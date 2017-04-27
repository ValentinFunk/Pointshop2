Pointshop2.ItemPersistence = class( "Pointshop2.ItemPersistence" )
local ItemPersistence = Pointshop2.ItemPersistence

ItemPersistence.static.DB = "Pointshop2"

ItemPersistence.static.model = {
	tableName = "ps2_itempersistence",
	fields = {
		baseClass = "string", --Controller
		price = "optKey", --INT NULL
		pricePremium = "optKey", --INT NULL
		ranks = "json",
		name = "string",
		uuid = "string",
		description = "text",
		createdAt = "createdTime",
		updatedAt = "updatedTime",
		servers = "luadata"
	}
}

ItemPersistence:include( DatabaseModel )

function ItemPersistence.static.createOrUpdateFromSaveTable( saveTable, doUpdate )
	local def = Deferred( )
	if doUpdate then
		ItemPersistence.findById( saveTable.persistenceId )
		:Done( function( persistence )
			def:Resolve( persistence )
		end )
		:Fail( function( errid, err )
			def:Reject( errid, err )
		end )
	else
		local instance = ItemPersistence:new( )
		instance.uuid = LibK.GetUUID()
		def:Resolve( instance )
	end

	return def:Then( function( instance )
		instance.price = saveTable.price
		instance.pricePremium = saveTable.pricePremium
		instance.ranks = {}
		instance.name = saveTable.name
		instance.baseClass = saveTable.baseClass
		instance.description = saveTable.description
		return instance:save( )
	end )
end

function ItemPersistence:generateInstanceExportTable( )
	local cleanTable = generateNetTable( self )
	cleanTable.id = nil
	cleanTable._classname = nil
	return cleanTable
end
