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
		label = "Hat",
		base = "base_hat",
		icon = "pointshop2/fedora.png",
		creator = "DHatCreator"
	}
}

Pointshop2.RegisterModule( MODULE )