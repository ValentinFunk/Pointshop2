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
	
		--Create Tree from the information
		local categoryItemsTable = {}
		for k, dbCategory in pairs( categories ) do
			local newCategory = { 
				self = {
					id = tonumber( dbCategory.id ),
					label = dbCategory.label,
					icon = dbCategory.icon
				},
				subcategories = { },
				items = {}
			}
			
			--Fill With items
			for k, dbItemMapping in pairs( itemMappings ) do
				if dbItemMapping.categoryId == newCategory.self.id then
					local persistence = persistencesLookup[tonumber(dbItemMapping.itemClass)]
					local hash = util.CRC( persistence.baseClass .. persistence.name .. persistence.description )
					table.insert( newCategory.items, hash )
				end
			end
			
			--Put it in the right place into the tree
			if not dbCategory.parent then
				--Create Category in root
				categoryItemsTable[newCategory.self.id] = newCategory
			else
				local function findAndAddToParent( tree, parentId, subcategory )
					if tree.self.id ==  parentId then
						tree.subcategories[newCategory.self.id] = subcategory
						return true
					end

					for id, category in pairs( tree.subcategories ) do
						if findAndAddToParent( category, parentId, subcategory ) then
							return true
						end
					end
				end
				for id, rootCategory in pairs( categoryItemsTable ) do
					if findAndAddToParent( rootCategory, dbCategory.parent, newCategory ) then
						break
					end
				end
			end
		end
		return categoryItemsTable
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
	for k, category in pairs( importTable ) do
		local promise = recursiveAddCategory( category )
		table.insert( addCatPromises, promise )
	end
	
	
	return WhenAllFinished( addCatPromises )
	:Then( function( )
		local importPromises = {}
		local function recursiveAddItems( category )
			local promises = {}
			for _, crc in pairs( category.items ) do
				local promise = Pointshop2.DB.DoQuery( Format( "SELECT id FROM ps2_itempersistence WHERE CRC32(CONCAT(baseClass,name,description)) = %s",
					Pointshop2.DB.SQLStr( crc )
				) )
				:Then( function( result )
					if not result or not result[1] then
						ErrorNoHalt( "Couldn't find item id, skipping" )
						return
					end
					
					if not category.id then
						print( "Item " .. result[1].id .. " invalid category " )
						PrintTable( category )
						return
					end
					
					local itemMapping = Pointshop2.ItemMapping:new( )
					itemMapping.itemClass = result[1].id
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