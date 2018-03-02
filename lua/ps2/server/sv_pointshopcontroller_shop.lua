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
                LibK.GLib.Error("Pointshop2Controller:internalBuyItem - Error running sql " + tostring(err))
                return Pointshop2.DB.DoQuery("ROLLBACK"):Then( function()
                    return Promise.Reject( "Error!" )
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
        ply.PS2_Inventory:notifyItemAdded(item)
        item:OnPurchased( )
        self:startView( "Pointshop2View", "displayItemAddedNotify", ply, item )
        return item
    end)
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
		return Promise.Reject( "Cannot buy item: " .. ( err or errid or "" ) )
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

function Pointshop2Controller:sellItem( ply, itemId )
	local item = KInventory.ITEMS[itemId]
	if not item then
		KLogf( 3, "[WARN] Player %s tried to sell an item that wasn't cached (id %i)", ply:Nick( ), itemId )
		return Promise.Reject( 0, "Invalid Data" )
	end

	if not item:CanBeSold( ) then
		KLogf( 3, "[WARN] Player %s tried to sell not sellable item %i", ply:Nick( ), itemId )
		return Promise.Reject( 0, "Invalid Data" )
	end

	if not Pointshop2.PlayerOwnsItem( ply, item ) then
		transactionDef:Reject( 0, "Couldn't sell item: You don't own this item." )
		return transactionDef:Promise( )
	end

	local slot
	for k, v in pairs( ply.PS2_Slots ) do
		if v.itemId == item.id then
			slot = v
		end
	end

	LibK.SetBlocking( true )
	Pointshop2.DB.DoQuery( "BEGIN" )
	return Promise.Resolve():Then(function()
		if ply.PS2_Inventory:containsItem( item ) then
			return ply.PS2_Inventory:removeItem( item ) --Unlink from inventory
		elseif slot then
			return slot:removeItem( item ):Then( function( )
				self:startView( "Pointshop2View", "slotChanged", ply, slot )
			end )
		end
	end):Then( function( )
		self:startView( "Pointshop2View", "playerUnequipItem", player.GetAll( ), ply, item.id )
		item:OnHolster( )
		Pointshop2.DeactivateItemHooks(item)
		item:OnSold( )
		local amount, currencyType = item:GetSellPrice( )
		ply.PS2_Wallet[currencyType] = ply.PS2_Wallet[currencyType] + amount
		return ply.PS2_Wallet:save( )
	end ):Then( function( )
		return item.id, item:remove( ) --remove the actual db entry
	end ):Then( function( itemId )
		KInventory.ITEMS[itemId] = nil
		Pointshop2.LogCacheEvent('REMOVE', 'SellItem', item.id)
		KLogf( 4, "Player %s sold an item", ply:Nick( ) )
		hook.Run( "PS2_SoldItem", ply )

		Pointshop2.DB.DoQuery( "COMMIT" )
		LibK.SetBlocking( false )
		self:sendWallet( ply )

	end, function( errid, err )
		KLogf( 2, "Error selling item: %s", err )
		Pointshop2.DB.DoQuery( "ROLLBACK" )
		LibK.SetBlocking( false )
	end )
end

