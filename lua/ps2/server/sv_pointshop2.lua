-- UNCOMMENT TO USE FastDL
--LibK.addContentFolder( "materials/pointshop2" )
--LibK.addContentFolder( "materials/trails" )
resource.AddWorkshop( "439856500" )

function Pointshop2.ResetDatabase( )
	local models = {}
	local function add( tbl ) 
		for k, v in pairs( tbl ) do
			if istable( v ) and v.dropTable then
				table.insert( models, v )
			end
		end
	end
	add( Pointshop2 )
	add( KInventory )
	
	LibK.SetBlocking( true )
	Pointshop2.DB.DisableForeignKeyChecks( true )
	local promises = {}
	for k, v in pairs( models ) do
		local promise = v.dropTable( )
		:Done( function( )
			KLogf( 5, "Dropped table %s", v.name )
		end )
		table.insert( promises, promise )
	end
	
	LibK.ResetTableCache( )
	
	for k, v in pairs( models ) do
		local promise = v:initializeTable( )
		:Done( function( )
			KLogf( 5, "Reset Table %s", v.name )
		end )
		table.insert( promises, promise )
	end
	Pointshop2.DB.DisableForeignKeyChecks( false )
	LibK.SetBlocking( false )
	
	return WhenAllFinished( promises )
end

/*
	This function tries to find and fix database errors.
	Only use it in extreme cases and ALWAYS do a backup!
	The function doesn't consider Lua defined items and detects them as DB errors, be very careful with that!
*/
function Pointshop2.FixDatabase( )
	-- 1: Find all itemPersistences without a valid parent base persistence
	local promises = {}
	local persistences = Pointshop2Controller:getPersistenceModels( )
	for _, persistenceModel in pairs( persistences ) do
		local promise = persistenceModel.getDbEntries( "WHERE 1" )
		:Then( function( persistentItems ) 
			local promises = {}
			for _, item in pairs( persistentItems ) do
				if not item.ItemPersistence then
					KLogf( 2, "[PS2-FIX] Found item persistence with invalid parent persistence, removing it, class %s, id %i", persistenceModel.name, item.id )
					table.insert( promises, item:remove( ) )
				end
			end
			return WhenAllFinished( promises )
		end )
		table.insert( promises, promise )
	end
	
	-- 2: Find all items that don't have a valid class (base persistence)
	WhenAllFinished( promises ) 
	:Then( function( )
		return KInventory.Item.getAll( 0 ) --Don't resolve relationships
	end )
	:Then( function( items )
		local promises = {}
		for k, v in pairs( items ) do
			if v._creationFailed then
				PrintTable( v )
				KLogf( 2, "[PS2-FIX] Found invalid item reference in inventory, removing item %i, class %s", v.id, v._className )
				table.insert( promises, v:remove( ) )
			end
		end
		return WhenAllFinished( promises )
	end )
	
	-- 3: Find all item mappings that don't have a valid class (base persistence)
	:Then( function( )
		return Pointshop2.ItemMapping.getAll( )
	end )
	:Then( function( itemMappings ) 
		local promises = {}
		for k, itemMapping in pairs( itemMappings ) do
			local promise = Pointshop2.ItemPersistence.findById( itemMapping.itemClass )
			:Then( function( persistence )
				if not persistence then
					KLogf( 2, "[PS2-FIX] Found invalid reference in mapping, class was %s", itemMapping.itemClass )
					return itemMapping:remove( )
				end
			end )
			table.insert( promises, promise )
		end
		return WhenAllFinished( promises )
	end )
	
	-- 4: Remove settings wrongfully in the DB
	:Then( function( )
		return WhenAllFinished{
			Pointshop2.StoredSetting.removeWhere{ plugin = "Pointshop 2", path = "InternalSettings.Servers" },
			Pointshop2.StoredSetting.removeWhere{ plugin = "Pointshop 2", path = "InternalSettings.ServerId" }
		}
	end )
	
	:Done( function( )
		RunConsoleCommand( "changelevel", game.GetMap( ) )
	end )
end

function Pointshop2.PlayerOwnsItem( ply, item )
	for k, v in pairs( ply.PS2_Inventory:getItems( ) ) do
		if v.id == item.id then
			return true
		end
	end
	
	for k, v in pairs( ply.PS2_Slots ) do
		if v.itemId == item.id then
			return true
		end
	end
	
	return false
end