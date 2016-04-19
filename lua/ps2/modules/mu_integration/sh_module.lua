local MODULE = {}

MODULE.Name = "Murder Integration"
MODULE.Author = "Aragas (Pinkie Arg)"
MODULE.RestrictGamemodes = { "murder", "murder-ex" }

MODULE.Blueprints = { }

MODULE.SettingButtons = {
	{
		label = "Point Rewards",
		icon = "pointshop2/hand129.png",
		control = "DMurderConfigurator"
	}
}

MODULE.Settings = { }

MODULE.Settings.Shared = { }

MODULE.Settings.Server = {
	Kills = {
		info = {
			label = "Murdering rewards"
		},

		MurderKillsBystander = {
			value = 50,
			label = "Murderer killed a bystander",
			tooltip = "Reward for crime",
		},

		MurderKillsBystanderWithWeapon = {
			value = 100,
			label = "Murder killed Bystander with a weapon",
			tooltip = "Reward for crime",
		},

		BystanderKillsMurderer = {
			value = 200,
			label = "Bystander killed the Murderer",
			tooltip = "Reward for preventing the crime",
		},
		PickupLoot = {
				value = 25,
				label = "Picked up loot",
				tooltip = "Reward for picking up Loot"
		}
	},
	RoundWin = {
		info = {
			label = "Awards for winning the round"
		},
		Bystander = {
			value = 50,
			label = "Bystanders won",
			tooltip = "Points awarded to each Bystander for winning the round"
		},

		BystanderCleanRound = {
			value = 500,
			label = "Clean round",
			tooltip = "Not a single Bystander killed"
		},

		BystanderAlive = {
			value = 100,
			label = "Bystander survived",
			tooltip = "Bonus for each survived Bystander",
		},
	},
}

-- For Drops integration: Returns players that can get a drop once the round ends
function MODULE.GetPlayersForDrops( )
	local players = {}
	for k, v in pairs( player.GetAll( ) ) do
		if v.HasMoved then
			table.insert( players, v )
		end
	end
	return players
end

Pointshop2.RegisterModule(MODULE)

Pointshop2.NotifyGamemodeModuleLoaded("murder", MODULE)
Pointshop2.NotifyGamemodeModuleLoaded("murder-ex", MODULE)
