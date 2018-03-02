local Player = FindMetaTable( "Player" )

--TODO
function Player:PS2_HasItemEquipped( item ) 
	if CLIENT then
		for slotName, eqItem in pairs( self.PS2_Slots ) do
			if eqItem.id == item.id then
				return true
			end
		end
		return false
	end
	for k, slot in pairs( self.PS2_Slots ) do
		if slot.itemId == item.id then
			return true
		end
	end
end

function Player:PS2_GetItemInSlot( name )
	if CLIENT then
		return self.PS2_Slots and self.PS2_Slots[name]
	else
		for k, slot in pairs( self.PS2_Slots or {} ) do
			if slot.slotName == name then
				return slot.Item
			end
		end
	end
end

function Player:PS2_GetWallet( )
	return self.PS2_Wallet
end

function Player:PS2_HasInventorySpace( slots )
	if not self.PS2_Inventory then
		error( "Inventory of " .. tostring( self ) .. " not cached" )	
	end
	
	local slotsUsed = table.Count( self.PS2_Inventory:getItems() )
	local slotsTotal = self.PS2_Inventory:getNumSlots( )
	return slotsTotal - slotsUsed - slots >= 0
end

function Player:PS2_GetFirstItemOfClass( class )
	for k, item in pairs( self.PS2_Inventory:getItems( ) ) do
		if instanceOf( class, item ) then
			return item
		end
	end
end

function Player:PS2_CanAfford( itemClass )
	local price = itemClass:GetBuyPrice()
	local wallet = self:PS2_GetWallet()
	if not wallet or not price then
		return false
	end

	if price.points and wallet.points >= price.points then
		 return true
	end

	if price.premiumPoints and wallet.premiumPoints >= price.premiumPoints then 
		return true
	end

	return false
end

function Player:PS2_CanBuyItem( itemClass )
	if itemClass.isBase then
		return false, "You can not buy a base", "Invalid"
	end

	if not self:PS2_CanAfford( itemClass ) then
		return false, "You cannot afford this item", "Can't afford"
	end

	if not self:PS2_HasInventorySpace( 1 ) then
		return false, "Your inventory is full", "Inventory full"
	end

	if not itemClass:PassesRankCheck( self ) then
		return false, "You are not the correct rank", "Wrong Rank"
	end

	local tree
	if SERVER then 
		tree = Pointshop2Controller:getInstance().tree
	else
		tree = Pointshop2View:getInstance().categoryItemsTable
	end
	if table.HasValue( tree:getNotForSaleItemClassNames( ), itemClassName ) then
		return false, "This item cannot be bought", "Can't buy"
	end

	return true
end