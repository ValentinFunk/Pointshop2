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