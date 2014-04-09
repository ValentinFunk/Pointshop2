Pointshop2.ItemPersistence = class( "Pointshop2.ItemPersistence" )
local ItemPersistence = Pointshop2.ItemPersistence 

ItemPersistence.static.DB = "Pointshop2"

ItemPersistence.static.model = {
	tableName = "ps2_itempersistence",
	fields = {
		baseClass = "string", --Controller
		price = "optKey", --INT NULL
		pricePremium = "optKey", --INT NULL
		ranks = "table",
		name = "string",
		description = "text",
		createdAt = "createdTime",
		updatedAt = "updatedTime",
	}
}

ItemPersistence:include( DatabaseModel )

function ItemPersistence.static.createFromSaveTable( saveTable )
	local instance = ItemPersistence:new( )
	instance.price = saveTable.price
	instance.pricePremium = saveTable.pricePremium
	instance.ranks = ""
	instance.name = saveTable.name
	instance.baseClass = saveTable.baseClass
	instance.description = saveTable.description
	return instance:save( )
end