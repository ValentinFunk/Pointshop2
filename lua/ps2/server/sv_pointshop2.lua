LibK.addContentFolder( "materials/pointshop2" )
LibK.addContentFolder( "materials/trails" )
LibK.SetupDatabase( "Pointshop2", Pointshop2 )

function Pointshop2.ResetDatabase( )
	for k, v in pairs( Pointshop2 ) do
		if istable( v ) and v.dropTable then
			v.dropTable( )
			KLogf( 5, "Dropped %s", v.name )
		end
	end
	
	for k, v in pairs( KInventory ) do
		if istable( v ) and v.dropTable then
			v.dropTable( )
			KLogf( 5, "Dropped %s", v.name )
		end
	end
end

function Pointshop2.PlayerOwnsItem( ply, item )
	for k, v in pairs( ply.PS2_Inventory:getItems( ) ) do
		if v.id == item.id then
			return true
		end
	end
	
	for k, v in pairs( ply.PS2_Slots ) do
		if v.itemId == item.id then
			return true
		end
	end
	
	return false
end
