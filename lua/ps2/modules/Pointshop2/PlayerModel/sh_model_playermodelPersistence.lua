Pointshop2.PlayermodelPersistence = class( "Pointshop2.PlayermodelPersistence" )
local PlayermodelPersistence = Pointshop2.PlayermodelPersistence 

PlayermodelPersistence.static.DB = "Pointshop2"

PlayermodelPersistence.static.model = {
	tableName = "ps2_playermodelpersistence",
	fields = {
		itemPersistenceId = "int",
		model = "string",
		skin = "int",
		bodygroups = "string"
	},
	belongsTo = {
		ItemPersistence = {
			class = "Pointshop2.ItemPersistence",
			foreignKey = "itemPersistenceId"
		}
	}
}

PlayermodelPersistence:include( DatabaseModel )

function PlayermodelPersistence.static.createFromSaveTable( saveTable )
	return Pointshop2.ItemPersistence.createFromSaveTable( saveTable )
	:Then( function( itemPersistence )
		local playermodel = PlayermodelPersistence:new( )
		playermodel.itemPersistenceId = itemPersistence.id
		playermodel.model = saveTable.model
		playermodel.bodygroups = saveTable.bodygroups
		playermodel.skin = saveTable.skin
		return playermodel:save( )
	end )
end