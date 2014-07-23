Pointshop2Controller = class( "Pointshop2Controller" )
Pointshop2Controller:include( BaseController )

function Pointshop2.InitPromises( )
	Pointshop2.LoadModuleItemsPromise = Deferred( )
	Pointshop2.LoadModuleItemsPromise:Done( function( )
		KLogf( 4, "[Pointshop2] All Module items were loaded" )
	end )

	Pointshop2.ItemsLoadedPromise = Deferred( )
	Pointshop2.ItemsLoadedPromise:Done( function( )
		KLogf( 4, "[Pointshop2] All Items were loaded by KInv" )
	end )
	hook.Add( "KInv_ItemsLoaded", "ResolveDeferred", function( )
		Pointshop2.ItemsLoadedPromise:Resolve( ) --Trigger ready for all listeners
	end )

	Pointshop2.DatabaseConnectedPromise = Deferred( )
	Pointshop2.DatabaseConnectedPromise:Done( function( )
		KLogf( 4, "[Pointshop2] The database was connected" )
	end )
	function Pointshop2.onDatabaseConnected( )
		DATABASES["KInventory"] = Pointshop2.DB
		if Pointshop2.ModulesLoaded then
			Pointshop2.DatabaseConnectedPromise:Resolve( )
		else
			hook.Add( "PS2_ModulesLoaded", "load", function( )
				Pointshop2.DatabaseConnectedPromise:Resolve( )
			end )
		end
	end

	Pointshop2.SettingsLoadedPromise = Deferred( )
	Pointshop2.SettingsLoadedPromise:Done( function( )
		KLogf( 4, "[Pointshop2] Settings have been loaded" )
	end )

	Pointshop2.FullyInitializedPromise = WhenAllFinished{ 
		Pointshop2.ItemsLoadedPromise:Promise( ),
		Pointshop2.DatabaseConnectedPromise:Promise( ),
		Pointshop2.SettingsLoadedPromise:Promise( )
	}
	Pointshop2.FullyInitializedPromise:Done( function( )
		KLogf( 4, "[Pointshop2] The initial load stage has been completed" )
	end )
end
Pointshop2.InitPromises( )
	
--Override for access controll
--returns a promise, resolved if user can do it, rejected with error if he cant
function Pointshop2Controller:canDoAction( ply, action )
	local def = Deferred( )
	if action == "saveCategoryOrganization" or
	   action == "removeItem"
	then
		if PermissionInterface.query( ply, "pointshop2 manageitems" ) then
			def:Resolve( )
		else
			def:Reject( 1, "Permission Denied" )
		end
	elseif action == "resetToDefaults" or action == "installDefaults" then
		if PermissionInterface.query( ply, "pointshop2 reset" ) then
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
	elseif action == "outfitsReceived" then
		def:Resolve( )
	elseif action == "searchPlayers" or
		   action == "getUserDetails" or
		   action == "adminChangeWallet"
	then
		if PermissionInterface.query( ply, "pointshop2 manageusers" ) then
			def:Resolve( )
		else
			def:Reject( 1, "Permission Denied" )
		end
	elseif action == "buyItem" or action == "sellItem" then
		def:Resolve( )
	elseif action == "equipItem" or action == "unequipItem" then
		def:Resolve( )
	elseif action == "sendPoints" then
		def:Resolve( )
	else
		def:Reject( 1, "Permission denied" )
	end
	return def:Promise( )
end

function Pointshop2Controller:initializeInventory( ply )
	return KInventory.Inventory.findByOwnerId( ply.kPlayerId )
	:Then( function( inventory )
		--Check for Inventory and create if necessary
		if inventory then
			return inventory
		end
		
		inventory = KInventory.Inventory:new( )
		inventory.ownerId = ply.kPlayerId
		inventory.numSlots = Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.DefaultSlots" )
		inventory.maxWeight = 0 --Not using weight for ps items
		return inventory:save( )
	end )
	:Then( function( inventory )
		if inventory.numSlots < Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.DefaultSlots" ) then
			inventory.numSlots = Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.DefaultSlots" )
			return inventory:save( )
		end
		return inventory
	end )
	:Then( function( inventory )
		--Load Items
		return inventory:loadItems( )
		:Done( function( )
			--Cache the inventory
			ply.PS2_Inventory = inventory
			KLogf( 5, "[PS2] Loaded inventory for player %s", ply:Nick( ) )
			
			--Network the Inventory to the player
			self:startView( "Pointshop2View", "receiveInventory", ply, inventory )
			--self:startView( "InventoryView", "receiveInventory", ply, inventory )
		end )
		:Fail( function( errid, err )
			KLogf( 2, "Error loading items %i %s", errid, err )
		end )
	end,
	function( errid, err )
		KLogf( 2, "Error creating inventory %i %s", errid, err )
	end )
