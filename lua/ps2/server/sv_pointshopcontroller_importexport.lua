function Pointshop2Controller:exportItems( )
	local promises = {}
	
	local exportTable = {}
	for _, persistence in pairs( Pointshop2Controller:getPersistenceModels( ) ) do
		if persistence.generateExportTable then
			local promise = persistence.generateExportTable( )
			:Done( function( persistenceExported )
				exportTable[persistence.name] = persistenceExported
			end )
			:Fail( function( err )
				error( persistence.name "Failed", err )
			end )
			table.insert( promises, promise )
		else
			KLogf( 3, "[WARN] Couldn't export persistence %s, not implemented!", persistence.name )
		end
	end
	
	return WhenAllFinished( promises )
	:Done( function( )
		local filename = "ps2_export_".. os.date( "%Y-%m-%d_%H-%M" ) .. ".txt"
		print( filename )
		file.Write( filename, LibK.luadata.Encode( exportTable ) )
	end )
end

function Pointshop2Controller:importItemsFromFile( filename )
	KLogf( 4, "[Pointshop2] Starting import of %s", filename )
	local exportTable = LibK.luadata.ReadFile( filename )
	return self:importItems( exportTable )
	:Then( function( )
		return self:moduleItemsChanged( )
	end )
end

function Pointshop2Controller:importItems( exportTable )
	local promises = {}
	
	for persistenceClassName, exportData in pairs( exportTable ) do
		local persistenceClass = getClass( persistenceClassName )
		if not persistenceClass then
			KLogf( 3, "[WARN] Not importing %s items, persistence not installed!" )
			continue
		end
		
		if not persistenceClass.importDataFromTable then
			KLogf( 3, "[WARN] Not importing %s items, persistence not supported!" )
			continue
		end
		
		local promise = persistenceClass.importDataFromTable( exportData )
		promise:Done( function( )
			KLogf( 4, "    -> Imported %s", persistenceClassName )
		end )
		table.insert( promises, promise )
	end
	
	return WhenAllFinished( promises )
end

