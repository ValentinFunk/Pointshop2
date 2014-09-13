function Pointshop2Controller:initServer( )
	return Pointshop2.Server.findByServerHash( Pointshop2.CalculateServerHash( ) )
	:Then( function( server )
		if not server then
			server = Pointshop2.Server:new( )
			server.ip = GetConVarString( "ip" )
			server.port = GetConVarNumber( "port" )
			server.serverHash = Pointshop2.CalculateServerHash( )
			server.name = GetConVarString( "hostname" )
			return server:save( )
		end 
		return server
	end )
	:Then( function( server )
		Pointshop2.GetModule( "Pointshop 2" ).Settings.Shared.InternalSettings.ServerId = server.id
		KLogf( 4, "[Pointshop 2] Loaded server, this is %s, id %i", server.name, server.id )
		server.name = GetConVarString( "hostname" )
		return server:save()
	end )
end

function Pointshop2Controller:adminGetServers( )
	return Pointshop2.Server.getAll()
end

function Pointshop2Controller:removeServer( ply, serverId )
	if serverId == Pointshop2.GetSetting( "Pointshop 2", "InternalSettings.ServerId" ) then
		return Promise.Reject( "You cannot remove the server you're playing on!" )
	end
	return Pointshop2.Server.removeWhere{ id = serverId }
end

function Pointshop2Controller:migrateServer( ply, serverId )
	return Pointshop2.Server.findById( serverId )
	:Then( function( server )
		if not server then
			return Promise.Reject( "Server with id " .. serverId .. " not found!" )
		end
		
		server.ip = GetConVarString( "ip" )
		server.port = GetConVarNumber( "port" )
		server.serverHash = Pointshop2.CalculateServerHash( )
		server.name = GetConVarString( "hostname" )
		return server:save( )
	end )
	:Then( function( server )
		return self:initServer( )
	end )
	:Then( function( )
		return Pointshop2Controller:getInstance( ):reloadSettings( false )
	end )
end