local MODULE = {}

--Pointshop2 TTT integration
MODULE.Name = "TTT Integration"
MODULE.Author = "Kamshak"
MODULE.RestrictGamemodes = { "terrortown" } --Only load for TTT

MODULE.Blueprints = {}

MODULE.SettingButtons = {
	{
		label = "Point Rewards",
		icon = "pointshop2/hand129.png",
		control = "DTerrortownConfigurator"
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
		
		DelayReward = {
			value = true,
			label = "Delay Rewards until round end",
			tooltip = "Use this to prevent players to meta-game using the kill notifications. Kill points are collected and awarded at round end.",
		},
		
		TraitorKillsInno = {
			value = 100,
			label = "Traitor kills Innocent",
			tooltip = "Points awarded to a traitor when he kills an innocent player",
		},
		
		TraitorKillsDetective = {
			value = 150, 
			label = "Traitor kills Detective",
			tooltip = "Points awarded to a traitor when he kills a detective",
		},
		
		DetectiveKillsTraitor = {
			value = 200,
			label = "Detective kills Traitor",
			tooltip = "Points awarded to a detective when he kills a traitor",
		},
		
		DetectiveDnaBonus = { 
			value = 50,
			label = "Detective DNA Bonus",
			tooltip = "Additional points awarded to a detective if he had DNA on a traitor he killed"
		},
		
		InnoKillsTraitor = { 
			value = 250,
			label = "Innocent kills Traitor",
			tooltip = "Points awarded to an innocent when he kills a traitor",
		},
	},
	RoundWin = {
		info = {
			label = "Round Win Rewards"
		},
		Innocent = {
			value = 300,
			label = "Innocents win",
			tooltip = "Points awarded to every innocent when they win the round"
		},
		
		CleanRound = { 
			value = 100,
			label = "Clean round bonus",
			tooltip = "Bonus given to players if they did not hurt a teammate (no karma loss)"
		},
		
		InnocentAlive = {
			value = 100,
			label = "Innocent alive bonus",
			tooltip = "Bonus given to innocents that are alive at the end of the round",
		},
		
		Traitor = {
			value = 300,
			label = "Traitors win",
			tooltip = "Points awarded to every traitor when they win the round"
		},
		
		TraitorAlive = {
			value = 100,
			label = "Traitor alive bonus",
			tooltip = "Bonus given to traitors if they are alive at the end of the round"
		}
	},
	Detective = {
		info = {
			label = "Detective Rewards" 
		},
		DnaFound = { 
			value = 50,
			label = "DNA Found",
			tooltip = "Points awarded to a detective upon collecting DNA"
		},
	},
}

-- For Drops integration: Returns players that can get a drop once the round ends
function MODULE.GetPlayersForDrops( )
	local players = {}
	for k, v in pairs( player.GetAll( ) ) do
		if v:ShouldScore() then
			table.insert( players, v )
		end
	end
	return players
end

Pointshop2.RegisterModule( MODULE )
Pointshop2.NotifyGamemodeModuleLoaded( "terrortown", MODULE )