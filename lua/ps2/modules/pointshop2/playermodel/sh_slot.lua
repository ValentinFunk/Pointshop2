Pointshop2.AddEquipmentSlot( "Model", function( item )
	--Check if the item is a playermodel
	return instanceOf( Pointshop2.GetItemClassByName( "base_playermodel" ), item )
end, 0 )