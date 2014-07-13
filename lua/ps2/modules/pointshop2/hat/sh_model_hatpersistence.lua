Pointshop2.HatPersistence = class( "Pointshop2.HatPersistence" )
local HatPersistence = Pointshop2.HatPersistence 

HatPersistence.static.DB = "Pointshop2"

HatPersistence.static.ALL_MODELS = "BaseItem"
HatPersistence.static.ALL_CSS_MODELS = "CS:S Models"

HatPersistence.static.model = {
	tableName = "ps2_HatPersistence",
	fields = {
		itemPersistenceId = "int",
		iconInfo = "luadata",
		validSlots = "luadata"
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

--Removes all outfits and mappings for this HatPersistence from the database
function HatPersistence:removeOutfits( )
	return Pointshop2.OutfitHatPersistenceMapping.findAllByHatPersistenceId( self.id )
	:Then( function( mappings )
		local mappingIds = {}
		for k, v in pairs( mappings ) do
			table.insert( mappingIds, v.id )
		end
		
		local outfitIds = {}
		for k, v in pairs( mappings ) do
			if not table.HasValue( outfitIds ) then
				table.insert( outfitIds, v.outfitId )
			end
		end
		
		--Remove all persistence mappings
		local removeMappings = Pointshop2.OutfitHatPersistenceMapping.removeDbEntries( Format( "WHERE id IN (%s)", table.concat( mappingIds, "," ) ) )
		
		--Remove all outfits
		local removeOutfits = Pointshop2.StoredOutfit.removeDbEntries( Format( "WHERE id IN (%s)", table.concat( outfitIds, "," ) ) )
		
		return WhenAllFinished{ removeMappings, removeOutfits }
	end )
end

function HatPersistence.static.createOrUpdateFromSaveTable( saveTable, doUpdate )
	return Pointshop2.ItemPersistence.createOrUpdateFromSaveTable( saveTable, doUpdate )
	:Then( function( itemPersistence )
		if doUpdate then
			return HatPersistence.findByItemPersistenceId( itemPersistence.id )
		else
			local hat = HatPersistence:new( )
			hat.itemPersistenceId = itemPersistence.id
			return hat
		end
	end )
	:Then( function( hat )
		hat.iconInfo = saveTable.iconInfo or {}
		hat.validSlots = saveTable.validSlots
		if doUpdate then
			--For simplicity remove all OutfitMappings and recreate them
			return WhenAllFinished{ hat:save( ), hat:removeOutfits( ) }
		else
			return hat:save( )
		end
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