Pointshop2.PlayermodelPersistence = class( "Pointshop2.PlayermodelPersistence" )
local PlayermodelPersistence = Pointshop2.PlayermodelPersistence 

PlayermodelPersistence.static.DB = "Pointshop2"

PlayermodelPersistence.static.model = {
	tableName = "ps2_playermodelpersistence",
	fields = {
		itemPersistenceId = "int",
		playerModel = "string",
		skin = "int",
		bodygroups = "string"
	},
	belongsTo = {
		ItemPersistence = {
			class = "Pointshop2.ItemPersistence",
			foreignKey = "itemPersistenceId",
			onDelete = "CASCADE",
		}
	}
}

PlayermodelPersistence:include( DatabaseModel )
PlayermodelPersistence:include( Pointshop2.EasyExport )

function PlayermodelPersistence.static.createOrUpdateFromSaveTable( saveTable, doUpdate )
	return Pointshop2.ItemPersistence.createOrUpdateFromSaveTable( saveTable, doUpdate )
	:Then( function( itemPersistence )
		if doUpdate then
			return PlayermodelPersistence.findByItemPersistenceId( itemPersistence.id )
		else
			local playermodelPersistence = PlayermodelPersistence:new( )
			playermodelPersistence.itemPersistenceId = itemPersistence.id
			return playermodelPersistence
		end
	end )
	:Then( function( playermodelPersistence )
		playermodelPersistence.playerModel = saveTable.playerModel
		playermodelPersistence.bodygroups = saveTable.bodygroups
		playermodelPersistence.skin = saveTable.skin
		return playermodelPersistence:save( )
	end )
end