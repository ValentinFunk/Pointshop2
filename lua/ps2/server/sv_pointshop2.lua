LibK.addContentFolder( "materials/pointshop2" )
LibK.SetupDatabase( "Pointshop2", Pointshop2 )

function Pointshop2.ResetDatabase( )
	for k, v in pairs( Pointshop2 ) do
		if istable( v ) and v.dropTable then
			v.dropTable( )
			KLogf( 5, "Dropped %s", v.name )
		end
	end
end