--Using GLib to allow LOADS of settings to be sent
local GLib = LibK.GLib

function Pointshop2Controller:loadSettings( )
	local moduleInitPromises = {}
	for k, mod in pairs( Pointshop2.Modules ) do
		table.insert( moduleInitPromises, Pointshop2.InitializeModuleSettings( mod ) )
	end

	return WhenAllFinished( moduleInitPromises )
	:Then( function( )
		local data = util.TableToJSON( { Pointshop2.Settings.Shared } )
		local resource = LibK.GLib.Resources.RegisterData( "Pointshop2", "settings", data )
		resource:GetCompressedData( ) --Force compression now
		KLogf( 4, "[Pointshop2] Settings package loaded, version " .. resource:GetVersionHash( ) )
	end )
end

function Pointshop2Controller:SendInitialSettingsPackage( ply )
	local resource = LibK.GLib.Resources.Resources["Pointshop2/settings"]
	if not resource then
		KLogf( 4, "[Pointshop2] Settings package not loaded yet, trying again later" )
	end

	Pointshop2.SettingsLoadedPromise:Done( function( resource )
		self:startView( "Pointshop2View", "loadSettings", ply, resource:GetVersionHash( ) )
	end )
end

GLib.Transfers.RegisterHandler( "Pointshop2.Settings", GLib.NullCallback )
GLib.Transfers.RegisterRequestHandler( "Pointshop2.Settings", function( userId, data )
	local inBuffer = GLib.StringInBuffer( data )
	local modName = inBuffer:String( )

	local ply
	for k, v in pairs( player.GetAll( ) ) do
		if GLib.GetPlayerId( v ) == userId then
			ply = v
			break
		end
	end

	if not PermissionInterface.query( ply, "pointshop2 managemodules" ) then
		KLogf( 3, "[Pointshop2] Rejecting settings transfer for %s, not allowed", userId )
		return false
	end

	local settings = table.Merge( Pointshop2.Settings.Server, Pointshop2.Settings.Shared )[modName]
	if not settings then
		KLogf( 3, "[Pointshop2] Rejecting settings transfer for %s, settings %s not found", userId, modName )
		return false
	end

	local outBuffer = GLib.StringOutBuffer( )
	outBuffer:LongString( util.TableToJSON( settings ) )
	return true, outBuffer:GetString( )
end )

GLib.Transfers.RegisterInitialPacketHandler( "Pointshop2.SettingsUpdate", function( userId, data )
	local ply
	for k, v in pairs( player.GetAll( ) ) do
		if GLib.GetPlayerId( v ) == userId then
			ply = v
			break
		end
	end

	if not PermissionInterface.query( ply, "pointshop2 managemodules" ) then
		KLogf( 3, "[Pointshop2] Rejecting settings update from %s, insufficient permissions", ply:Nick( ) )
		return false
	end

	return true
end )

/*
	An admin sends us new settings
*/
GLib.Transfers.RegisterHandler( "Pointshop2.SettingsUpdate", function( userId, data )
	local inBuffer = GLib.StringInBuffer( data )
	local modName = inBuffer:String( )
	local realm = inBuffer:String( )
	local serializedData = inBuffer:LongString( )
	local dontSendToClients = ( realm == "Server" )

	local ply
	for k, v in pairs( player.GetAll( ) ) do
		if GLib.GetPlayerId( v ) == userId then
			ply = v
			break
		end
	end

	local newSettings = util.JSONToTable( serializedData )
	Pointshop2.StoredSetting.findAllByPlugin( modName )
	:Then( function( stored )
		local promises = {}

		for settingPath, settingValue in pairs( newSettings ) do
			local needsUpdate, settingToUpdate
			for k, storedSetting in pairs( stored ) do
				if storedSetting.path == settingPath then
					--Need to compare them as serialized versions, might be tables or other data structures
					if util.TableToJSON( {settingValue} ) != util.TableToJSON( {storedSetting.value} ) then
						needsUpdate = true
					end
					settingToUpdate = storedSetting
				end
			end
			if settingToUpdate then
				if needsUpdate then
					--setting exists and needs to be updated
					settingToUpdate.value = settingValue
					table.insert( promises, settingToUpdate:save( ) )
				end
				continue --Setting already exists in the database
			end

			--Check if we need to skip this because it should not be saved to DB
			local pathRoot = string.Explode( ".", settingPath )[1]
			local mod = Pointshop2.GetModule( modName )
			local settingsMeta = mod.Settings.Shared[pathRoot] or mod.Settings.Server[pathRoot]
			if ( settingsMeta.info and settingsMeta.info.noDbSetting ) or settingsMeta.noDbSetting then
				continue
			end

			--Doesn't exist, create new:
			local storedSetting = Pointshop2.StoredSetting:new( )
			storedSetting.plugin = modName
			storedSetting.path = settingPath
			storedSetting.value = settingValue
			table.insert( promises, storedSetting:save( ) )
		end
		return WhenAllFinished( promises )
	end )
	:Then( function( )
		return Pointshop2Controller:getInstance( ):reloadSettings( dontSendToClients )
	end )
	-- Notify the client that requested the save if the server settings have been successfully saved
	:Then( function( )
		if dontSendToClients then
			Pointshop2Controller:getInstance( ):startView( "Pointshop2View", "serverSettingsSaved", ply, modName, false )
		end
	end, function( errid, err )
		if dontSendToClients then
			Pointshop2Controller:getInstance( ):startView( "Pointshop2View", "serverSettingsSaved", ply, modName, err )
		end
	end )
	:Done( function( )
		hook.Run( "PS2_OnSettingsUpdate" )
	end )
end )

function Pointshop2Controller:reloadSettings( dontSendToClients )
	return Pointshop2Controller:getInstance( ):loadSettings( ):Then( function( )
		if  dontSendToClients then
			return
		end

		for k, ply in pairs(player.GetAll()) do
			Pointshop2Controller:getInstance( ):SendInitialSettingsPackage( ply )
		end
	end )
end