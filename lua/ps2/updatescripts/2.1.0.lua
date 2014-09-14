/*
	This update script is ran when pointshop2 is updated from a version before the update system was in place.
	It is also run on a clean install so some checks are required.
*/

local DB = LibK.getDatabaseConnection( LibK.SQL, "Update" )

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
	if name != "Update" then
		return
	end
	
	DB.DoQuery( "SHOW TABLES LIKE 'ps2_itempersistence'" )
	:Then( function( result )
		if not result then
			return Promise.Resolve()
		end
		return WhenAllFinished{ addSettingsField(), addServersField() }
	end )
	:Done( function( )
		def:Resolve( )
	end )
	:Fail( function( errid, err )
		def:Reject( errid, err )
	end )
end )

return def:Promise( )