Pointshop2Controller = class( "Pointshop2Controller" )
Pointshop2Controller:include( BaseController )

--Override for access controll
--returns a promise, resolved if user can do it, rejected with error if he cant
function Pointshop2Controller:canDoAction( ply, action )
	local def = Deferred( )
	if action == "saveCategoryOrganization" 
		if PermissionInterface.query( ply, "pointshop2_manageOrganization" ) then
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
	
end
hook.Add( "LibK_PlayerInitialSpawn", "Pointshop2Controller:sendDynamicInfo", function( ply )
	ReportsController:getInstance( ):sendDynamicInfo( ply )
end )

local function performSafeCategoryUpdate( categoryItemsTable )
	--Repopulate Categories Table
	Pointshop2.Category.truncateTable( )
	:Fail( function( errid, err ) error( "Couldn't tructate categories", errid, err ) end )
	
	local function recursiveAddCategory( category, parentId )
		local dbCategory = Pointshop2.Category:new( )
		dbCategory.label = category.self.label
		dbCategory.icon = category.self.icon
		dbCategory.parentId = parentId
		return dbCategory:save( )
		:Done( function( )
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
			local itemMapping = KInventory.ItemMapping:new( )
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
	DATABASES[Pointshop2.Category.DB].SetBlocking( true )
		DATABASES[Pointshop2.Category.DB].DoQuery( "START TRANSACTION" )
		local success, err = performSafeCategoryUpdate( categoryItemsTable )
		if not success then
			KLogf( 2, "Error saving categories: %s", err )
			DATABASES[Pointshop2.Category.DB].DoQuery( "ROLLBACK" )
			
			self:startView( "Pointshop2View", "displayError", ply, "A Technical error occured, your changes could not be saved!" )
		else
			KLogf( 4, "Categories Updated" )
			DATABASES[Pointshop2.Category.DB].DoQuery( "COMMIT" )
			
			for k, v in pairs( player.GetAll( ) ) do
				self:sendDynamicInfo( v )
			end
		end
	DATABASES[Pointshop2.Category.DB].SetBlocking( false )
end	