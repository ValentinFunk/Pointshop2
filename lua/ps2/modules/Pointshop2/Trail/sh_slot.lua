Pointshop2.AddEquipmentSlot( "Trail", function( item )
	--Check if the item is a playermodel
	return instanceOf( Pointshop2.GetItemClassByName( "base_trail" ), item )
end )