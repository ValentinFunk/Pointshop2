function Pointshop2Controller:initServer( )
	return Pointshop2.Server.findByServerHash( Pointshop2.CalculateServerHash( ) )
	:Then( function( server )
		if not server then
			server = Pointshop2.Server:new( )
			server.ip = GetConVarString( "ip" )
			server.port = GetConVarString( "port" )
			server.serverHash = Pointshop2.CalculateServerHash( )
			server.name = GetConVarString( "hostname" )
			return server:save( )
		end 
		return server
	end )
	:Then( function( server )
		Pointshop2.GetModule( "Pointshop 2" ).Settings.Shared.InternalSettings.ServerId = server.id
		KLogf( 4, "[Pointshop 2] Loaded server, this is %s, id %i", server.name, server.id )
	end )
end