local MODULE = {}

--Pointshop2 ZS integration
MODULE.Name = "ZS Integration"
MODULE.Author = "Trips"
MODULE.RestrictGamemodes = { "zombiesurvival" } --Only load for ZS

MODULE.Blueprints = {}

MODULE.SettingButtons = {
	{
		label = "Point Rewards",
		icon = "pointshop2/hand129.png",
		control = "DZombiesurvivalConfigurator"
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

		ZombieKillsHuman = {
			value = 250,
			label = "Zombie kills Human",
			tooltip = "Points awarded to a Zombie when he kills a Human",
		},

		HeadcrabKillsHuman = {
			value = 250,
			label = "Headcrab kills Human",
			tooltip = "Points awarded to a Headcrab when he kills a Human",
		},

		BossKillsHuman = {
			value = 250,
			label = "Boss kills Human",
			tooltip = "Points awarded to a Boss when he kills a Human",
		},

		HumanKillsZombie = {
			value = 150,
			label = "Human kills Zombie",
			tooltip = "Points awarded to a Human when he kills a Zombie",
		},

		HumanKillsHeadcrab = {
			value = 150,
			label = "Human kills Headcrab",
			tooltip = "Points awarded to a Human when he kills a Headcrab"
		},

		HumanKillsBoss = {
			value = 150,
			label = "Human kills Boss",
			tooltip = "Points awarded to a Human when he kills a Boss",
		},

		HumanKillsCrow = {
			value = 50,
			label = "Human kills Crow",
			tooltip = "Points awarded to a Human when he kills a Crow",
		},
	},
	RoundWin = {
		info = {
			label = "Round Win Rewards"
		},
		Human = {
			value = 1000,
			label = "Humans win",
			tooltip = "Points awarded to every Human when they win the round"
		},

		LastHumanToDie = {
			value = 5,
			label = "Last human to be alive",
			tooltip = "Points awarded to the last surviving Human (every second)"
		},

		Zombie = {
			value = 100,
			label = "Zombies win",
			tooltip = "Points awarded to every Zombie when they kill all the Humans"
		},

	},
	Redeemed = {
		info = {
			label = "Redeeming Rewards"
		},
		Redeem = {
			value = 250,
			label = "Redeemed himself",
			tooltip = "Points awarded to a player for redeeming himself"
		},
	},
	Barricades = {
		info = {
			label = "Barricade Rewards"
		},
		RepairObject = {
			value = 5,
			label = "Human repairs object",
			tooltip = "Points awarded to a Human for repairing an object"
		},
	},
}

-- For Drops integration: Returns players that can get a drop once the round ends
function MODULE.GetPlayersForDrops( )
	local players = {}
	for k, v in pairs( player.GetAll( ) ) do
		if not v:GetNWBool("playerafk") then
			table.insert( players, v )
		end
	end
	return players
end

Pointshop2.RegisterModule( MODULE )
Pointshop2.NotifyGamemodeModuleLoaded( "zombiesurvival", MODULE )
