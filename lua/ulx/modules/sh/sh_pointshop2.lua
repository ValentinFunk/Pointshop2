if SERVER then
	ULib.ucl.registerAccess("pointshop2 manageitems", ULib.ACCESS_SUPERADMIN, "Permission to modify item categories", "Pointshop 2" )
	ULib.ucl.registerAccess("pointshop2 createitems", ULib.ACCESS_SUPERADMIN, "Permission to create new items", "Pointshop 2" )
	ULib.ucl.registerAccess("pointshop2 manageusers", ULib.ACCESS_SUPERADMIN, "Permission to manage users(give points, items)", "Pointshop 2" )
	ULib.ucl.registerAccess("pointshop2 managemodules", ULib.ACCESS_SUPERADMIN, "Permission to manage modules and use settings", "Pointshop 2" )
	ULib.ucl.registerAccess("pointshop2 exportimport", ULib.ACCESS_SUPERADMIN, "Permission to export/import items", "Pointshop 2" )
	ULib.ucl.registerAccess("pointshop2 manageservers", ULib.ACCESS_SUPERADMIN, "Permission to manage servers", "Pointshop 2" )
	ULib.ucl.registerAccess("pointshop2 reset", ULib.ACCESS_SUPERADMIN, "Permission to reset the shop", "Pointshop 2" )
	ULib.ucl.registerAccess("pointshop2 usepac", ULib.ACCESS_SUPERADMIN, "Permission to use the PAC editor", "Pointshop 2" )
end

local function addPointsBySteamid( calling_ply, steamId, currencyType, amount )
	Pointshop2Controller:getInstance( ):addPointsBySteamId( steamId, currencyType, amount )
	:Fail( function( errid, err )
		KLogf( 2, "[Pointshop 2] ERROR: Couldn't give %i %s to %s, %i - %s", amount, currencyType, steamId, errid, err )
	end )
	:Done( function( )
		ulx.fancyLogAdmin( calling_ply, true, "#A gave #i #s to #s", amount, currencyType, steamId )
		KLogf( 4, "[Pointshop 2] %s gave %i %s to %s", calling_ply:IsValid( ) and calling_ply:Nick( ) or "CONSOLE", amount, currencyType, steamId )
	end )
end
local giveItemCmd = ulx.command( "Pointshop 2", "ps2_addpoints", addPointsBySteamid, "!addpts" )
giveItemCmd:defaultAccess( ULib.ACCESS_SUPERADMIN )
giveItemCmd:addParam{ type=ULib.cmds.StringArg, hint = "Steam ID to give poins to" }
giveItemCmd:addParam{ type=ULib.cmds.StringArg, hint="Currency Type", completes = {"points", "premiumPoints" }, error="invalid currency \"%s\" specified", ULib.cmds.restrictToCompletes }
giveItemCmd:addParam{ type=ULib.cmds.NumArg, min=1, default=1, hint="Amount" }
giveItemCmd:help( "Give Pointshop 2 points to a player by SteamID" )