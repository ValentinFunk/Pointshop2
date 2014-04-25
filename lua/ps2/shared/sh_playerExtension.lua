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