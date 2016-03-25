Pointshop2.EquipmentSlots = { } -- { { name = validationFunction }, ... }
Pointshop2.EquipmentSlotLookup = {}

function Pointshop2.IsItemValidForSlot( item, slotName )
	return Pointshop2.EquipmentSlotLookup[slotName]( item )
end

function Pointshop2.RemoveEquipmentSlot( slotName )
	Pointshop2.EquipmentSlotLookup[slotName] = nil
	for k, v in pairs(Pointshop2.EquipmentSlots) do
		if v.name == slotName then
			Pointshop2.EquipmentSlots[k] = nil
		end
	end
end

function Pointshop2.FindEquipmentSlot( slotName )
	for k, v in pairs( Pointshop2.EquipmentSlots ) do
		if v.name == slotName then
			return Pointshop2.EquipmentSlots[k]
		end
	end
end

function Pointshop2.AddEquipmentSlotEx( slot )
	table.insert( Pointshop2.EquipmentSlots, slot )
	Pointshop2.EquipmentSlotLookup[slot.name] = slot.canHoldItem

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

function Pointshop2.AddEquipmentSlot( slotName, func, order )
	local slot = {
		name = slotName,
		canHoldItem = func,
		order = order or math.huge
	}
	Pointshop2.AddEquipmentSlotEx(slot)
end

function Pointshop2.IsValidEquipmentSlot( slotName )
	return Pointshop2.EquipmentSlotLookup[slotName] != nil
end

if CLIENT then
	function Pointshop2.FindSlotThatContains(item)
		for slotName, itemInSlot in pairs(LocalPlayer().PS2_Slots) do
			if itemInSlot == item then
				return slotName
			end
		end
	end

	hook.Add( "PS2_PopulateSlots", "AddDefaultSlots", function( slotsLayout )
		for k, v in pairs( Pointshop2.EquipmentSlots ) do
			local slot = slotsLayout:Add( "DPointshopEquipmentSlot" )
			slot:SetSlotTable(v)
			slot:SetLabel( v.name )
			slot.CanHoldItem = function( self, item )
				-- Handle swaps between two slots correctly
				local itemInThisSlot = LocalPlayer().PS2_Slots[v.name]
				local previousSlot = Pointshop2.FindSlotThatContains(item)
				if itemInThisSlot and previousSlot then
					-- calls slot's function directly to avoid infinite loops
					if not Pointshop2.EquipmentSlotLookup[previousSlot]() then
						return false
					end
				end

				-- delegate to slot's function
				return v.canHoldItem( item )
			end
			if LocalPlayer().PS2_Slots[v.name] then
				slot:SetItem( LocalPlayer().PS2_Slots[v.name] )
			end
		end
	end )
else
	function Pointshop2.FindSlotThatContains(ply, item)
		for name, slot in pairs(ply.PS2_Slots) do
			if slot.itemId and slot.itemId == item.id then
				return slot.slotName
			end
		end
	end
end
