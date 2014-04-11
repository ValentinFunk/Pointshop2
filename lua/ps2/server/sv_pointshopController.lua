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
	elseif action == "saveModuleItem" then
		if PermissionInterface.query( ply, "pointshop2 createitems" ) then
			def:Resolve( )
		else
			def:Reject( 1, "Permission Denied" )
		end
	elseif action == "buyItem" then
		def:Resolve( )
	else
		def:Reject( 1, "Permission denied" )
	end
	return def:Promise( )
end

function Pointshop2Controller:initializeInventory( ply )
	KInventory.Inventory.findByOwnerId( ply.kPlayerId )
	:Then( function( inventory )
		--Check for Inventory and create if necessary
		if inventory then
			return inventory
		end
		
		inventory = KInventory.Inventory:new( )
		inventory.ownerId = ply.kPlayerId
		inventory.numSlots = Pointshop2.Config.DefaultSlots
		inventory.maxWeight = 0 --Not using weight for ps items
		return inventory:save( )
	end )
	:Then( function( inventory )
		--Load Items
		return inventory:loadItems( )
		:Done( function( )
			--Network the Inventory to the player
			self:startView( "Pointshop2View", "receiveInventory", ply, inventory )
		end )
		:Fail( function( errid, err )
			KLogf( 2, "Error loading items %i %s", errid, err )
		end )
	end,
	function( errid, err )
		KLogf( 2, "Error creating inventory %i %s", errid, err )
	end )
end

function Pointshop2Controller:sendWallet( ply )
	Pointshop2.Wallet.findByOwnerId( ply.kPlayerId )
	:Then( function( wallet )
		if not wallet then
			local wallet = Pointshop2.Wallet:new( )
			wallet.points = Pointshop2.Config.DefaultWallet.Points
			wallet.premiumPoints = Pointshop2.Config.DefaultWallet.PremiumPoints
			wallet.ownerId = ply.kPlayerId
			return wallet:save( )
		end
		return wallet
	end )
	:Then( function( wallet )
		self:startView( "Pointshop2View", "walletChanged", ply, wallet )
	end )
end

function Pointshop2Controller:sendDynamicInfo( ply )
	WhenAllFinished{ Pointshop2.ItemMapping.getDbEntries( "WHERE 1" ), 
					 Pointshop2.Category.getDbEntries( "WHERE 1 ORDER BY parent ASC" )
	}
	:Then( function( itemMappings, categories )
		print( "SendDynamicInfo ", ply, itemMappings, categories )
		local itemProperties = self.cachedPersistentItems
		self:startView( "Pointshop2View", "receiveDynamicProperties", ply, itemMappings, categories, itemProperties )
	end )
end
local function initPlayer( ply )
	local controller = Pointshop2Controller:getInstance( )
	controller:sendDynamicInfo( ply )
	controller:initializeInventory( ply )
	controller:sendWallet( ply )
