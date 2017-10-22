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

-- Update the base ps2_itempsersistences table ranks and reload the item class.
function Pointshop2Controller:updateServerRestrictions( ply, itemClassNames, serverIds )
	local saveTbl = {}
	for k, v in pairs( itemClassNames ) do
		saveTbl[k]= tonumber(v)
	end
	local saveStr = table.concat( saveTbl, "," )
  
	local dbEntries = Pointshop2.ItemPersistence.getDbEntries( "WHERE id IN (" .. saveStr .. ")" )
	:Then( function( itemPersistences )
		return Promise.Map( itemPersistences, function( persistence )
			-- Update the ranks
			persistence.servers = serverIds
			return persistence:save ()
		end )
	end )
	:Then( function( persistences )
		local persistenceIds = LibK._.map( persistences, function( p ) return tostring( p.id ) end )
		self:notifyItemsChanged( persistenceIds )
	end )
end
