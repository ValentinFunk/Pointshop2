Pointshop2.HatPersistence = class( "Pointshop2.HatPersistence" )
local HatPersistence = Pointshop2.HatPersistence 

HatPersistence.static.DB = "Pointshop2"

HatPersistence.static.model = {
	tableName = "ps2_HatPersistence",
	fields = {
		itemPersistenceId = "int",
		outfitId = "int",
		iconMaterial = "string",
		useMaterialIcon = "bool"
	},
	belongsTo = {
		ItemPersistence = {
			class = "Pointshop2.ItemPersistence",
			foreignKey = "itemPersistenceId"
		}
	}
}

HatPersistence:include( DatabaseModel )

function HatPersistence.static.createFromSaveTable( saveTable )
	return Pointshop2.ItemPersistence.createFromSaveTable( saveTable )
	:Then( function( itemPersistence )
		local hat = HatPersistence:new( )
		hat.itemPersistenceId = itemPersistence.id
		hat.outfitId = saveTable.outfitId
		hat.iconMaterial = saveTable.iconMaterial or ""
		hat.useMaterialIcon = saveTable.useMaterialIcon 
		return hat:save( )
	end )
end