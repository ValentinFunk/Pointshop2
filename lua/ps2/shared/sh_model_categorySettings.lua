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

Pointshop2.ItemMapping = class( "Pointshop2.ItemMapping" )
local ItemMapping = Pointshop2.ItemMapping 

ItemMapping.static.DB = "Pointshop2"

ItemMapping.static.model = {
	tableName = "ps2_itemmapping",
	fields = {
		categoryId = "optKey",
		itemClass = "string"
	}
}

ItemMapping:include( DatabaseModel )
