local MODULE = Pointshop2.GetModule( "TTT Integration" )
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