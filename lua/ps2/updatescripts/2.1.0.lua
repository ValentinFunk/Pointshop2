/*
	This update script is ran when pointshop2 is updated from a version before the update system was in place.
	It is also run on a clean install so some checks are required.
*/

local DB = LibK.getDatabaseConnection( LibK.SQL, "Update" )

DB.DoQuery( "ALTER TABLE `ps2_settings` ADD `serverId` INT NULL" )
:Done( function( )
	print( "\t Added column" )
end )
:Fail( function( err )
	print( err )
end )