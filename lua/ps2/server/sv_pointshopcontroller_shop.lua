function Pointshop2Controller:isValidPurchase( ply, itemClassName )
    local itemClass = Pointshop2.GetItemClassByName( itemClassName )
    if not itemClass then
        return Promise.Reject( "Couldn't buy item, item " .. itemClassName .. " isn't valid" )
    end

    local canBuy, message = ply:PS2_CanBuyItem( itemClass )
    if not canBuy then
        return Promise.Reject( message )
    end

    return self:sendWallet( ply ) -- Reload wallet from DB before carrying out purchase
end

LibK.GLib.PlayerMonitor:AddEventListener("PlayerDisconnected", "PS2_PlayerDisconnected", function (_, ply, userId)
    if not ply.PS2_Inventory or not ply.PS2_Inventory:getItems() then
        KLogf(4, "Player %s: Left before inventory has been loaded", ply:Nick())
        ply.fullyLoadedPromise:Reject('Disconnected')
    else
        for k, item in pairs(ply.PS2_Inventory:getItems()) do
            KInventory.ITEMS[item.id] = nil
            Pointshop2.LogCacheEvent('REMOVE', 'PlayerDisconnected (Inv)', item.id)
        end
    end

    if not ply.PS2_Slots then
        KLogf(4, "Player %s: Left before slots were planned", ply:Nick())
    else
        for k, slot in pairs(ply.PS2_Slots) do
            if slot.Item then
                Pointshop2.DeactivateItemHooks(slot.Item)
                KInventory.ITEMS[slot.Item.id] = nil
                Pointshop2.LogCacheEvent('REMOVE', 'PlayerDisconnected (Slots)', slot.Item.id)
            end
        end
    end
end)

function Pointshop2Controller:internalBuyItem( ply, itemClass, currencyType, price, suppressNotify )
    local item = itemClass:new( )
    item.purchaseData = {
        time = os.time(),
        amount = price,
        currency = currencyType,
        origin = "LUA"
    }
    item.inventory_id = ply.PS2_Inventory.id
    item:preSave()

    ply.PS2_Wallet[currencyType] = ply.PS2_Wallet[currencyType] - price
    local takePointsSql = Format("UPDATE ps2_wallet SET %s = %s - %s WHERE id = %i", currencyType, currencyType, Pointshop2.DB.SQLStr(price), ply.PS2_Wallet.id)
    return Promise.Resolve()
    :Then(function()
        if Pointshop2.DB.CONNECTED_TO_MYSQL then
            local transaction = LibK.TransactionMysql:new(Pointshop2.DB)
            transaction:begin()
            transaction:add(item:getSaveSql()) -- Create Item
            transaction:add(takePointsSql) -- Take Points
            return transaction:commit():Then(function()
                return Pointshop2.DB.DoQuery("SELECT LAST_INSERT_ID() as id")
            end ):Then(function(id)
                item.id = id[1].id
                return item
            end):Then(Promise.Resolve, function(err)
                if string.find( tostring(err), "Out of range value" ) then
                    Pointshop2.DB.DoQuery("ROLLBACK")
                    return Promise.Reject( "Not enough " .. currencyType )
                end

                LibK.GLib.Error("Pointshop2Controller:internalBuyItem - Error running sql " .. tostring(err))
                return Pointshop2.DB.DoQuery("ROLLBACK"):Then( function()
                    return Promise.Reject( "Error buying item" )
                end )
            end )
        else
            sql.Begin()
            return Pointshop2.DB.DoQuery(takePointsSql):Then(function()
                return item:save()
            end):Then(function()
                sql.Commit()
                return Promise.Resolve(item)
        end, function(err)
                sql.Query("ROLLBACK")
                return Promise.Reject(err)
            end)
        end
    end):Then(function(item)
        self:sendWallet( ply )
        ply.PS2_Inventory:notifyItemAdded( item )
        item:OnPurchased( )
        self:startView( "Pointshop2View", "displayItemAddedNotify", ply, item )
        return item
    end, function(err)
        self:sendWallet( ply )
        return Promise.Reject(err)
    end )
end

