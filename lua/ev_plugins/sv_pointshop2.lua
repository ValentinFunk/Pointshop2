local PLUGIN = {}
PLUGIN.Title = "Pointshop2 Management Access"
PLUGIN.Description = "Allows rank access to the Management section of Pointshop 2"
PLUGIN.Author = "Kamshak"
PLUGIN.Privileges = { "pointshop2 manageitems",
	"pointshop2 createitems",
	"pointshop2 manageusers",
	"pointshop2 managemodules",
	"pointshop2 exportimport",
	"pointshop2 reset",
	"pointshop2 usepac"
}
PLUGIN.ChatCommand = "ps2_addpoints"
PLUGIN.Usage = "steamid currency amount"

function PLUGIN:Call( ply, args )
	if not ply:EV_HasPrivilege( "pointshop2 manageusers" ) then
		evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
	end
	
	Pointshop2Controller:getInstance( ):addPointsBySteamId( steamId, currencyType, amount )
	:Fail( function( errid, err )
		local errString = Format( "[Pointshop 2] ERROR: Couldn't give %i %s to %s, %i - %s", amount, currencyType, steamId, errid, err )
		KLog( 2, errString )
		evolve:Notify( ply, evolve.colors.red, errString )
	end )
	:Done( function( )
		local succString = Format( "[Pointshop 2] %s gave %i %s to %s", calling_ply:Nick( ), amount, currencyType, steamId )
		KLog( 4, succString )
		evolve:Notify( ply, evolve.colors.blue, succString )
	end )
end

evolve:RegisterPlugin( PLUGIN )