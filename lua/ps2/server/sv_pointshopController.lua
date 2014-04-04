Pointshop2Controller = class( "Pointshop2Controller" )
Pointshop2Controller:include( BaseController )

--Override for access controll
--returns a promise, resolved if user can do it, rejected with error if he cant
function Pointshop2Controller:canDoAction( ply, action )
	local def = Deferred( )
	if action == "saveCategoryOrganization" then
		if PermissionInterface.query( ply, "pointshop2 manageitems" ) then
			def:Resolve( )
		else
			def:Reject( 1, "Permission Denied" )
		end
	else
		def:Reject( 1, "Permission denied" )
	end
	return def:Promise( )
end

function Pointshop2Controller:sendDynamicInfo( ply )
	timer.Simple( 1, function( )
		WhenAllFinished{ Pointshop2.ItemMapping.getDbEntries( "WHERE 1" ), 
						 Pointshop2.Category.getDbEntries( "WHERE 1 ORDER BY parent ASC" ) 
		}
		:Then( function( itemMappings, categories )
			local itemProperties = {}--TODO
			self:startView( "Pointshop2View", "receiveDynamicProperties", ply, itemMappings, categories, itemProperties )
		end )
	end )
end
hook.Add( "LibK_PlayerInitialSpawn", "Pointshop2Controller:sendDynamicInfo", function( ply )
	Pointshop2Controller:getInstance( ):sendDynamicInfo( ply )
end )
hook.Add( "OnReloaded", "Pointshop2Controller:sendDynamicInfo", function( )
	for _, ply in pairs( player.GetAll( ) ) do
		Pointshop2Controller:getInstance( ):sendDynamicInfo( ply )
	end
end )

local function performSafeCategoryUpdate( categoryItemsTable )
	--Repopulate Categories Table
	Pointshop2.Category.truncateTable( )
	:Fail( function( errid, err ) error( "Couldn't tructate categories", errid, err ) end )
	
	local function recursiveAddCategory( category, parentId )
		local dbCategory = Pointshop2.Category:new( )
		dbCategory.label = category.self.label
		dbCategory.icon = category.self.icon
		dbCategory.parent = parentId
		return dbCategory:save( )
		:Done( function( x )
			category.id = dbCategory.id --need this later for the items
			for _, subcategory in pairs( category.subcategories ) do
				recursiveAddCategory( subcategory, dbCategory.id )
			end
		end )
		:Fail( function( errid, err ) error( "Error saving subcategory", errid, err ) end )
	end
	for k, category in pairs( categoryItemsTable ) do
		recursiveAddCategory( category )
	end
	
	--Repopulate Item Mappings Table
	Pointshop2.ItemMapping.truncateTable( )
	:Fail( function( errid, err ) error( "Couldn't tructate item mappings", errid, err ) end )
	
	local function recursiveAddItems( category )
		for _, itemClassName in pairs( category.items ) do
			local itemMapping = Pointshop2.ItemMapping:new( )
			itemMapping.itemClass = itemClassName
			itemMapping.categoryId = category.id
			itemMapping:save( )
			:Fail( function( errid, err ) error( "Error saving item mapping", errid, err ) end )
		end
		
		for _, subcategory in pairs( category.subcategories ) do
			recursiveAddItems( subcategory )
		end
	end
	for k, category in pairs( categoryItemsTable ) do
		recursiveAddItems( category )
	end
end

function Pointshop2Controller:saveCategoryOrganization( ply, categoryItemsTable )
	--Wrap it into a transaction in case anything happens.
	--since tables are cleared and refilled for this it could fuck up the whole pointshop
	DATABASES[Pointshop2.Category.DB].SetBlocking( true )
		DATABASES[Pointshop2.Category.DB].DoQuery( "BEGIN" )
		:Fail( function( errid, err ) 
			KLogf( 2, "Error starting transaction: %s", err )
			self:startView( "Pointshop2View", "displayError", ply, "A Technical error occured, your changes could not be saved!" )
			error( "Error starting transaction:", err )
		end )
		
		local success, err = pcall( performSafeCategoryUpdate, categoryItemsTable )
		if not success then
			KLogf( 2, "Error saving categories: %s", err )
			DATABASES[Pointshop2.Category.DB].DoQuery( "ROLLBACK" )
			
			self:startView( "Pointshop2View", "displayError", ply, "A technical error occured, your changes could not be saved!" )
		else
			KLogf( 4, "Categories Updated" )
			DATABASES[Pointshop2.Category.DB].DoQuery( "COMMIT" )
			
			for k, v in pairs( player.GetAll( ) ) do
				self:sendDynamicInfo( v )
			end
		end
	DATABASES[Pointshop2.Category.DB].SetBlocking( false )
end	