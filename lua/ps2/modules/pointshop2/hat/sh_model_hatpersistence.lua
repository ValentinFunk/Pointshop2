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
			foreignKey = "itemPersistenceId",
			onDelete = "CASCADE"
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
		if doUpdate and saveTable.outfitsChanged then
			--For simplicity remove all OutfitMappings and recreate them
			return WhenAllFinished{ hat:save( ), hat:removeOutfits( ) }
		else
			return hat:save( )
		end
	end )
	:Then( function( hat )
		if doUpdate and not saveTable.outfitsChanged then
			return
		end

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

HatPersistence:include( Pointshop2.EasyExport )

--Nice and easy
function HatPersistence:generateInstanceExportTable( )
	local cleanTable = Pointshop2.EasyExport.generateInstanceExportTable( self )
	cleanTable.OutfitHatPersistenceMapping = {}
	for _, mapping in pairs( self.OutfitHatPersistenceMapping ) do
		table.insert( cleanTable.OutfitHatPersistenceMapping, {
			model = mapping.model,
			outfit = Pointshop2.Outfits[mapping.outfitId],
		} )
	end
	return cleanTable
end

--Not so easy
local copyModelFields = LibK.copyModelFields
function HatPersistence.static.importDataFromTable( exportTable )
	local promises = {}

	for _, instanceExport in pairs( exportTable ) do
		--Create basic persistence
		local itemPersistence = Pointshop2.ItemPersistence:new( )
		copyModelFields( itemPersistence, instanceExport.ItemPersistence, Pointshop2.ItemPersistence.model )
		itemPersistence.uuid = LibK.GetUUID()

		local promise = itemPersistence:save( )
		:Then( function( itemPersistence )
			--Create hat persistence
			local actualPersistence = HatPersistence:new( )
			copyModelFields( actualPersistence, instanceExport, HatPersistence.model )
			actualPersistence.itemPersistenceId = itemPersistence.id
			return actualPersistence:save( )
		end )
		:Then( function( actualPersistence )
			local mappingPromises = {}

			--Create outfits and set up mappings
			for k, mappingExport in pairs( instanceExport.OutfitHatPersistenceMapping ) do
				--Create outfit
				local outfit = Pointshop2.StoredOutfit:new( )
				outfit.outfitData = mappingExport.outfit

				local mappingPromise = outfit:save( )
				:Then( function( outfit )
					--Create mapping
					local mapping = Pointshop2.OutfitHatPersistenceMapping:new( )
					mapping.model = mappingExport.model
					mapping.hatPersistenceId = actualPersistence.id
					mapping.outfitId = outfit.id

					return mapping:save( )
				end )
				table.insert( mappingPromises, mappingPromise )
			end

			return WhenAllFinished( mappingPromises )
		end )

		table.insert( promises, promise )
	end

	return WhenAllFinished( promises )
end

function HatPersistence.static.customRemove( itemClass )
	local ids = { "NULL" }
	for k, v in pairs( itemClass.outfitIds ) do
		table.insert( ids, tonumber(v) )
	end

	return WhenAllFinished{
		Pointshop2.StoredOutfit.removeDbEntries( "WHERE id IN (" .. table.concat( ids, ',' ) .. ")" ),
		Pointshop2.ItemPersistence.removeWhere{ id = itemClass.className }
	}
end
