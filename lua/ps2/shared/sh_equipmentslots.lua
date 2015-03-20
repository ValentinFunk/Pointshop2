Pointshop2.EquipmentSlots = { } -- { { name = validationFunction }, ... }
Pointshop2.EquipmentSlotLookup = {}

function Pointshop2.IsItemValidForSlot( item, slotName )
	return Pointshop2.EquipmentSlotLookup[slotName]( item )
end

function Pointshop2.AddEquipmentSlot( slotName, func, order )
	Pointshop2.EquipmentSlotLookup[slotName] = func
	table.insert( Pointshop2.EquipmentSlots, {
		name = slotName,
		canHoldItem = func,
		order = order or math.huge
	} )
	Pointshop2.EquipmentSlots[#Pointshop2.EquipmentSlots].order2 = #Pointshop2.EquipmentSlots
	table.sort( Pointshop2.EquipmentSlots, function( a, b )
		if a.order < b.order then 
			return true
		end
		if a.order > b.order then
			return false
		end
		return a.order2 < b.order2
	end )
end

function Pointshop2.IsValidEquipmentSlot( slotName )
	return Pointshop2.EquipmentSlotLookup[slotName] != nil
end

if CLIENT then
	hook.Add( "PS2_PopulateSlots", "AddDefaultSlots", function( slotsLayout )
		for k, v in pairs( Pointshop2.EquipmentSlots ) do
			local slot = slotsLayout:Add( "DPointshopEquipmentSlot" )
			slot:SetLabel( v.name )
			slot.CanHoldItem = function( self, item ) return v.canHoldItem( item ) end
			if LocalPlayer().PS2_Slots[v.name] then
				slot:SetItem( LocalPlayer().PS2_Slots[v.name] )
			end
		end
	end )
end