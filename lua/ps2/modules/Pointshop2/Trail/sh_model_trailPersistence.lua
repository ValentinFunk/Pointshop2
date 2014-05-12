Pointshop2.TrailPersistence = class( "Pointshop2.TrailPersistence" )
local TrailPersistence = Pointshop2.TrailPersistence 

TrailPersistence.static.DB = "Pointshop2"

TrailPersistence.static.model = {
	tableName = "ps2_trailpersistence",
	fields = {
		itemPersistenceId = "int",
		material = "string"
	},
	belongsTo = {
		ItemPersistence = {
			class = "Pointshop2.ItemPersistence",
			foreignKey = "itemPersistenceId"
		}
	}
}

TrailPersistence:include( DatabaseModel )

function TrailPersistence.static.createFromSaveTable( saveTable )
	return Pointshop2.ItemPersistence.createFromSaveTable( saveTable )
	:Then( function( itemPersistence )
		local trail = TrailPersistence:new( )
		trail.itemPersistenceId = itemPersistence.id
		trail.material = saveTable.material
		return trail:save( )
	end )
end