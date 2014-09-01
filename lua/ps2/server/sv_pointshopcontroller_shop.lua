function Pointshop2Controller:buyItem( ply, itemClass, currencyType )
	local itemClass = Pointshop2.GetItemClassByName( itemClass )
	if not itemClass then
		self:startView( "Pointshop2View", "displayError", ply, "Couldn't buy item, item " .. itemClass .. " isn't valid" ) 
		return
	end
	local price = itemClass:GetBuyPrice( ply )
	
	if #ply.PS2_Inventory:getItems( ) >= ply.PS2_Inventory.numSlots then
		self:startView( "Pointshop2View", "displayError", ply, "Couldn't buy item, your inventory is full!" ) 
		return
	end
	
	--[[
		Wrap everything into a blocking transaction to make sure we don't get duplicate stuff
		if mysql takes a little longer to respond and prevent any lua from queueing querys in 
		between.
		TODO: look into alternative methods of locking the database as this is a bit performance heavy because it blocks the game thread, 
	]]--
	LibK.SetBlocking( true )
	Pointshop2.DB.DoQuery( "BEGIN" )
	:Fail( function( errid, err ) 
		KLogf( 2, "Error starting transaction: %s", err )
		self:startView( "Pointshop2View", "displayError", ply, "A Technical error occured, your purchase was not carried out." )
		error( "Error starting transaction:", err )
	end )
	
	if currencyType == "points" and price.points and ply.PS2_Wallet.points >= price.points then
		ply.PS2_Wallet.points = ply.PS2_Wallet.points - price.points
	elseif currencyType == "premiumPoints" and price.premiumPoints and ply.PS2_Wallet.premiumPoints >= price.premiumPoints then
		ply.PS2_Wallet.premiumPoints = ply.PS2_Wallet.premiumPoints - price.premiumPoints
	else
		self:startView( "Pointshop2View", "displayError", ply, "You cannot purchase this item (insufficient " .. currencyType .. ")" )
		return
	end
	
	ply.PS2_Wallet:save( )
	:Then( function( )
		local item = itemClass:new( )
		return item:save( )
	end )
	:Then( function( item )
		KInventory.ITEMS[item.id] = item
		return ply.PS2_Inventory:addItem( item )
		:Then( function( )
			item:OnPurchased( ply )
			self:startView( "Pointshop2View", "displayItemAddedNotify", ply, item )
		end )
	end )
	:Then( function( )
		KLogf( 4, "Player %s purchased item %s", ply:Nick( ), itemClass )
		hook.Run( "PS2_PurchasedItem", ply, itemClass )
		Pointshop2.DB.DoQuery( "COMMIT" )
		LibK.SetBlocking( false )
		self:sendWallet( ply )
	end, function( errid, err )
		KLogf( 2, "Error saving item purchase: %s", err )
		Pointshop2.DB.DoQuery( "ROLLBACK" )
		LibK.SetBlocking( false )
		
		self:startView( "Pointshop2View", "displayError", ply, "A technical error occured (2), your purchase was not carried out." )
	end )
end

function Pointshop2Controller:sellItem( ply, itemId )
	local transactionDef = Deferred( )
	
	LibK.SetBlocking( true )
	Pointshop2.DB.DoQuery( "BEGIN" )
	:Fail( function( errid, err ) 
		KLogf( 2, "Error starting transaction: %s", err )
		
		transactionDef:Reject( 0, "A Technical error occured(1), your purchase was not carried out." )
		return transactionDef:Promise()
	end )
	
	
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
	
	local def 
	if ply.PS2_Inventory:containsItem( item ) then
		def = ply.PS2_Inventory:removeItem( item ) --Unlink from inventory
	elseif slot then
		def = slot:removeItem( item ):Then( function( )
			self:startView( "Pointshop2View", "slotChanged", ply, slot )
		end )
	end
	
	def:Then( function( )
		item:OnHolster( ply )
		item:OnSold( ply )
		ply.PS2_Wallet.points = ply.PS2_Wallet.points + item:GetSellPrice( ply )
		return ply.PS2_Wallet:save( )
	end )
	:Then( function( ) 
		KInventory.ITEMS[item.id] = nil
		return item:remove( ) --remove the actual db entry
	end )
	:Then( function( )
		KLogf( 4, "Player %s sold an item", ply:Nick( ) )
		hook.Run( "PS2_SoldItem", ply, itemClass )
		Pointshop2.DB.DoQuery( "COMMIT" )
		LibK.SetBlocking( false )
		self:sendWallet( ply )
		
		transactionDef:Resolve( )
	end, function( errid, err )
		KLogf( 2, "Error selling item: %s", err )
		Pointshop2.DB.DoQuery( "ROLLBACK" )
		LibK.SetBlocking( false )
		
		transactionDef:Reject( errid, "A technical error occured (2), your sale was not carried out." )
	end )
	
	return transactionDef:Promise( )
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
	
	ply.PS2_Inventory:addItem( item )
	:Then( function( )
		slot.itemId = nil
		slot.Item = nil
		return slot:save( )
	end )
	:Then( function( updatedSlot )
		item:OnHolster( ply )
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
			oldItem:OnHolster( ply )
			self:startView( "Pointshop2View", "playerUnequipItem", player.GetAll( ), ply, oldItem.id )
		end, function( errid, err )
			moveOldItemDef:Reject( errid, err )
		end )
	else
		moveOldItemDef:Resolve( )
	end
	
	moveOldItemDef:Then( function( )
		slot.itemId = item.id
		slot.Item = item
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
		
		--Delay to next frame to clear stack
		timer.Simple( 0, function( )
			item:OnEquip(  )
		end )
		
		slot.Item = item
		self:startView( "Pointshop2View", "slotChanged", ply, slot )
		hook.Run( "PS2_EquipItem", ply, item.id, slotsused )
		self:startView( "Pointshop2View", "playerEquipItem", player.GetAll( ), ply.kPlayerId, item )
		Pointshop2.DB.DoQuery( "COMMIT" )
		LibK.SetBlocking( false )
	end )
	:Fail( function( errid, err )
		self:reportError( "Pointshop2View", ply, "Error equipping item", errid, err )
		
		Pointshop2.DB.DoQuery( "ROLLBACK" )
		LibK.SetBlocking( false )
	end )
end