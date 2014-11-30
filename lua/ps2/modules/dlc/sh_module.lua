local MODULE = {}

--Pointshop2 Basic Items
MODULE.Name = "Pointshop 2 DLC"
MODULE.Author = "Kamshak"

--This defines blueprints that players can use to create items.
--base is the name of the class that is used as a base
--creator is the name of the derma control that is used to create new items from the blueprint
MODULE.Blueprints = {}

MODULE.SettingButtons = {}


MODULE.Settings = { 
	Shared = {},
	Server = {}
}

Pointshop2.RegisterModule( MODULE )