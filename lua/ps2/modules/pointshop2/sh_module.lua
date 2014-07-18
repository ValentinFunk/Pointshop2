local MODULE = {}

--Pointshop2 Basic Items
MODULE.Name = "Pointshop 2"
MODULE.Author = "Kamshak"

--This defines blueprints that players can use to create items.
--base is the name of the class that is used as a base
--creator is the name of the derma control that is used to create new items from the blueprint
MODULE.Blueprints = {
	{
		label = "Player Model",
		base = "base_playermodel",
		icon = "pointshop2/playermodel.png",
		creator = "DPlayerModelCreator"
	},
	{
		label = "Trail",
		base = "base_trail",
		icon = "pointshop2/winner2.png",
		creator = "DTrailCreator"
	},
	{
		label = "Accessory/Hat",
		base = "base_hat",
		icon = "pointshop2/fedora.png",
		creator = "DHatCreator"
	}
}

MODULE.SettingButtons = {
	{
		label = "Basic Settings",
		icon = "pointshop2/small43.png",
		control = "DPointshop2Configurator"
	}
}

MODULE.Settings = {}
MODULE.Settings.Shared = {
	BasicSettings = {
		info = {
			label = "General Settings"
		},
		SellRatio = {
			tooltip = "The price is multiplied with this to calculate the sell price",
			label = "Item sell repay ratio", 
			value = 0.75
		},
		ServerId = {
			tooltip = "Generated from the ip and hostname, if you switch hosts/ips save this and change it back on the new host.",
			label = "Server Id",
			value = util.CRC( GetConVarString( "ip" ) .. GetConVarString( "port" ) ),
		}
	}
}

MODULE.Settings.Server = {
	BasicSettings = {
		info = {
			label = "Player Defaults"
		},
		DefaultSlots = {
			value = 40,
			label = "Starting inventory slots",
			tooltip = "Size of the inventory when a player first joins",
		},
		["DefaultWallet.Points"] = {
			label = "Starting points",
			value = 1000
		},
		["DefaultWallet.PremiumPoints"] = {
			label = "Starting donator points",
			value = 1000
		},
	},
	GUISettings = {
		info = {
			label = "GUI Settings",
		},
		ShopKey = {
			value = "F3",
			possibleValues = {
				"F1",
				"F2",
				"F3",
				"F4",
			},
			type = "option",
			label = "Shop Key",
			tooltip = "Key used to open the shop"
		}
	}
}

Pointshop2.RegisterModule( MODULE )