Pointshop2.TexthatPersistence = class( "Pointshop2.TexthatPersistence" )
local TexthatPersistence = Pointshop2.TexthatPersistence

TexthatPersistence.static.DB = "Pointshop2"

TexthatPersistence.static.model = {
	tableName = "ps2_texthatpersistence",
	fields = {
		itemPersistenceId = "int",
		color = "luadata",
		outlineColor = "luadata",
		rainbow = "bool",
		size = "luadata" --Float :S
	},
	belongsTo = {
		ItemPersistence = {
			class = "Pointshop2.ItemPersistence",
			foreignKey = "itemPersistenceId",
			onDelete = "CASCADE",
		}
	}
}

TexthatPersistence:include( DatabaseModel )
TexthatPersistence:include( Pointshop2.EasyExport )

function TexthatPersistence.static.createOrUpdateFromSaveTable( saveTable, doUpdate )
	return Pointshop2.ItemPersistence.createOrUpdateFromSaveTable( saveTable, doUpdate )
	:Then( function( itemPersistence )
		if doUpdate then
			return TexthatPersistence.findByItemPersistenceId( itemPersistence.id )
		else
			local texthatPersistence = TexthatPersistence:new( )
			texthatPersistence.itemPersistenceId = itemPersistence.id
			return texthatPersistence
		end
	end )
	:Then( function( texthatPersistence )
		texthatPersistence.color = saveTable.color
		texthatPersistence.outlineColor = saveTable.outlineColor
		texthatPersistence.rainbow = saveTable.rainbow
		texthatPersistence.size = saveTable.size
		return texthatPersistence:save( )
	end )
end