function Pointshop2Controller:buyItem( ply, itemClassName, currencyType )
    return self:isValidPurchase( ply, itemClassName )
    :Then( function( )
        local itemClass = Pointshop2.GetItemClassByName( itemClassName )

        local price = itemClass:GetBuyPrice( ply )
        if not price then
            KLogf( 3, "Player %s tried to buy item %s which cannot be bought! Hacking Attempt?", ply:Nick(), itemClass )
            return Promise.Reject( "Item %s cannot be bought!" )
        end

        if currencyType == "points" and price.points and ply.PS2_Wallet.points < price.points  or
           currencyType == "premiumPoints" and price.premiumPoints and ply.PS2_Wallet.premiumPoints < price.premiumPoints
        then
            return Promise.Reject( "You cannot purchase this item (insufficient " .. currencyType .. ")" )
        end

        return self:internalBuyItem( ply, itemClass, currencyType, price[currencyType] )
    end )
    :Then( function( item )
        KLogf( 4, "Player %s purchased item %s", ply:Nick( ), itemClassName )
        hook.Run( "PS2_PurchasedItem", ply, itemClassName )
        return item
    end, function( errid, err )
        KLogf( 2, "Error saving item purchase: %s", err or errid )
        return err
    end )
end

function Pointshop2Controller:easyAddItem( ply, itemClassName, purchaseData, suppressNotify )
    local itemClass = Pointshop2.GetItemClassByName( itemClassName )
    return Promise.Resolve()
    :Then( function( )
        if not itemClass then
            return Promise.Reject( "Item class " .. tostring( itemClassName ) .. " is not valid!" )
        end

        local item = itemClass:new( )
        local price = itemClass.Price
        local currencyType, amount
        if price.points then
            currencyType = "points"
            amount = price.points
        elseif price.premiumPoints then
            currencyType = "premiumPoints"
            amount = price.premiumPoints
        else
            currencyType = "points"
            amount = 0
        end
        item.purchaseData = purchaseData or {
            time = os.time(),
            amount = amount,
            currency = currencyType,
            origin = "LUA"
        }
        return item
    end )
    :Then( function( item )
        return ply.PS2_Inventory:addItem( item )
        :Then( function( )
            item:OnPurchased( )
            if not suppressNotify then
                self:startView( "Pointshop2View", "displayItemAddedNotify", ply, item )
            end
            return item
        end )
    end )
end

--[[
    Whenever the DB has been updated to unequip an item
    this should be called to update the game state to reflect the change.
]]
function Pointshop2Controller:handleItemUnequip( item, ply, slotName )
    Pointshop2.DeactivateItemHooks( item )
    item:OnHolster( ply )
    hook.Run( "PS2_ItemRemovedFromSlot", slotName, item )
    for slotId, slotObj in pairs( ply.PS2_Slots ) do
        if slotObj.itemId == item.id then
            if slotObj.Item != item then
                MsgC( Color(255, 0, 0), "Assertion Failure: Cached item does not match slot item\n" )
                MsgC( Color(255, 0, 0), LibK.GLib.StackTrace (nil, 1) )
                PrintTable(slotObj)
            end
            ply.PS2_Slots[slotId] = nil
        end
    end
    
    local players = {}
    for k, v in pairs( player.GetAll() ) do
        if getPromiseState( v.fullyLoadedPromise ) != "done" then
            continue
        end
        
        table.insert( players, v )
    end
    
    self:startView( "Pointshop2View", "playerUnequipItem", players, ply, item.id )
end

local function isValidSale( ply, item )
    if not item then
        KLogf( 3, "[WARN] Player %s tried to sell an item that wasn't cached", ply:Nick( ) )
        return Promise.Reject( 0, "Invalid Data" )
    end

    if not item:CanBeSold( ) then
        KLogf( 3, "[WARN] Player %s tried to sell not sellable item %i", ply:Nick( ), item.id )
        return Promise.Reject( 0, "Invalid Data" )
    end

    if not Pointshop2.PlayerOwnsItem( ply, item ) then
        KLogf( 3, "[WARN] Player %s tried to sell item he doesn't own", ply:Nick(), item.id )
        return Promise.Reject( 0, "Couldn't sell item: You don't own this item." )
    end

    return Promise.Resolve( )
end

