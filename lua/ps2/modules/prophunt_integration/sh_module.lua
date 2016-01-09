local MODULE = {}

--Pointshop2 PH integration
MODULE.Name = "Prop Hunt Integration"
MODULE.Author = "Kamshak"
MODULE.RestrictGamemodes = { "prop_hunt" } --Only load for TTT

MODULE.Blueprints = {}

MODULE.SettingButtons = {
	{
		label = "Point Rewards",
		icon = "pointshop2/hand129.png",
		control = "DPropHuntConfigurator"
	}
}

MODULE.Settings = {}

--These are sent to the client on join
MODULE.Settings.Shared = { }

--These are not sent
MODULE.Settings.Server = {
	Kills = {
		info = {
			label = "Kill Rewards"
		},

		HunterKillsProp = {
			value = 100,
			label = "Hunter kills Prop",
			tooltip = "Points a hunter gets when killing a prop",
		},
	},
	RoundWin = {
		info = {
			label = "Round Win Rewards"
		},

		MinimumPlayers = {
			value = 3,
			label = "Minimum Players",
			tooltip = "Minimum amount of players online for round awards to be given"
		},

		PropsWin = {
			value = 100,
			label = "Props Win: Points given",
			tooltip = "Points given to each prop when props win."
		},

		TimeJackpotPerPlayer = {
			value = 130,
			label = "Hunters Win: Time Jackpot per Player",
			tooltip = "This amount is multiplied with the amount of players to get the time jackpot. The time jackpot decreases with each minute that passed. When hunters win the time jackpot is distributed to the hunters."
		},

		AliveBonus = {
			value = 100,
			label = "Alive Bonus",
			tooltip = "Points given to props/hunters that are still alive at the end of a round."
		},
	}
}

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
Pointshop2.NotifyGamemodeModuleLoaded( "prop_hunt", MODULE )
