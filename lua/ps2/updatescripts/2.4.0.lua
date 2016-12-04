/*
	This update script is ran when pointshop2 is updated from a version before the update system was in place.
	It is also run on a clean install so some checks are required.
*/

local DB

local function addYearField( )
	return DB.FieldExistsInTable( "ps2_adventcalendaruses", "year" )
	:Then( function( exists )
		if not exists then
			return DB.DoQuery( "ALTER TABLE `ps2_adventcalendaruses` ADD `year` INT NULL" )
        :Then(function()
          return DB.DoQuery( "UPDATE `ps2_adventcalendaruses` SET `year` = 2015 WHERE 1")
        end)
		end
	end )
	:Then( function( )
		print( "\t Added column year to ps2_adventcalendaruses" )
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
			return DB.DoQuery( "SHOW TABLES LIKE 'ps2_adventcalendaruses'" )
			:Then( function( exists )
				return exists
			end )
		else
			return DB.DoQuery( "SELECT name FROM sqlite_master WHERE type='table' AND name='ps2_adventcalendaruses'" )
			:Then( function( result )
				local exists = result and result[1] and result[1].name
				return exists
			end )
		end
	end )
	:Then( function( shouldUpdate )
		KLogf( 2, "[INFO] We are on %s and %s to update", DB.CONNECTED_TO_MYSQL and "MySQL" or "SQLite", shouldUpdate and "need" or "not need" )
		if shouldUpdate then
			return addYearField()
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
		KLogf( 2, "[ERROR] Error during update: %i, %s.", errid, err )
		def:Reject( errid, err )
	end )
end )

DB = LibK.getDatabaseConnection( LibK.SQL, "Update" )

return def:Promise( )
