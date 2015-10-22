local MODULE = {}

--Pointshop2 The Hidden integration
MODULE.Name = "Hidden Integration"
MODULE.Author = "Kamshak"
MODULE.RestrictGamemodes = { "thehidden" } --Only load for Hidden

MODULE.Blueprints = {}

MODULE.SettingButtons = {
	{
		label = "Reward Settings",
		icon = "pointshop2/small43.png",
		control = "DTheHiddenConfigurator"
	},
}

MODULE.Settings = {}

--These are sent to the client on join
MODULE.Settings.Shared = { }

--These are not sent
MODULE.Settings.Server = {
	PointsOverTime = {
		info = {
			label = "Survival Points over Time"
		},

		Enable = {
			value = true,
			label = "Enable",
			tooltip = "Gives players that are not The Hidden survival points over time.",
		},

		Points = {
			value = 20,
			label = "Points",
			tooltip = "Points awarded for staying alive",
		},

		Delay = {
			value = 1,
			label = "Interval in minutes",
			tooltip = "Interval in which points are given",
		},
	},
	Rewards = {
		info = {
			label = "Rewards"
		},

		HiddenKilled = {
			value = 500,
			label = "Points given for killing the Hidden",
			tooltip = "Points awarded to the player when killing the Hidden"
		},

		HiddenPointsPerHP = {
			value = 5,
			label = "Hidden assist bonus",
			tooltip = "Points given per Damage done to the Hidden (excludes Killer of the Hidden)"
		},

		HumanKilled = {
			value = 100,
			label = "Hidden kills human",
			tooltip = "Points given to The Hidden when killing a human"
		},

		HumansWin = {
			value = 200,
			label = "I.R.I.S. Wins",
			tooltip = "Points given to each player when humans win a round"
		},

		HiddenWins = {
			value = 500,
			label = "Hidden wins",
			tooltip = "Points given to The Hidden when winning a round"
		}
	},
}

function MODULE:GetPlayersForDrops( )
	return player.GetAll( )
end

Pointshop2.RegisterModule( MODULE )
Pointshop2.NotifyGamemodeModuleLoaded( "thehidden", MODULE )
