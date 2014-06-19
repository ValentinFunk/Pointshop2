Pointshop2.ValidHatSlots = { }

local function addHatSlot( name )
	Pointshop2.AddEquipmentSlot( name, function( item )
		local isHat = instanceOf( Pointshop2.GetItemClassByName( "base_hat" ), item )
		if isHat and item:CanBeEquippedInSlot( name ) then
			return true
		end
		return false
	end )
	table.insert( Pointshop2.ValidHatSlots, name )
end

addHatSlot( "Hat" )
addHatSlot( "Accessory" )
addHatSlot( "Accessory 2" )