end
hook.Add( "LibK_PlayerInitialSpawn", "Pointshop2Controller:sendDynamicInfo", function( ply )
	timer.Simple( 1, function( )
		initPlayer( ply )
	end )
end )
hook.Add( "OnReloaded", "Pointshop2Controller:sendDynamicInfo", function( )
	timer.Simple( 1, function( )
		for _, ply in pairs( player.GetAll( ) ) do
			initPlayer( ply )
		end
	end )
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
		DATABASES[Pointshop2.Category.DB].SetBlocking( false )
		
		self:startView( "Pointshop2View", "displayError", ply, "A technical error occured, your changes could not be saved!" )
	else
		KLogf( 4, "Categories Updated" )
		DATABASES[Pointshop2.Category.DB].DoQuery( "COMMIT" )
		DATABASES[Pointshop2.Category.DB].SetBlocking( false )
		
		for k, v in pairs( player.GetAll( ) ) do
			self:sendDynamicInfo( v )
		end
	end
end	
	
function Pointshop2Controller:loadModuleItems( )
	local promises = {}
	self.cachedPersistentItems = {}
	for _, mod in pairs( Pointshop2.Modules ) do
		for k, v in pairs( mod.Blueprints ) do
			local class = Pointshop2.GetItemClassByName( v.base )
			local promise = class.getPersistence( ).getDbEntries( "WHERE 1" )
			:Then( function( persistentItems ) 
				for _, persistentItem in pairs( persistentItems ) do
					table.insert( self.cachedPersistentItems, persistentItem )
					Pointshop2.LoadPersistentItem( persistentItem )
				end
			end )
			table.insert( promises, promise )
		end
	end
	return WhenAllFinished( promises )
end
local function loadPersistent( )
	KLogf( 4, "[Pointshop2] Loading Module items" )
	Pointshop2Controller:getInstance( ):loadModuleItems( )
	:Done( function( )
		KLogf( 4, "[Pointshop2] Loaded Module items from DB" )
	end )
	:Fail( function( errid, err )
		KLogf( 2, "[Pointshop2] Couldn't load persistent items: %i - %s", errid, err )
	end )
end
function Pointshop2.onDatabaseConnected( )
	loadPersistent( )
end

function Pointshop2Controller:saveModuleItem( ply, saveTable )
	local class = Pointshop2.GetItemClassByName( saveTable.baseClass )
	if not class then
		KLogf( 3, "[Pointshop2] Couldn't save item %s: invalid baseclass", saveTable.name, saveTable.baseClass )
		return self:reportError( "Pointshop2View", ply, "Error saving item", 1, "Invalid Baseclass " .. saveTable.baseClass )
	end
	class.getPersistence( ).createFromSaveTable( saveTable )
	:Then( function( saved )
		KLogf( 4, "[Pointshop2] Saved item %s", saveTable.name )
		self:moduleItemsChanged( )
	end, function( errid, err )
		self:reportError( "Pointshop2View", ply, "Error saving item", errid, err )
	end )
end

function Pointshop2Controller:moduleItemsChanged( )
	self:loadModuleItems( )
	:Then( function( )
		for k, v in pairs( player.GetAll( ) ) do
			self:sendDynamicInfo( v )
		end
	end )
end

function Pointshop2Controller:buyItem( ply, itemClass, currencyType )
	local itemClass = Pointshop2.GetItemClassByName( itemClass )
	if not itemClass then
		self:startView( "Pointshop2View", "displayError", ply, "Couldn't buy item, item " .. itemClass .. " isn't valid" ) 
		return
	end
	local price = itemClass.GetBuyPrice( ply )
	
	/*
		Wrap everything into a blocking transaction to make sure we don't get duplicate stuff
		if mysql takes a little longer to respond and prevent any lua from queueing querys in 
		between.
		TODO: look into alternative methods of locking the database as this is a bit performance heavy because it blocks the game thread, 
	*/
	DATABASES[Pointshop2.Category.DB].SetBlocking( true )
	DATABASES[Pointshop2.Category.DB].DoQuery( "BEGIN" )
	:Fail( function( errid, err ) 
		KLogf( 2, "Error starting transaction: %s", err )
		self:startView( "Pointshop2View", "displayError", ply, "A Technical error occured, your purchase was not carried out." )
		error( "Error starting transaction:", err )
	end )
	
	Pointshop2.Wallet.findByOwnerId( ply.kPlayerId )
	:Then( function( wallet )
		--Check currency / canAfford
		local canAfford = false
		if currencyType == "points" then
			if wallet.points >= price.points then
				canAfford = true
				wallet.points = wallet.points - price.points
			end
		else if currencyType == "premiumPoints" then
			if wallet.premiumPoints >= price.premiumPoints then
				canAfford = true
				wallet.premiumPoints = wallet.premiumPoints - price.premiumPoints
			end
		else
			local def = Deferred( )
			def:Reject( 1, "Invalid currency " .. currencyType )
			return def:Promise( )
		end
		
		if not canAfford then
			local def = Deferred( )
			def:Reject( 1, "You can't afford this item!" )
			return def:Promise( )
		end
		
		--Take money
		return wallet:save( )
	end )
	:Then( function( wallet )
		--Find inventory
		return KInventory.Inventory.findByOwnerId( ply.kPlayerId )
	end )
	:Then( function( inventory )
		local item = itemClass:new( )
		return item:save( )
		:Then( function( )
			return inventory:addItem( item )
		end )
	end )
	:Then( function( )
		KLogf( 2, "Error saving categories: %s", err )
		DATABASES[Pointshop2.Category.DB].DoQuery( "COMMIT" )
		DATABASES[Pointshop2.Category.DB].SetBlocking( false )
	end, function( errid, err )
		KLogf( 2, "Error saving categories: %s", err )
		DATABASES[Pointshop2.Category.DB].DoQuery( "ROLLBACK" )
		DATABASES[Pointshop2.Category.DB].SetBlocking( false )
		
		self:startView( "Pointshop2View", "displayError", ply, "A technical error occured (2), your purchase was not carried out." )
	end )
end