function Pointshop2Controller:sellItem( ply, itemId )
    local item = KInventory.ITEMS[itemId]
    return isValidSale( ply, item ):Then(function()
        local amount, currencyType = item:GetSellPrice( )

        local slot = Pointshop2.GetSlotContainingItemId( ply, item.id )
        if slot then
            local transaction = Pointshop2.DB.Transaction()
            transaction:begin()
            transaction:add(Format("DELETE FROM ps2_equipmentslot WHERE id = %i", slot.id))
            transaction:add(Format("DELETE FROM kinv_items WHERE id = %i", item.id))
            transaction:add(Format("UPDATE ps2_wallet SET %s = %s + %i WHERE ownerId = %i", currencyType, currencyType, amount, ply.kPlayerId))
            return transaction:commit():Then(function()
                self:handleItemUnequip( item, ply, slot.slotName )
            end, function(err)
                transaction:rollback()
                LibK.GLib.Error(err)
            end )
        else
            local transaction = Pointshop2.DB.Transaction()
            transaction:begin()
            transaction:add(Format("DELETE FROM kinv_items WHERE id = %i", item.id))
            transaction:add(Format("UPDATE ps2_wallet SET %s = %s + %i WHERE ownerId = %i", currencyType, currencyType, amount, ply.kPlayerId))
            return transaction:commit():Then(function()
                ply.PS2_Inventory:notifyItemRemoved( itemId )
            end, function( err )
                transaction:rollback()
                LibK.GLib.Error(err)
            end )
        end
    end):Then(function()
        KInventory.ITEMS[itemId] = nil
        Pointshop2.LogCacheEvent( "REMOVE", "SellItem", item.id)
        item:OnSold( )
        KLogf( 4, "Player %s sold an item", ply:Nick( ) )
        return self:sendWallet( ply )
    end)
end

function Pointshop2Controller:sellItems( ply, itemIds )
    local validSale = Promise.Resolve( )
    local items = { }
    for k, itemId in pairs( itemIds ) do
        local item = KInventory.ITEMS[itemId]
        table.insert( items, item )
        validSale = validSale:Then( function()
            if Pointshop2.GetSlotContainingItemId( ply, item.id ) then
                return Promise.Reject( 0, "Items from slots cannot be sold using this method" )
            end
            return isValidSale( ply, item )
        end )
    end

    return validSale:Then(function()
        local saleAmounts = {
            points = 0,
            premiumPoints = 0
        }
        for k, item in pairs( items ) do
            local amount, currencyType = item:GetSellPrice( )
            saleAmounts[currencyType] = saleAmounts[currencyType] + amount
        end

        local transaction = Pointshop2.DB.Transaction()
        transaction:begin()
        local idsCommaSeparated = LibK._(items):chain():pluck("id"):join(","):value()
        transaction:add(Format("DELETE FROM kinv_items WHERE id IN (%s)", idsCommaSeparated))
        transaction:add(Format("UPDATE ps2_wallet SET points = points + %i, premiumPoints = premiumPoints + %i WHERE ownerId = %i", saleAmounts.points, saleAmounts.premiumPoints, ply.kPlayerId))
        return transaction:commit():Then(function()
            for k, itemId in pairs( itemIds ) do
                ply.PS2_Inventory:notifyItemRemoved( itemId )
            end
        end, function( err )
            transaction:rollback()
            LibK.GLib.Error(err)
        end )
    end):Then(function()
        for k, item in pairs( items ) do
            KInventory.ITEMS[item.id] = nil
            Pointshop2.LogCacheEvent("REMOVE", "SellItem", item.id)
            item:OnSold( )
        end

        local idsCommaSeparated = LibK._(items):chain():pluck("id"):join(","):value()
        KLogf( 4, "Player %s sold an item stack %s", ply:Nick( ), idsCommaSeparated )
        return self:sendWallet( ply )
    end)
end

--Remove Item, clear inventory references etc.
function Pointshop2Controller:removeItemFromPlayer( ply, item )
    local itemId = item.id
    return Promise.Resolve( )
    :Then( function( )
        local slot = Pointshop2.GetSlotContainingItemId( ply, item.id )
        if ply.PS2_Inventory:containsItem( item ) then
            return ply.PS2_Inventory:removeItem( item ) --Unlink from inventory
        elseif slot then
            return slot:removeItem( item ):Then( function( )
                self:handleItemUnequip( item, ply, slot.slotName )
            end )
        else
            return Promise.Reject("Pointshop2Controller:removeItemFromPlayer - Item not in slot or inventory")
        end
    end )
    :Then( function( )
        item:OnRemove( )
        return item:remove( ) --remove the actual db entry
    end ):Then(function()
        Pointshop2.LogCacheEvent('REMOVE', 'removeItemFromPlayer', itemId)
        KInventory.ITEMS[itemId] = nil
    end)
