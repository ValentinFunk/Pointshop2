/*
	This update script is ran when pointshop2 is updated from a version before the update system was in place.
	It is also run on a clean install so some checks are required.
*/
local DB = LibK.getDatabaseConnection( LibK.SQL, "Update" )

local function addSettingsField( )
	return DB.FieldExistsInTable( "ps2_settings", "serverId" )
	:Then( function( exists )
		if not exists then
			return DB.DoQuery( "ALTER TABLE `ps2_settings` ADD `serverId` INT NULL" )
		end
	end )
	:Then( function( )
		print( "\t Added column serverId to settings" )
	end )
end

local function addServersField( )
	return DB.FieldExistsInTable( "ps2_itempersistence", "servers" )
	:Then( function( exists )
		if not exists then
			DB.DoQuery( "ALTER TABLE `ps2_itempersistence` ADD `servers` TEXT" )
		end
	end )
	:Done( function( )
		print( "\t Added column servers to persistence" )
	end )
end

return DB.ConnectionPromise
:Then( function( )
	return DB.TableExists( 'ps2_itempersistence' )
end )
:Then( function( shouldUpdate )
	KLogf( 2, "[INFO] We are on %s and %s to update", DB.CONNECTED_TO_MYSQL and "MySQL" or "SQLite", shouldUpdate and "need" or "not need" )
	if shouldUpdate then
		return WhenAllFinished{ addSettingsField(), addServersField() }
	else
		return Promise.Resolve( )
	end
end )
:Then( function( )	end, function( errid, err )
	KLogf( 2, "[ERROR] Error during update: %i, %s.", errid, err )
	return Promise.Reject( errid, err )
end )