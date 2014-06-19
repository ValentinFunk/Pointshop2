Pointshop2.EquipmentSlots = { } -- { { name = validationFunction }, ... }

function Pointshop2.IsItemValidForSlot( item, slotName )
	return Pointshop2.EquipmentSlots[slotName]( item )
end

function Pointshop2.AddEquipmentSlot( slotName, func )
	Pointshop2.EquipmentSlots[slotName] = func
end

function Pointshop2.IsValidEquipmentSlot( slotName )
	return Pointshop2.EquipmentSlots[slotName] != nil
end

if CLIENT then
	hook.Add( "PS2_PopulateSlots", "AddDefaultSlots", function( slotsLayout )
		for slotName, acceptFunc in pairs( Pointshop2.EquipmentSlots ) do
			local slot = slotsLayout:Add( "DPointshopEquipmentSlot" )
			slot:SetLabel( slotName )
			slot.CanHoldItem = function( self, item ) return acceptFunc( item ) end
			if LocalPlayer().PS2_Slots[slotName] then
				slot:SetItem( LocalPlayer().PS2_Slots[slotName] )
			end
		end
	end )
end