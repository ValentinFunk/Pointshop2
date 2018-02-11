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
		noModal = true,
		creator = "DHatCreator"
	},
}

MODULE.SettingButtons = {
	{
		label = "Basic Settings",
		icon = "pointshop2/small43.png",
		control = "DPointshop2Configurator"
	},
	{
		label = "Reset All",
		icon = "pointshop2/restart1.png",
		control = "DPointshopReset"
	},
	{
		label = "Install Default Items",
		icon = "pointshop2/download7.png",
		onClick = function( )
			Promise.Resolve()
			:Then(function()
				if Pointshop2.GetItemClassByPrintName( "Hatchet" ) then
					local def = Deferred()
					Derma_Query( "It looks as if you have already installed the default items. If you install them again, you might get duplicates and a bit of a mess. Do you want to proceed?", "Warning",
						"Ok, do it", function( )
							def:Resolve()
						end,
						"No", function( )
							def:Reject()
						end )
					return def:Promise()
				end
			end)
			:Then(function()
				Pointshop2View:getInstance( ):installDefaults( )
				Derma_Message( "We're installing the default items for you. Please give us about a minute, your shop will update automatically once the items are installed", "Information" )
			end)
		end
	},
	{
		label = "Repair Database",
		icon = "pointshop2/wizard_l.png",
		onClick = function( )
			Derma_Query( "This will attempt to repair a broken database, then switch the map. If you have strange errors you can try this. Backup your database as you could lose data or problems could get worse. Open a support ticket in this case.", "Warning",
			"Ok, do it", function( )
				Pointshop2View:getInstance( ):fixDatabase( )
			end,
			"No", function( )
			end )
		end
	},
	{
		label = "Points over Time",
		icon = "pointshop2/person25.png",
		control = "DPointsOverTimeConfigurator"
	}
}

--Resolve Servers that Pointshop 2 runs on to shared. Only transmit id and name
--to avoid exposing the com secret
MODULE.Resolve = function( )
	return Pointshop2.Server.getAll( )
	:Then( function( servers )
		MODULE.Settings.Shared.InternalSettings.Servers = {
			type = "table",
			value = {}
		}
		for k, server in pairs( servers ) do
			table.insert( MODULE.Settings.Shared.InternalSettings.Servers.value, {
				id = server.id,
				name = server.name
			} )
		end
	end )
end

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
		SendPointsEnabled = {
			label = "Allow players to send points",
			tooltip = "This can be used to disable the possibility to send points to other players",
			value = true
		},
		LimitPACAccess = {
			value = true,
			label = "Limit PAC access",
			tooltip = "Restricts the use of the PAC editor to players/groups with the \"pointshop2 usepac\" permission."
		},
	},
	InternalSettings = {
		info = {
			isManualSetting = true,
			noDbSetting = true --Never save these to DB
		},
		-- Server's unique id, fetched from the database
		ServerId = {
			value = -1,
		},
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
		PotAfkCheck = {
			label = "Disable Points over Time for AFK Players",
			tooltip = "When turned on player movements are checked to prevent AFK players from getting points over time.",
			value = true
		},
	},
	AdvancedSettings = {
		info = {
			label = "Technical Settings"
		},
		ShouldBlock = {
			value = true,
			label = "Blocking Transactions",
			tooltip = "When turned on trades some performance for safety against data loss on gmod or sql server crashes"
		},
		BroadcastWallets = {
			value = false,
			label = "Broadcast Wallets",
			tooltip = "Causes pointshop 2 to network all wallets across the server. This makes it possible to show points on the scoreboard"
		}
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
				"None"
			},
			type = "option",
			label = "Shop Key",
			tooltip = "Key used to open the shop"
		},
		ShopChat = {
			value = "!shop",
			possibleValues = {
				"!shop",
				"!ps",
				"!ps2",
				"!pointshop",
				"!pointshop2",
				"!points"
			},
			type = "option",
			label = "Shop Chat Command",
			tooltip = "Chat command used to open the shop"
		}
	},
	PointsOverTime = {
		info = {
			isManualSetting = true, --Ignored by AutoAddSettingsTable
		},
		Delay = 10,
		Points = 100,
		ForceEnable = false,
		GroupMultipliers = {
			type = "table",
			value = { }
		}
	}
}

Pointshop2.RegisterModule( MODULE )