end

/*
	After joining initialize all slots for the player
	and equip Items he has in them
*/
function Pointshop2Controller:initializeSlots( ply )
	return Pointshop2.EquipmentSlot.findAllByOwnerId( ply.kPlayerId )
	:Then( function( slots )
		--Don't double equip if the script gets reloaded
		local shouldEquipItems = true
		if ply.PS2_Slots then
			shouldEquipItems = false
		end
		
		ply.PS2_Slots = {}
		for _, slot in pairs( slots ) do
			ply.PS2_Slots[slot.id] = slot
			KLogf( 5, "[PS2] Loaded slots for player %s", ply:Nick( ) )
		end
		self:startView( "Pointshop2View", "receiveSlots", ply, slots )
	
		if shouldEquipItems then
			ply.outfitsReceivedPromise:Done( function( )
				for _, slot in pairs( ply.PS2_Slots ) do
					if not slot.itemId then continue end
					
					local item = slot.Item
					item:OnEquip( ply )
					
					self:startView( "Pointshop2View", "playerEquipItem", player.GetAll( ), ply, item )
				end
			end )
		end
	end )
end

--network wallets to owning players and all admins
function Pointshop2Controller:getWalletChangeSubscribers( ply )
	local receivers = { ply }
	for k, v in pairs( player.GetAll( ) ) do
		if PermissionInterface.query( v, "pointshop2 manageusers" ) then
			if v == ply then continue end
			table.insert( receivers, v )
		end
	end
	return receivers
end

function Pointshop2Controller:sendWallet( ply )
	Pointshop2.Wallet.findByOwnerId( ply.kPlayerId )
	:Then( function( wallet )
		if not wallet then
			local wallet = Pointshop2.Wallet:new( )
			wallet.points = Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.DefaultWallet.Points" )
			wallet.premiumPoints = Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.DefaultWallet.PremiumPoints" )
			wallet.ownerId = ply.kPlayerId
			return wallet:save( )
		end
		return wallet
	end )
	:Then( function( wallet )
		ply.PS2_Wallet = wallet
		self:startView( "Pointshop2View", "walletChanged", self:getWalletChangeSubscribers( ply ), wallet )
	end )
end

function Pointshop2Controller:sendDynamicInfo( ply )
	Pointshop2.LoadModuleItemsPromise:Done( function( )
		WhenAllFinished{ Pointshop2.ItemMapping.getDbEntries( "WHERE 1" ), 
						 Pointshop2.Category.getDbEntries( "WHERE 1 ORDER BY parent ASC" )
		}
		:Then( function( itemMappings, categories )
			local itemProperties = self.cachedPersistentItems
			self:startView( "Pointshop2View", "receiveDynamicProperties", ply, itemMappings, categories, itemProperties )
		end )
	end )
end

--[[
	Send equipped items of players to "late" joiners
]]--
function Pointshop2Controller:sendActiveEquipmentTo( plyToSendTo )
	for _, ply in pairs( player.GetAll( ) ) do
		if ply == plyToSendTo then
			continue --handled in the slot-sender
		end
		
		if not ply.PS2_Slots then
			continue --handled in the slot-sender
		end
		
		for _, slot in pairs( ply.PS2_Slots ) do
			if not slot.itemId then continue end
			
			local item = KInventory.ITEMS[slot.itemId]
			if not item then
				KLogf( 2, "[WARN] Uncached item %s from player %s slot %s", slot.itemId, ply:Nick( ), slot.name )
				continue
			end
			self:startView( "Pointshop2View", "playerEquipItem", plyToSendTo, ply, item )
		end
	end
end

local function initPlayer( ply )
	KLogf( 5, "[PS2] Initializing player %s, modules loaded: %s", ply:Nick( ), Pointshop2.LoadModuleItemsPromise:Promise( )._state )
	local controller = Pointshop2Controller:getInstance( )
	controller:sendWallet( ply )
	
	ply.outfitsReceivedPromise = Deferred( )
	Pointshop2.LoadModuleItemsPromise:Done( function( )
		controller:sendDynamicInfo( ply )
		
		--TODO: Make a proper promise/transaction for this
		timer.Simple( 2, function( )
			WhenAllFinished{ controller:initializeInventory( ply ),
				controller:initializeSlots( ply ),
				ply.outfitsReceivedPromise 
			}
			:Done( function( )
				controller:sendActiveEquipmentTo( ply )
			end )
		end )
	end )
