util.AddNetworkString( "RequestServerTrails" )

net.Receive( "RequestServerTrails", function( len, ply )
	if not PermissionInterface.query( ply, "pointshop2 createitems" ) then
		KLogf( 3, "Player %s wanted to request server trails but is not allowed to creat items!", ply:Nick( ) )
		return
	end
	
	local files, folders = file.Find( "materials/trails/*", "GAME" )
	net.Start( "RequestServerTrails" )
		net.WriteTable( files )
	net.Send( ply )
end )