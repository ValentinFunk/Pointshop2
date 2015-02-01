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