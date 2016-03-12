function Pointshop2Controller:initServer( )
	return Pointshop2.Server.findByServerHash( Pointshop2.CalculateServerHash( ) )
	:Then( function( server )
		if not server then
			server = Pointshop2.Server:new( )
			server:setToCurrentServer( )
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
	return WhenAllFinished{
		Pointshop2.ItemPersistence.getAll( ),
		Pointshop2.StoredSetting.removeWhere{ serverId = serverId },
		Pointshop2.Server.removeWhere{ id = serverId },
	}
	:Then( function( itemPersistences )
		--Make sure that there are no removed servers in the restriction lists
		local promises = {}
		for k, persistence in pairs( itemPersistences ) do
			local changed = false
			for k, v in pairs( persistence.servers or {} ) do
				if v == serverId then
					persistence.servers[k] = nil
					changed = true
					break
				end
			end
			if changed then
				table.insert( promises, persistence:save( ) )
			end
		end
		return WhenAllFinished( promises )
	end )
	:Then( function( )
		return self:moduleItemsChanged( )
	end )
end

function Pointshop2Controller:migrateServer( ply, serverId )
	return Pointshop2.Server.findById( serverId )
	:Then( function( server )
		if not server then
			return Promise.Reject( "Server with id " .. serverId .. " not found!" )
		end

		server:setToCurrentServer( )
		return server:save( )
	end )
	:Then( function( server )
		return self:initServer( )
	end )
	:Then( function( )
		return Pointshop2Controller:getInstance( ):reloadSettings( false )
	end )
end

function Pointshop2Controller:updateServerRestrictions( ply, itemClassNames, serverIds )
	local saveTbl = {}
	for k, v in pairs( itemClassNames ) do
		saveTbl[k]= tonumber(v)
	end
	local saveStr = table.concat( saveTbl, "," )

	return Pointshop2.ItemPersistence.getDbEntries( "WHERE id IN (" .. saveStr .. ")" )
	:Then( function( itemPersistences )
		local promises = {}
		for k, itemClassName in pairs( itemClassNames ) do
			local persistence
			for _, v in pairs( itemPersistences ) do
				if tonumber( v.id ) == tonumber( itemClassName ) then
					persistence = v
				end
			end
			if not persistence then
				return Promise.Reject( "Invalid Item Class " .. itemClassName )
			end
			persistence.servers = serverIds
			table.insert( promises, persistence:save( ) )
		end
		--Could optimize this to single query but cba
		return WhenAllFinished( promises )
	end )
	:Then( function( )
		return self:moduleItemsChanged( )
	end )
end
