Pointshop2.AddEquipmentSlot( "Trail", function( item )
	--Check if the item is a trail
	return instanceOf( Pointshop2.GetItemClassByName( "base_trail" ), item )
end, 1 )
