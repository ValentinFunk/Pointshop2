Pointshop2.ValidHatSlots = { }

local function addHatSlot( name )
	Pointshop2.AddEquipmentSlot( name, function( item )
		local isHat = instanceOf( Pointshop2.GetItemClassByName( "base_hat" ), item )
		
		if not isHat or not item:CanBeEquippedInSlot( name ) then
			return false
		end
		
		--Check for same class items:
		for _, slotName in pairs( Pointshop2.ValidHatSlots ) do
			local equipmentItem = Pointshop2.GetItemInSlot( item:GetOwner(), slotName )
			if equipmentItem then
				--Allow to move items between slots
				if equipmentItem == item then
					continue
				end
				
				if equipmentItem.class.className == item.class.className then
					return false
				end
			end
		end
		
		return true
	end )
	table.insert( Pointshop2.ValidHatSlots, name )
end

addHatSlot( "Hat" )
addHatSlot( "Accessory" )
addHatSlot( "Accessory 2" )