end
hook.Add( "LibK_PlayerInitialSpawn", "Pointshop2Controller:initPlayer", function( ply )
	KLogf( 5, "[PS2] Initializing player %s, modules loaded: %s", ply:Nick( ), Pointshop2.LoadModuleItemsPromise:Promise( )._state )
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
	PrintTable( categoryItemsTable )
	--Repopulate Categories Table
	Pointshop2.Category.removeDbEntries( "WHERE 1=1" )
	:Fail( function( errid, err ) error( "Couldn't truncate categories", errid, err ) end )
	
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
	Pointshop2.ItemMapping.removeDbEntries( "WHERE 1=1" )
	:Fail( function( errid, err ) error( "Couldn't truncate item mappings", errid, err ) end )
	
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
	LibK.SetBlocking( true )
	Pointshop2.DB.DoQuery( "BEGIN" )
	:Fail( function( errid, err ) 
		KLogf( 2, "Error starting transaction: %s", err )
		self:startView( "Pointshop2View", "displayError", ply, "A Technical error occured, your changes could not be saved!" )
		error( "Error starting transaction:", err )
	end )
	
	Pointshop2.DB.DisableForeignKeyChecks( true )
	
	local success, err = pcall( performSafeCategoryUpdate, categoryItemsTable )
	if not success then
		KLogf( 2, "Error saving categories: %s", err )
		Pointshop2.DB.DoQuery( "ROLLBACK" )
		Pointshop2.DB.DisableForeignKeyChecks( false )
		LibK.SetBlocking( false )
		
		self:startView( "Pointshop2View", "displayError", ply, "A technical error occured, your changes could not be saved!" )
	else
		KLogf( 4, "Categories Updated" )
		Pointshop2.DB.DoQuery( "COMMIT" )
		Pointshop2.DB.DisableForeignKeyChecks( false )
		LibK.SetBlocking( false )
		
		for k, v in pairs( player.GetAll( ) ) do
			self:sendDynamicInfo( v )
		end
	end
end	

function Pointshop2Controller:getPersistenceModels( )
	local persistences = {}
	for _, mod in pairs( Pointshop2.Modules ) do
		for k, v in pairs( mod.Blueprints ) do
			local class = Pointshop2.GetItemClassByName( v.base )
			if not class then
				KLogf( 2, "[Pointshop2][Error] Blueprint %s: couldn't find baseclass", v.base )
				continue
			end
			
			table.insert( persistences, class.getPersistence( ) )
		end
	end
	return persistences
end
	
function Pointshop2Controller:loadModuleItems( )
	local promises = {}
	self.cachedPersistentItems = {}
	
	for _, persistence in pairs( Pointshop2Controller:getPersistenceModels( ) ) do
		local promise = persistence.getDbEntries( "WHERE 1" )
		:Then( function( persistentItems ) 
			for _, persistentItem in pairs( persistentItems ) do
				table.insert( self.cachedPersistentItems, persistentItem )
				Pointshop2.LoadPersistentItem( persistentItem )
			end
		end )
		table.insert( promises, promise )
	end

	return WhenAllFinished( promises )
end
local function loadPersistent( )
	KLogf( 4, "[Pointshop2] Loading Module items" )
	Pointshop2Controller:getInstance( ):loadModuleItems( )
	:Done( function( )
		Pointshop2.LoadModuleItemsPromise:Resolve( )
		KLogf( 4, "[Pointshop2] Loaded Module items from DB" )
	end )
	:Fail( function( errid, err )
		Pointshop2.LoadModuleItemsPromise:Reject( errid, err )
		KLogf( 2, "[Pointshop2] Couldn't load persistent items: %i - %s", errid, err )
	end )
end
--When KInventory has loaded all item bases and the database has been connected we load persistent items
Pointshop2.FullyInitializedPromise:Done( function( )
	loadPersistent( )
end )

function Pointshop2Controller:saveModuleItem( ply, saveTable )
	local class = Pointshop2.GetItemClassByName( saveTable.baseClass )
	if not class then
		KLogf( 3, "[Pointshop2] Couldn't save item %s: invalid baseclass", saveTable.name, saveTable.baseClass )
		return self:reportError( "Pointshop2View", ply, "Error saving item", 1, "Invalid Baseclass " .. saveTable.baseClass )
	end
	--If persistenceId != nil update existing
	print( saveTable.persistenceId != nil, saveTable.persistenceId )
	class.getPersistence( ).createOrUpdateFromSaveTable( saveTable, saveTable.persistenceId != nil )
	:Then( function( saved )
		KLogf( 4, "[Pointshop2] Saved item %s", saveTable.name )
		self:moduleItemsChanged( )
	end, function( errid, err )
		self:reportError( "Pointshop2View", ply, "Error saving item", errid, err )
	end )
end

function Pointshop2Controller:moduleItemsChanged( )
	for k, v in pairs( player.GetAll( ) ) do
		v.outfitsReceivedPromise = Deferred( )
	end
	
	return self:loadModuleItems( )
	:Then( function( )
		return self:loadOutfits( )
	end )
	:Done( function( )
		for k, v in pairs( player.GetAll( ) ) do
			v.outfitsReceivedPromise:Done( function( )
				self:sendDynamicInfo( v )
			end )
		end
	end )
end

function Pointshop2Controller:addToPlayerWallet( ply, currencyType, addition )
	if not table.HasValue( { "points", "premiumPoints" }, currencyType ) then
		local def = Deferred( )
		def:Reject( -2, "Invalid currency type " .. currencyType )
		return def:Promise( )
	end
	
	if not ply.PS2_Wallet then
		local def = Deferred( )
		def:Reject( -3, "Player wallet not loaded" )
		return def:Promise( )
	end
	
	self:updatePlayerWallet( ply.kPlayerId, currencyType, ply.PS2_Wallet[currencyType] + addition )
	:Done( function( wallet )
		self:startView( "Pointshop2View", "walletChanged", self:getWalletChangeSubscribers( ply ), wallet )
	end )
end

function Pointshop2Controller:addToPointFeed( ply, message, points, small )
	self:startView( "Pointshop2View", "addToPointFeed", ply, message, points, small )
end

--Lookup table taken from adamburton/pointshop
local KeyToHook = {
	F1 = "ShowHelp",
	F2 = "ShowTeam",
	F3 = "ShowSpare1",
	F4 = "ShowSpare2",
	None = "ThisHookDoesNotExist"
}
function Pointshop2Controller:registerShopOpenHook( )
	for key, hookName in pairs( KeyToHook ) do
		hook.Remove( hookName, "PS2_MenuOpen" )
	end
	hook.Add( KeyToHook[Pointshop2.GetSetting( "Pointshop 2", "GUISettings.ShopKey" )], "PS2_MenuOpen", function( ply )
		self:startView( "Pointshop2View", "toggleMenu", ply )
	end )
end
hook.Add( "PS2_OnSettingsUpdate", "ChangeKeyHook", function( )
	Pointshop2Controller:getInstance( ):registerShopOpenHook( )
end )
Pointshop2.SettingsLoadedPromise:Done( function( )
	Pointshop2Controller:getInstance( ):registerShopOpenHook( )
end )

function Pointshop2Controller:sendPoints( ply, targetPly, points )
	if points < 0 then
		KLogf( 3, "Player %s tried to send negative points! Hacking attempt!", ply:Nick( ) )
		return
	end
	
	if points > ply.PS2_Wallet.points then
		KLogf( 3, "Player %s tried to send more points than he has! Hacking attempt!", ply:Nick( ) )
		return
	end
	
	if not IsValid( targetPly ) then
		--This could legitimately happen
		KLogf( 4, "Player %s tried to send points to an invalid player!", ply:Nick( ) )
		return
	end
	
	self:updatePlayerWallet( ply.kPlayerId, "points", ply.PS2_Wallet.points - points )
	:Done( function( wallet )
		self:startView( "Pointshop2View", "walletChanged", self:getWalletChangeSubscribers( ply ), wallet )
	end )
	
	self:updatePlayerWallet( targetPly.kPlayerId, "points", targetPly.PS2_Wallet.points + points )
	:Done( function( wallet )
		self:startView( "Pointshop2View", "walletChanged", self:getWalletChangeSubscribers( targetPly ), wallet )
	end )
	
	--TODO: Send the targetPlayer a nice notification, similar to iten added
end

function Pointshop2Controller:removeItem( ply, itemClassName, refund )
	local itemClass = Pointshop2.GetItemClassByName( itemClassName )
	
	return Pointshop2.ItemMapping.removeWhere{ itemClass = itemClassName }
	:Then( function( )
		return KInventory.Item.removeWhere{ itemclass = itemClassName }
	end )
	:Then( function( )
		if not itemClass then
			local def = Deferred( )
			def:Reject( "An item " .. itemClassName .. " doesn't exist!" )
			return def:Promise( )
		end
		if itemClass:getPersistence( ).customRemove then
			return itemClass:getPersistence( ).customRemove( itemClass )
		end
		return Pointshop2.ItemPersistence.removeWhere{ id = itemClassName }
	end )
	:Then( function( )
		return self:moduleItemsChanged( )
	end )
end