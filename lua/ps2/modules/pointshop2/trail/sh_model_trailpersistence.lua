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
			foreignKey = "itemPersistenceId",
			onDelete = "CASCADE"
		}
	}
}

TrailPersistence:include( DatabaseModel )
TrailPersistence:include( Pointshop2.EasyExport )


function TrailPersistence.static.createOrUpdateFromSaveTable( saveTable, doUpdate )
	return Pointshop2.ItemPersistence.createOrUpdateFromSaveTable( saveTable, doUpdate )
	:Then( function( itemPersistence )
		if doUpdate then
			return TrailPersistence.findByItemPersistenceId( itemPersistence.id )
		else
			local trail = TrailPersistence:new( )
			trail.itemPersistenceId = itemPersistence.id
			return trail
		end
	end )
	:Then( function( trail )
		trail.material = saveTable.material
		return trail:save( )
	end )
end