--Remove Item, clear inventory references etc.
function Pointshop2Controller:removeItemFromPlayer( ply, item )
	local slot
	for k, v in pairs( ply.PS2_Slots ) do
		if v.itemId == item.id then
			slot = v
		end
	end

	local itemId = item.id
	return Promise.Resolve( )
	:Then( function( )
		if ply.PS2_Inventory:containsItem( item ) then
			return ply.PS2_Inventory:removeItem( item ) --Unlink from inventory
		elseif slot then
			return slot:removeItem( item ):Then( function( )
				self:startView( "Pointshop2View", "slotChanged", ply, slot )
			end )
		else
			return Promise.Reject("Pointshop2Controller:removeItemFromPlayer - Item not in slot or inventory")
		end
	end )
	:Then( function( )
		item:OnHolster( )
		Pointshop2.DeactivateItemHooks(item)
		self:startView( "Pointshop2View", "playerUnequipItem", player.GetAll( ), ply, item.id )
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
		KLogf( 3, "[ERROR] Player %s tried to unequipItem empty slot %s", ply:Nick( ), slotName )
		self:startView( "Pointshop2View", "displayError", ply, "Could not unequip item, " .. slotName .. " is empty!" )
		return
	end

	local item = KInventory.ITEMS[slot.itemId]
	if not item then
		KLogf( 3, "[ERROR] Player %s tried to unequip an uncached Item %i", ply:Nick( ), slot.itemId )
		self:startView( "Pointshop2View", "displayError", ply, "Could not unequip item, Item not found in cache" )
		return
	end

	LibK.SetBlocking( true )
	Pointshop2.DB.DoQuery( "BEGIN" )

	return ply.PS2_Inventory:addItem( item )
	:Then( function( )
		slot.itemId = nil
		slot.Item = nil
		return slot:save( )
	end )
	:Then( function( updatedSlot )
		item:OnHolster( )
		Pointshop2.DeactivateItemHooks(item)
		hook.Run( "PS2_UnEquipItem", ply, item.id )

		self:startView( "Pointshop2View", "playerUnequipItem", player.GetAll( ), ply, item.id )
		self:startView( "Pointshop2View", "slotChanged", ply, updatedSlot )

		Pointshop2.DB.DoQuery( "COMMIT" )
		LibK.SetBlocking( false )
	end, function( errid, err )
		self:reportError( "Pointshop2View", ply, "Error unequipping item", errid, err )

		Pointshop2.DB.DoQuery( "ROLLBACK" )
		LibK.SetBlocking( false )
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
		KLogf( 3, "[Pointshop2][WARN] Player %s tried to equip item %i into slot %s (not valid for slot)", ply:Nick( ), itemId, slotName )
		self:startView( "Pointshop2View", "displayError", ply, "Could not equip item: You can't put it into this slot." )
		return
	end

	LibK.SetBlocking( true )
	Pointshop2.DB.DoQuery( "BEGIN" )
	local slot
	local slotsused = 1
	for k, v in pairs( ply.PS2_Slots ) do
		if v.slotName == slotName then
			slot = v
		end
		if v.itemId then
			slotsused = slotsused + 1
		end
	end

	if not slot then
		slot = Pointshop2.EquipmentSlot:new( )
		slot.ownerId = ply.kPlayerId
		slot.slotName = slotName
		slot:save( )
		ply.PS2_Slots[slot.id] = slot
	end


	local moveOldItemDef = Deferred( )
	if slot.itemId then
		local oldItem = KInventory.ITEMS[slot.itemId]
		if not oldItem then
			KLogf( 2, "[ERROR] Unsynced item %i in slot %s", slot.itemId, slot.slotName )
		end

		ply.PS2_Inventory:addItem( oldItem )
		:Then( function( )
			moveOldItemDef:Resolve( )
			Pointshop2.DeactivateItemHooks( oldItem )
			oldItem:OnHolster( ply )
			self:startView( "Pointshop2View", "playerUnequipItem", player.GetAll( ), ply, oldItem.id )
			slot.Item = nil
			slot.itemId = nil
			hook.Run( "PS2_SlotChanged", ply, slot, nil )
		end, function( errid, err )
			moveOldItemDef:Reject( errid, err )
		end )
	else
		moveOldItemDef:Resolve( )
	end

	moveOldItemDef:Then( function( )
		slot.itemId = item.id
		slot.Item = item
		self:startView( "Pointshop2View", "slotChanged", ply, slot )
		hook.Run( "PS2_SlotChanged", ply, slot, item )
		return slot:save( )
	end )
	:Then( function( slot )
		return ply.PS2_Inventory:removeItem( item ) --unlink from inventory
	end )
	:Done( function( )
		item.owner = ply
		if not IsValid( item:GetOwner() ) then
			debug.Trace( )
			print( "Error in 0" )
		end

		slot.Item = item
		slot.itemId = item.id

		if item.class:IsValidForServer( Pointshop2.GetCurrentServerId( ) ) then
			Pointshop2.ActivateItemHooks( item )
		end

		--Delay to next frame to clear stack
		timer.Simple( 0, function( )
			if item.class:IsValidForServer( Pointshop2.GetCurrentServerId( ) ) then
				item:OnEquip(  )
				hook.Run( "PS2_EquipItem", ply, item.id, slotsused )
				self:startView( "Pointshop2View", "playerEquipItem", player.GetAll( ), ply.kPlayerId, item )
			end
		end )

		Pointshop2.DB.DoQuery( "COMMIT" )
		LibK.SetBlocking( false )
	end )
	:Fail( function( errid, err )
		self:reportError( "Pointshop2View", ply, "Error equipping item", errid, err )

		Pointshop2.DB.DoQuery( "ROLLBACK" )
		LibK.SetBlocking( false )
	end )
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
