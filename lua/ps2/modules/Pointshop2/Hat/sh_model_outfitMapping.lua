Pointshop2.OutfitHatPersistenceMapping = class( "Pointshop2.OutfitHatPersistenceMapping" )
local OutfitHatPersistenceMapping = Pointshop2.OutfitHatPersistenceMapping 

OutfitHatPersistenceMapping.static.DB = "Pointshop2"

OutfitHatPersistenceMapping.static.model = {
	tableName = "ps2_OutfitHatPersistenceMapping",
	fields = {
		hatPersistenceId = "int",
		outfitId = "int",
		model = "string", --can be a full model path or HatPersistence constants
	}
}

OutfitHatPersistenceMapping:include( DatabaseModel )