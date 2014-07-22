Pointshop2.OutfitHatPersistenceMapping = class( "Pointshop2.OutfitHatPersistenceMapping" )
local OutfitHatPersistenceMapping = Pointshop2.OutfitHatPersistenceMapping 

OutfitHatPersistenceMapping.static.DB = "Pointshop2"

OutfitHatPersistenceMapping.static.model = {
	tableName = "ps2_OutfitHatPersistenceMapping",
	fields = {
		hatPersistenceId = "int",
		outfitId = "int",
		model = "string", --can be a full model path or HatPersistence constants
	},
	belongsTo = {
		HatPersistence = {
			class = "Pointshop2.HatPersistence",
			foreignKey = "hatPersistenceId",
			onDelete = "CASCADE",
		},
		Outfit = {
			class = "Pointshop2.StoredOutfit", 
			foreignKey = "outfitId",
			onDelete = "CASCADE"
		}
	}
}

OutfitHatPersistenceMapping:include( DatabaseModel )