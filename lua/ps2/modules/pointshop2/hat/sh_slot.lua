Pointshop2.ValidHatSlots = { }

function Pointshop2.AddHatSlot( name )
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
	end, 2 )
	table.insert( Pointshop2.ValidHatSlots, name )
end

Pointshop2.AddHatSlot( "Hat" )
Pointshop2.AddHatSlot( "Accessory" )
Pointshop2.AddHatSlot( "Accessory 2" )
