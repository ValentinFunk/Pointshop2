local DB

local function convertCategoryOrganization( )
	Pointshop2 = {}
	include( "ps2/shared/sh_model_categorysettings.lua" )
	Pointshop2.Category.static.DB = "Update"

	return Pointshop2.Category.getDbEntries( "WHERE parent IS NULL" )
	:Then( function( categories )
		if #categories == 1 and categories[1].label == "Root" then
			-- Already updated
			print( "Already updated to new format: Root node exists" )
			return
		end

		local rootNode = Pointshop2.Category:new( )
		rootNode.label = "Root"
		rootNode.icon = "Root"

		return rootNode:save( )
		:Then( function( rootNode )
			local notForSale = Pointshop2.Category:new( )
			notForSale.label = "Not for sale Items"
			notForSale.icon = "pointshop2/circle14.png"
			notForSale.parent = rootNode.id

			local shopCategories = Pointshop2.Category:new( )
			shopCategories.label = "Shop Categories"
			shopCategories.icon = "pointshop2/folder62.png"
			shopCategories.parent = rootNode.id

			return WhenAllFinished{ notForSale:save( ), shopCategories:save( ) }
		end )
		:Then( function( notForSale, shopCategories )
			print( "NotForSale: ", notForSale.id )
			print( "Shop:", shopCategories.id )
			local promises = {}
			for k, v in pairs( categories ) do
				v.parent = shopCategories.id
				table.insert( promises, v:save( ) )
				print( "Updated ", v.label )
			end
			return WhenAllFinished( promises )
		end )
	end )
end

local def = Deferred( )

hook.Add( "LibK_DatabaseInitialized", "Initialized", function( dbObj, name )
	DB = dbObj

	if name != "Update" then
		return
	end

	Promise.Resolve( )
	:Then( function( )
		if DB.CONNECTED_TO_MYSQL then
			return DB.DoQuery( "SHOW TABLES LIKE 'ps2_itempersistence'" )
			:Then( function( exists )
				return exists
			end )
		else
			return DB.DoQuery( "SELECT name FROM sqlite_master WHERE type='table' AND name='ps2_itempersistence'" )
			:Then( function( result )
				local exists = result and result[1] and result[1].name
				return exists
			end )
		end
	end )
	:Then( function( shouldUpdate )
		KLogf( 2, "[INFO] We are on %s, %s", DB.CONNECTED_TO_MYSQL and "MySQL" or "SQLite", tostring(shouldUpdate) )
		if shouldUpdate then
			return convertCategoryOrganization( )
		end
	end )
	:Then( function( )
		def:Resolve( )
	end, function( errid, err )
		KLogf( 2, "[ERROR] Error during update: %i, %s.", errid, err )
		def:Reject( errid, err )
	end )
end )

DB = LibK.getDatabaseConnection( LibK.SQL, "Update" )

return def:Promise( )