end

function Pointshop2Controller:adminRemoveItem(ply, itemId)
    local item = KInventory.ITEMS[itemId]
    if not item then
        return Promise.Reject("Invalid Item")
    end

    local owner = item:GetOwner( )
    if not IsValid(owner) then
        KLogf(4, "Removing item from offline player...")
        return WhenAllFinished{
            Pointshop2.EquipmentSlot.removeWhere{itemId = itemId},
            KInventory.Item.removeWhere{id = itemId}
        }
    else
        return self:removeItemFromPlayer(owner, item)
    end
end

function Pointshop2Controller:unequipItem( ply, slotName )
    local slot
    for k, v in pairs( ply.PS2_Slots ) do
        if v.slotName == slotName then
            slot = v
        end
    end

    if not slot then
        KLogf( 3, "[ERROR] Player %s tried to unequipItem from uncached slot %s", ply:Nick( ), slotName )
        self:startView( "Pointshop2View", "displayError", ply, "Could not unequip item, " .. slotName .. " is not a valid equipment slot." )
        return
    end

    if not slot.itemId then
        KLogf( 4, "[ERROR] Player %s tried to unequipItem empty slot %s", ply:Nick( ), slotName )
        -- self:startView( "Pointshop2View", "displayError", ply, "Could not unequip item, " .. slotName .. " is empty!" )
        return
    end

    local item = KInventory.ITEMS[slot.itemId]
    if not item then
        KLogf( 3, "[ERROR] Player %s tried to unequip an uncached Item %i", ply:Nick( ), slot.itemId )
        self:startView( "Pointshop2View", "displayError", ply, "Could not unequip item, Item not found in cache" )
        return
    end

    ply._EquipLock = ply._EquipLock or Promise.Resolve()
    if getPromiseState(ply._EquipLock) != "pending" then
        ply._EquipLock = Promise.Resolve()
    end

    ply._EquipLock = ply._EquipLock:Then( function( )
        item.inventory_id = ply.PS2_Inventory.id
        slot.itemId = nil
        slot.Item = nil

        local transaction = Pointshop2.DB.Transaction()
        transaction:begin()
        transaction:add(item:getSaveSql())
        transaction:add(slot:getSaveSql())

        return transaction:commit( )
    end ):Then( function( )
        ply.PS2_Inventory:notifyItemAdded( item, { doSend = false } )
        self:handleItemUnequip( item, ply, slot.slotName )
    end, function( err )
        KLogf( 1, "UnequipItem - Error running sql. Err: %s", tostring( err ) )
        return Pointshop2.DB.DoQuery("ROLLBACK")
    end )
end

