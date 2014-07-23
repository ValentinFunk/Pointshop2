Pointshop2.ItemMapping = class( "Pointshop2.ItemMapping" )
local ItemMapping = Pointshop2.ItemMapping 

ItemMapping.static.DB = "Pointshop2"

ItemMapping.static.model = {
	tableName = "ps2_itemmapping",
	fields = {
		categoryId = "int",
		itemClass = "string"
	},
	belongsTo = {
		Category = {
			class = "Pointshop2.Category",
			foreignKey = "categoryId",
			onDelete = "CASCADE"
		}
	}
}

ItemMapping:include( DatabaseModel )