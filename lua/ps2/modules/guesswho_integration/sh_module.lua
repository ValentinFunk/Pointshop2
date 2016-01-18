local MODULE = {}

--Pointshop2 Guess Who very basic integration. Only hides visuals on seekers.
MODULE.Name = "Guess Who Integration"
MODULE.Author = "Kamshak"
MODULE.RestrictGamemodes = { "guesswho" } --Only load for Guess Who

MODULE.Blueprints = {}

MODULE.SettingButtons = {}

MODULE.Settings = {}

--These are sent to the client on join
MODULE.Settings.Shared = { }

--These are not sent
MODULE.Settings.Server = { }

-- For Drops integration: Returns players that can get a drop once the round ends
function MODULE.GetPlayersForDrops( )
	local players = {}
	for k, v in pairs( player.GetAll( ) ) do
		if v:Team() != TEAM_SPECTATOR then
			table.insert( players, v )
		end
	end
	return players
end

Pointshop2.RegisterModule( MODULE )
--Pointshop2.NotifyGamemodeModuleLoaded( "prop_hunt", MODULE )
