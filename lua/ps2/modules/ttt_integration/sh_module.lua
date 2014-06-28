local MODULE = {}

--Pointshop2 TTT integration
MODULE.Name = "TTT Integration"
MODULE.Author = "Kamshak"

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
		DelayReward = true,
		
		TraitorKillsInno = 100,
		TraitorKillsDetective = 150,
		
		DetectiveKillsTraitor = 200,
		DetectiveDnaBonus = 50,
		
		InnoKillsTraitor = 200,
	},
	RoundWin = {
		Innocent = 300,
		CleanRound = 100,
		InnocentAlive = 100,
		
		Traitor = 300,
		TraitorAlive = 50,
	},
	Detective = {
		DnaFound = 50,
	},
}
	
Pointshop2.RegisterModule( MODULE )