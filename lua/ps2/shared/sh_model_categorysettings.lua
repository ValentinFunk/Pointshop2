Pointshop2.Category = class( "Pointshop2.Category" )
local Category = Pointshop2.Category

Category.static.DB = "Pointshop2"

Category.static.model = {
	tableName = "ps2_categories",
	fields = {
		parent = "optKey",
		label = "string",
		icon = "string"
	}
}

Category:include( DatabaseModel )
