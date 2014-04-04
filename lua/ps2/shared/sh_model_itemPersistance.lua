Pointshop2.ItemPersistance = class( "Pointshop2.ItemPersistance" )
local ItemPersistance = Pointshop2.ItemPersistance 

ItemPersistance.static.DB = "Pointshop2"

ItemPersistance.static.model = {
	tableName = "ps2_itempersistance",
	fields = {
		baseClass = "string", --Controller
		price = "int",
		pricePremium = "int",
		ranks = "string",
		name = "string",
		description = "text",
		createdAt = "createdTime",
		updatedAt = "updatedTime",
	}
}

ItemPersistance:include( DatabaseModel )