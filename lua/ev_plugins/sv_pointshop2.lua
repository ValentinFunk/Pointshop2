local PLUGIN = {}
PLUGIN.Title = "Pointshop2 Management Access"
PLUGIN.Description = "Allows rank access to the Management section of Pointshop 2"
PLUGIN.Author = "Kamshak"
PLUGIN.Privileges = { "pointshop2 manageitems",
	"pointshop2 createitems",
	"pointshop2 manageusers",
	"pointshop2 managemodules",
	"pointshop2 exportimport",
	"pointshop2 reset"
}

evolve:RegisterPlugin( PLUGIN )