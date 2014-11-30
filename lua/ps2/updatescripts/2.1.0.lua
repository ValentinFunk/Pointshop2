/*
	This update script is ran when pointshop2 is updated from a version before the update system was in place.
	It is also run on a clean install so some checks are required.
*/

local DB

local function addSettingsField( )
	return DB.DoQuery( "ALTER TABLE `ps2_settings` ADD `serverId` INT NULL" )
	:Done( function( )
		print( "\t Added column serverId to settings" )
	end )
end

local function addServersField( )
	return DB.DoQuery( "ALTER TABLE `ps2_itempersistence` ADD `servers` TEXT" )
	:Done( function( )
		print( "\t Added column servers to persistence" )
	end )
end

local def = Deferred( )
hook.Add( "LibK_DatabaseInitialized", "Initialized", function( dbObj, name )
	DB = dbObj
	
	if name != "Update" then
		return
	end
	
	Promise.Resolve( )
	:Then( function( )
		if DB.CONNECTED_TO_MYSQL then
			return DB.DoQuery( "SHOW TABLES LIKE 'ps2_itempersistence'" )
			:Then( function( exists )
				return not exists
			end )
		else
			return DB.DoQuery( "SELECT name FROM sqlite_master WHERE type='table' AND name='ps2_itempersistence'" )
			:Then( function( result )
				local exists = result and result[1] and result[1].name
				return not exists
			end )
		end
	end )
	:Then( function( doUpdate )
		if doUpdate then
			return WhenAllFinished{ addSettingsField(), addServersField() }
			:Fail( function( errid, err )
				KLogf( 3, "[WARN] Error during update: %i, %s. Ignore this if you run multiple servers on a single database.", errid, err )
				def:Resolve( )
			end )
		else
			return Promise.Resolve( )
		end
	end )
	:Done( function( )
		def:Resolve( )
	end )
	:Fail( function( errid, err )
		KLogf( 3, "[WARN] Error during update: %i, %s. Ignore this if you run multiple servers on a single database.", errid, err )
		def:Reject( errid, err )
	end )
end )

DB = LibK.getDatabaseConnection( LibK.SQL, "Update" )

return def:Promise( )