function Pointshop2Controller:exportCategoryOrganization( )
	return WhenAllFinished{ Pointshop2.Category.getDbEntries( "WHERE 1 ORDER BY parent ASC" ), 
		Pointshop2.ItemMapping.getDbEntries( "WHERE 1" ),
		Pointshop2.ItemPersistence.getDbEntries( "WHERE 1" )
	}
	:Then( function( categories, itemMappings, persistences )
		--Lookup for classes
		local persistencesLookup = {}
		for k, v in pairs( persistences ) do
			persistencesLookup[v.id] = v
		end
	
		local stack = {}
		for k, v in pairs( self.itemCategories ) do
			table.insert( stack, { 
				self = {
					id = tonumber( v.id ),
					label = v.label,
					icon = v.icon
				},
				subcategories = {},
				items = {},
				parentId = v.parent
			} )
			
			local item = stack[#stack]
			for k, dbItemMapping in pairs( self.itemMappings ) do
				if dbItemMapping.categoryId == item.self.id then
					table.insert( item.items, dbItemMapping.itemClass )
				end
			end
		end
		
		local function findAndAddToParent( startNode, parentId, subcategory )
			if startNode.self.id ==  parentId then
				table.insert(startNode.subcategories, subcategory)
				return true
			end

			for id, category in pairs( startNode.subcategories ) do
				if findAndAddToParent( category, parentId, subcategory ) then
					return true
				end
			end
		end
		
		local n = 1
		local tree
		while ( #stack > 0 ) do
			n = n +1
			if n > 1000000 then
				error( "Overflow" )
				break
			end
			
			local item = table.remove( stack )
			if not item.parentId then
				tree = item
				continue
			end
			
			if not tree or not findAndAddToParent( tree, item.parentId, item ) then
				table.insert( stack, 1, item )
				continue
			end
		end
		
		local shopCategories = {}
		for k, v in pairs( tree.subcategories ) do
			if v.self.label == "Shop Categories" then
				shopCategories = v.subcategories
			end
		end
		
		return shopCategories
	end )
	:Done( function( exportTable )
		local filename = "ps2_export_categories_".. os.date( "%Y-%m-%d_%H-%M" ) .. ".txt"
		print( filename )
		file.Write( filename, LibK.luadata.Encode( exportTable ) )
	end )
end

function Pointshop2Controller:importCategoriesFromFile( filename )
	local importTable = LibK.luadata.ReadFile( filename )
	return self:importCategoryOrganization( importTable )
	:Done( function( )
		return self:moduleItemsChanged( )
	end )
end

function Pointshop2Controller:importCategoryOrganization( importTable )
	local addCatPromises = {}
	local function recursiveAddCategory( category, parentId )
		local dbCategory = Pointshop2.Category:new( )
		dbCategory.label = category.self.label
		dbCategory.icon = category.self.icon
		dbCategory.parent = parentId
		return dbCategory:save( )
		:Done( function( )
			print( "Saved", category.self.label)
		end) 
		:Then( function( dbCategory )
			local promises = {}
			
			category.id = dbCategory.id --need this later for the items
			for _, subcategory in pairs( category.subcategories ) do
				print( "Subcat", subcategory.self.label, dbCategory.id )
				local promise = recursiveAddCategory( subcategory, dbCategory.id )
				table.insert( promises, promise )
			end
			
			return WhenAllFinished( promises )
		end )
		:Fail( function( errid, err ) error( "Error saving subcategory", errid, err ) end )
	end
	
	local shopCategoryId = Pointshop2.GetCategoryByName( "Shop Categories" ).id
	for k, category in pairs( importTable ) do
		local promise = recursiveAddCategory( category, shopCategoryId )
		table.insert( addCatPromises, promise )
	end

	
	--Fucking sqlite...
	local findItemIdByCRC 
	if Pointshop2.DB.CONNECTED_TO_MYSQL then
		findItemIdByCRC = function( crc )
			return Pointshop2.DB.DoQuery( Format( "SELECT id FROM ps2_itempersistence WHERE CRC32(CONCAT(baseClass, name, description)) = %s",
				Pointshop2.DB.SQLStr( crc )
			) )
			:Then( function( result )
				if result and result[1] then
					return result[1].id
				end
			end )
		end
	else
		LibK.DB.SetBlocking( true )
		local itemPersistenceIdMap = {}
		Pointshop2.ItemPersistence.getDbEntries( "WHERE 1" )
		:Done( function( persistences ) 
			for k, v in pairs( persistences ) do
				local hash = util.CRC( v.baseClass .. v.name .. v.description )
				print( hash )
				itemPersistenceIdMap[hash] = v.id
			end 
		end )
		LibK.DB.SetBlocking( false )
		
		findItemIdByCRC = function( crc )
			local def = Deferred( )
			def:Resolve( itemPersistenceIdMap[crc] )
			return def:Promise( )
		end
	end
	
	
	return WhenAllFinished( addCatPromises )
	:Then( function( )
		local importPromises = {}
		local function recursiveAddItems( category )
			local promises = {}
			for _, crc in pairs( category.items ) do
				findItemIdByCRC( crc )
				:Then( function( id )
					if not id then
						ErrorNoHalt( "Couldn't find item id, skipping", crc )
						return
					end
					
					if not category.id then
						print( "Item " .. id .. " invalid category " )
						PrintTable( category )
						return
					end
					
					local itemMapping = Pointshop2.ItemMapping:new( )
					itemMapping.itemClass = id
					itemMapping.categoryId = category.id
					return itemMapping:save( )
				end )
				:Fail( function( errid, err ) error( "Error saving item mapping", errid, err ) end )
				table.insert( promises, promise )
			end
			
			for _, subcategory in pairs( category.subcategories ) do
				local promise = recursiveAddItems( subcategory )
				table.insert( promises, promise )
			end
			
			return WhenAllFinished( promises )
		end
		
		for k, category in pairs( importTable ) do
			local promise = recursiveAddItems( category )
			table.insert( importPromises, promise )
		end
		
		return WhenAllFinished( importPromises )
	end )
end

function Pointshop2Controller:resetToDefaults( )
	--Just to be sure...
	WhenAllFinished{ self:exportItems( ), self:exportCategoryOrganization( ) }
	:Then( function( )
		--Reset All
		return Pointshop2.ResetDatabase( )
	end )
	:Done( function( )
		hook.Run( "Pointshop2_FullReset" )
		RunConsoleCommand( "changelevel", game.GetMap( ) )
	end )
end

function Pointshop2Controller:installDefaults( )
	WhenAllFinished{ self:exportItems( ), self:exportCategoryOrganization( ) }
	:Then( function( )
		return self:importItems( Pointshop2.DefaultItems )
	end )
	:Then( function( )
		return self:importCategoryOrganization( Pointshop2.DefaultCategories )
	end )
	:Done( function( )
		return self:moduleItemsChanged( )
	end )
end

function Pointshop2Controller:fixDatabase( )
	Pointshop2.FixDatabase( )
end