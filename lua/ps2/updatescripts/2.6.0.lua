/*
	This update script is ran when pointshop2 is updated from a version before the update system was in place.
	It is also run on a clean install so some checks are required.
*/
local DB = LibK.getDatabaseConnection( LibK.SQL, "Update" )

local function addYearField( )
	return DB.FieldExistsInTable( "ps2_adventcalendaruses", "year" )
	:Then( function( exists )
		if not exists then
			return DB.DoQuery( "ALTER TABLE `ps2_adventcalendaruses` ADD `year` INT NULL" )
			:Then(function()
				return DB.DoQuery( "UPDATE `ps2_adventcalendaruses` SET `year` = 2015 WHERE 1" )
			end)
			:Then(function()
				return DB.DoQuery( 'UPDATE ps2_settings SET plugin="Daily Rewards / Advent Calendar" WHERE plugin="Advent Calendar"' )
			end )
		end
	end )
	:Then( function( )
		print( "\t Added column year to ps2_adventcalendaruses" )
	end )
end

return DB.ConnectionPromise
	:Then( function( )
		return DB.TableExists('ps2_adventcalendaruses')
	end )
	:Then( function( tableExists )
		if tableExists then
			return DB.FieldExistsInTable( "ps2_adventcalendaruses", "year" ):Then(function (exists)
				return not exists
			end)
		end
		return false
	end )
	:Then( function( shouldUpdate )
		KLogf( 2, "[INFO] We are on %s and %s to update", DB.CONNECTED_TO_MYSQL and "MySQL" or "SQLite", shouldUpdate and "need" or "not need" )
		if shouldUpdate then
			return addYearField()
		end
	end )
	:Then( function() end, function( errid, err )
		KLogf( 2, "[ERROR] Error during update: %i, %s.", errid, err )
		return Promise.Reject( errid, err )
	end )