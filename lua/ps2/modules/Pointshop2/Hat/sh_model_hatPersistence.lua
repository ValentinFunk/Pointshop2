Pointshop2.HatPersistence = class( "Pointshop2.HatPersistence" )
local HatPersistence = Pointshop2.HatPersistence 

HatPersistence.static.DB = "Pointshop2"

HatPersistence.static.ALL_MODELS = "BaseItem"
HatPersistence.static.ALL_CSS_MODELS = "CS:S Models"

HatPersistence.static.model = {
	tableName = "ps2_HatPersistence",
	fields = {
		itemPersistenceId = "int",
		iconMaterial = "string",
		useMaterialIcon = "bool"
	},
	belongsTo = {
		ItemPersistence = {
			class = "Pointshop2.ItemPersistence",
			foreignKey = "itemPersistenceId"
		}
	},
	hasMany = {
		OutfitHatPersistenceMapping = {
			class = "Pointshop2.OutfitHatPersistenceMapping",
			foreignKey = "hatPersistenceId"
		}
	}
}

HatPersistence:include( DatabaseModel )

function HatPersistence.static.createFromSaveTable( saveTable )
	return Pointshop2.ItemPersistence.createFromSaveTable( saveTable )
	:Then( function( itemPersistence )
		--Save Hat persistence
		local hat = HatPersistence:new( )
		hat.itemPersistenceId = itemPersistence.id
		hat.outfitId = saveTable.outfitId
		hat.iconMaterial = saveTable.iconMaterial or ""
		print( "UseMaterialIcon: ", saveTable.useMaterialIcon, type( saveTable.useMaterialIcon ) )
		hat.useMaterialIcon = saveTable.useMaterialIcon
		return hat:save( )
	end )
	:Then( function( hat )
		local outfitPromises = {}
		for model, outfitTable in pairs( saveTable.outfits ) do
			--Save Outfit
			local outfit = Pointshop2.StoredOutfit:new( )
			outfit.outfitData = outfitTable
			local promise = outfit:save( )
			:Then( function( outfit )
				--Save Model -> Outfit mapping
				local mapping = Pointshop2.OutfitHatPersistenceMapping:new( )
				mapping.hatPersistenceId = hat.id
				mapping.outfitId = outfit.id
				mapping.model = model
				return mapping:save( )
			end )
			table.insert( outfitPromises, promise )
		end
		return WhenAllFinished( outfitPromises )
	end )
end