function Pointshop2Controller:equipItem( ply, itemId, slotName )
    if not Pointshop2.IsValidEquipmentSlot( slotName ) then
        self:startView( "Pointshop2View", "displayError", ply, "Could not equip item, " .. slotName .. " is not a valid equipment slot." )
        KLogf( 3, "[Pointshop2][WARN] Player %s tried to equip item into invalid slot %s", ply:Nick( ), slotName )
        return
    end

    local item = KInventory.ITEMS[itemId]
    if not item then
        KLogf( 3, "[Pointshop2][WARN] Player %s tried to equip uncached item %i", ply:Nick( ), itemId )
        self:startView( "Pointshop2View", "displayError", ply, "Could not equip item: Item couldn't be found." )
        return
    end

    if not Pointshop2.PlayerOwnsItem( ply, item ) then
        KLogf( 3, "[Pointshop2][WARN] Player %s tried to equip foreign owned item %i", ply:Nick( ), itemId )
        self:startView( "Pointshop2View", "displayError", ply, "Could not equip item: You don't own this item." )
        return
    end

    if not Pointshop2.IsItemValidForSlot( item, slotName ) then
        KLogf( 3, "[Pointshop2][WARN] Player %s tried to equip item %i into slot %s (not valid for slot)", ply:Nick( ), itemId, item:GetPrintName(), slotName )
        self:startView( "Pointshop2View", "displayError", ply, "Could not equip item: You can't put it into this slot." )
        return
    end

    -- Make sure only one equip runs at a time
    ply._EquipLock = ply._EquipLock or Promise.Resolve()
    if getPromiseState(ply._EquipLock) != "pending" then
        ply._EquipLock = Promise.Resolve()
    end

    ply._EquipLock = ply._EquipLock:Then( function( )
        -- Find or create slot entry in DB
        local slot = ply:PS2_GetSlot( slotName )
        if slot then
            -- Move the item that is in that slot atm back into the inventory
            if slot.itemId then
                -- Doesn't make sense to move an item from a slot into the same slot
                if slot.itemId == itemId then
                    return Promise.Reject( -1, "BAIL" )
                end

                local transaction = Pointshop2.DB.Transaction( )
                transaction:begin( )
                local oldItem = KInventory.ITEMS[slot.itemId]
                if not oldItem then
                    KLogf( 2, "[ERROR] Unsynced item %i in slot %s", slot.itemId, slot.slotName )
                end

                oldItem.inventory_id = ply.PS2_Inventory.id
                slot.itemId = nil
                slot.Item = nil
                transaction:add( oldItem:getSaveSql( ) )
                transaction:add( slot:getSaveSql( ) )

                return transaction:commit( ):Then( function( )
                    ply.PS2_Inventory:notifyItemAdded( oldItem, { doSend = false } )
                    self:handleItemUnequip( oldItem, ply, slot.slotName )
                end ):Then( function( )
                    return slot
                end, function( err )
                    transaction:rollback( )
                    return Promise.Reject( "Moving the old item failed " .. err )
                end )
            end

            return slot
        else
            -- Create a slot entry
            local newSlot = Pointshop2.EquipmentSlot:new( )
            newSlot.ownerId = ply.kPlayerId
            newSlot.slotName = slotName
            return newSlot:save( ):Then( function( )
                KLogf(4, "Created slot" )
                dpt( newSlot )
                ply.PS2_Slots[newSlot.id] = newSlot
                return newSlot
            end )
        end
    end ):Then( function( slot )
        local movingFromSlot = ply:PS2_HasItemEquipped( item )
        -- Move the new item into the slot and remove the item from inventory
        -- or the slot where it is currently in
        slot.itemId = item.id
        slot.Item = item
        local transaction = Pointshop2.DB.Transaction( )
        transaction:begin( )
        if movingFromSlot then
            movingFromSlot.Item = nil
            movingFromSlot.itemId = nil
            transaction:add( movingFromSlot:getSaveSql( ) )
        else
            item.inventory_id = nil
            transaction:add( item:getSaveSql( ) )
        end
        transaction:add( slot:getSaveSql( ) )
        return transaction:commit( ):Then( function( )
            return slot, movingFromSlot
        end ):Fail( function( err )
            transaction:rollback( )
        end )
    end )
    :Then( function( slot, movingFromSlot )
        item.owner = ply

        self:handleItemEquip( ply, item, slot.slotName )
        if movingFromSlot then
            self:startView( "Pointshop2View", "itemSlotSwapped", ply, movingFromSlot.slotName )
        else
            ply.PS2_Inventory:notifyItemRemoved( item.id, { resetSelection = false } )
        end
    end )
    :Then( function() end, function( errid, err )
        if errid == -1 then
            return Promise.Resolve( )
        end

        self:reportError( "Pointshop2View", ply, "Error equipping item", errid, err )
    end )

    return ply._EquipLock
end

Pointshop2.DlcPacks = {}

function Pointshop2.RegisterDlcPack( name, items, categories )
    Pointshop2.DlcPacks[name] = { items = items, categories = categories }
end

function Pointshop2Controller:installDlcPack( ply, name )
    local pack = Pointshop2.DlcPacks[name]
    if not pack then
        KLogf( 2, "Trying to install invalid DLC pack " .. name .. "!" )
        return
    end

    Promise.Resolve( )
    :Then( function( )
        return self:importItems( pack.items )
    end )
    :Then( function( )
        return self:importCategoryOrganization( pack.categories )
    end )
    :Done( function( )
        return self:moduleItemsChanged( true )
    end )
end
