Pointshop2Controller = class( "Pointshop2Controller" )
Pointshop2Controller:include( BaseController )

--TODO:
--	- Cache player inventories
--	- Cache player items
-- Why? For proper, persistent OO and reduction in queries

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
	Pointshop2.DatabaseConnectedPromise:Resolve( )
end

Pointshop2.FullyInitializedPromise = WhenAllFinished{ Pointshop2.ItemsLoadedPromise:Promise( ), Pointshop2.DatabaseConnectedPromise:Promise( ) }
Pointshop2.FullyInitializedPromise:Done( function( )
	KLogf( 4, "[Pointshop2] The initial load stage has been completed" )
end )

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
	elseif action == "searchPlayers" or
		   action == "getUserDetails" 
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
		inventory.numSlots = Pointshop2.Config.DefaultSlots
		inventory.maxWeight = 0 --Not using weight for ps items
		return inventory:save( )
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
			self:startView( "InventoryView", "receiveInventory", ply, inventory )
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
	Pointshop2.EquipmentSlot.findAllByOwnerId( ply.kPlayerId )
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
			for _, slot in pairs( ply.PS2_Slots ) do
				if not slot.itemId then continue end
				
				local item = slot.Item
				item:OnEquip( ply )
				self:startView( "Pointshop2View", "playerEquipItem", player.GetAll( ), ply, item )
			end
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
			wallet.points = Pointshop2.Config.DefaultWallet.Points
			wallet.premiumPoints = Pointshop2.Config.DefaultWallet.PremiumPoints
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

local function initPlayer( ply )
	KLogf( 5, "[PS2] Initializing player %s, modules loaded: %s", ply:Nick( ), Pointshop2.LoadModuleItemsPromise:Promise( )._state )
	local controller = Pointshop2Controller:getInstance( )
	controller:sendWallet( ply )
	
	--
	Pointshop2.LoadModuleItemsPromise:Done( function( )
		controller:sendDynamicInfo( ply )
		controller:initializeInventory( ply )
		:Done( function( )
			controller:initializeSlots( ply )
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
	Pointshop2.DB.SetBlocking( true )
	Pointshop2.DB.DoQuery( "BEGIN" )
	:Fail( function( errid, err ) 
		KLogf( 2, "Error starting transaction: %s", err )
		self:startView( "Pointshop2View", "displayError", ply, "A Technical error occured, your changes could not be saved!" )
		error( "Error starting transaction:", err )
	end )
	
	local success, err = pcall( performSafeCategoryUpdate, categoryItemsTable )
	if not success then
		KLogf( 2, "Error saving categories: %s", err )
		Pointshop2.DB.DoQuery( "ROLLBACK" )
		Pointshop2.DB.SetBlocking( false )
		
		self:startView( "Pointshop2View", "displayError", ply, "A technical error occured, your changes could not be saved!" )
	else
		KLogf( 4, "Categories Updated" )
		Pointshop2.DB.DoQuery( "COMMIT" )
		Pointshop2.DB.SetBlocking( false )
		
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
			if not class then
				KLogf( 2, "[Pointshop2][Error] Blueprint %s: couldn't find baseclass", v.base )
				continue
			end
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
	local price = itemClass:GetBuyPrice( ply )
	
	if #ply.PS2_Inventory:getItems( ) >= ply.PS2_Inventory.numSlots then
		self:startView( "Pointshop2View", "displayError", ply, "Couldn't buy item, your inventory is full!" ) 
		return
	end
	
	/*
		Wrap everything into a blocking transaction to make sure we don't get duplicate stuff
		if mysql takes a little longer to respond and prevent any lua from queueing querys in 
		between.
		TODO: look into alternative methods of locking the database as this is a bit performance heavy because it blocks the game thread, 
	*/
	Pointshop2.DB.SetBlocking( true )
	Pointshop2.DB.DoQuery( "BEGIN" )
	:Fail( function( errid, err ) 
		KLogf( 2, "Error starting transaction: %s", err )
		self:startView( "Pointshop2View", "displayError", ply, "A Technical error occured, your purchase was not carried out." )
		error( "Error starting transaction:", err )
	end )
	
	if currencyType == "points" and price.points and ply.PS2_Wallet.points > price.points then
		ply.PS2_Wallet.points = ply.PS2_Wallet.points - price.points
	elseif currencyType == "premiumPoints" and price.premiumPoints and ply.PS2_Wallet.premiumPoints >= price.premiumPoints then
		ply.PS2_Wallet.premiumPoints = ply.PS2_Wallet.premiumPoints - price.premiumPoints
	else
		self:startView( "Pointshop2View", "displayError", ply, "You cannot purchase this item (insufficient " .. currencyType )
		return
	end
	
	ply.PS2_Wallet:save( )
	:Then( function( )
		local item = itemClass:new( )
		return item:save( )
	end )
	:Then( function( item )
		KInventory.ITEMS[item.id] = item
		return ply.PS2_Inventory:addItem( item )
		:Then( function( )
			item:OnPurchased( ply )
			self:startView( "Pointshop2View", "displayItemAddedNotify", ply, item )
		end )
	end )
	:Then( function( )
		KLogf( 4, "Player %s purchased item %s", ply:Nick( ), itemClass )
		Pointshop2.DB.DoQuery( "COMMIT" )
		Pointshop2.DB.SetBlocking( false )
		self:sendWallet( ply )
	end, function( errid, err )
		KLogf( 2, "Error saving item purchase: %s", err )
		Pointshop2.DB.DoQuery( "ROLLBACK" )
		Pointshop2.DB.SetBlocking( false )
		
		self:startView( "Pointshop2View", "displayError", ply, "A technical error occured (2), your purchase was not carried out." )
	end )
end

function Pointshop2Controller:sellItem( ply, itemId )
	Pointshop2.DB.SetBlocking( true )
	Pointshop2.DB.DoQuery( "BEGIN" )
	:Fail( function( errid, err ) 
		KLogf( 2, "Error starting transaction: %s", err )
		self:startView( "Pointshop2View", "displayError", ply, "A Technical error occured(1), your purchase was not carried out." )
		return
	end )
	
	
	local item = KInventory.ITEMS[itemId]
	if not item then
		KLogf( 3, "[WARN] Player %s tried to sell an item that wasn't cached (id %i)", ply:Nick( ), itemId )
		return
	end
	
	if not Pointshop2.PlayerOwnsItem( ply, item ) then
		self:startView( "Pointshop2View", "displayError", ply, "Couldn't sell item: You don't own this item." )
		return 
	end
	
	local slot
	for k, v in pairs( ply.PS2_Slots ) do
		if v.itemId == item.id then
			slot = v
		end
	end
	
	local def 
	if ply.PS2_Inventory:containsItem( item ) then
		def = ply.PS2_Inventory:removeItem( item ) --Unlink from inventory
	elseif slot then
		def = slot:removeItem( item ):Then( function( )
			self:startView( "Pointshop2View", "slotChanged", ply, slot )
		end )
	end
	
	def:Then( function( )
		item:OnHolster( ply )
		item:OnSold( ply )
		ply.PS2_Wallet.points = ply.PS2_Wallet.points + item:GetSellPrice( ply )
		return ply.PS2_Wallet:save( )
	end )
	:Then( function( ) 
		KInventory.ITEMS[item.id] = nil
		return item:remove( ) --remove the actual db entry
	end )
	:Then( function( )
		KLogf( 4, "Player %s sold an item", ply:Nick( ) )
		Pointshop2.DB.DoQuery( "COMMIT" )
		Pointshop2.DB.SetBlocking( false )
		self:sendWallet( ply )
	end, function( errid, err )
		KLogf( 2, "Error selling item: %s", err )
		Pointshop2.DB.DoQuery( "ROLLBACK" )
		Pointshop2.DB.SetBlocking( false )
		
		self:startView( "Pointshop2View", "displayError", ply, "A technical error occured (2), your sell was not carried out." )
	end )
end

function Pointshop2Controller:unequipItem( ply, slotName )
	local slot
	for k, v in pairs( ply.PS2_Slots ) do
		if v.slotName == slotName then
			slot = v
		end
	end
	
	if not slot then 
		KLogf( 3, "[ERROR] Player %s tried to unequipItem from uncached slot %s", ply:Nick( ), slotName )
		self:startView( "Pointshop2View", "displayError", ply, "Could not unequip item, " .. slotName .. " is not a valid equipment slot." )
		return
	end
	
	if not slot.itemId then
		KLogf( 3, "[ERROR] Player %s tried to unequipItem empty slot %s", ply:Nick( ), slotName )
		self:startView( "Pointshop2View", "displayError", ply, "Could not unequip item, " .. slotName .. " is empty!" )
		return
	end
	
	local item = KInventory.ITEMS[slot.itemId]
	if not item then 
		KLogf( 3, "[ERROR] Player %s tried to unequip an uncached Item %i", ply:Nick( ), slot.itemId )
		self:startView( "Pointshop2View", "displayError", ply, "Could not unequip item, Item not found in cache" )
		return
	end
	
	Pointshop2.DB.SetBlocking( true )
	Pointshop2.DB.DoQuery( "BEGIN" )
	
	ply.PS2_Inventory:addItem( item )
	:Then( function( )
		slot.itemId = nil
		slot.Item = nil
		return slot:save( )
	end )
	:Then( function( updatedSlot )
		item:OnHolster( ply )
		self:startView( "Pointshop2View", "playerUnequipItem", player.GetAll( ), ply, item.id )
		self:startView( "Pointshop2View", "slotChanged", ply, updatedSlot )
		
		Pointshop2.DB.DoQuery( "COMMIT" )
		Pointshop2.DB.SetBlocking( false )
	end, function( errid, err )
		self:reportError( "Pointshop2View", ply, "Error unequipping item", errid, err )
		
		Pointshop2.DB.DoQuery( "ROLLBACK" )
		Pointshop2.DB.SetBlocking( false )
	end )
end

function Pointshop2Controller:equipItem( ply, itemId, slotName )
	if not Pointshop2.IsValidEquipmentSlot( slotName ) then
		self:startView( "Pointshop2View", "displayError", ply, "Could not equip item, " .. slotName .. " is not a valid equipment slot." )
		KLogf( 3, "[Pointshop2][WARN] Player %s tried to equip item into invalid slot %s", ply:Nick( ), slotName )
		return
	end
	
	local item = KInventory.ITEMS[itemId]
	if not item then
		KLogf( 3, "[Pointshop2][WARN] Player %s tried to equip uncached item %i", ply:Nick( ), itemId )
		self:startView( "Pointshop2View", "displayError", ply, "Could not equip item: Item couldn't be found." )
		return
	end
	
	if not Pointshop2.PlayerOwnsItem( ply, item ) then
		KLogf( 3, "[Pointshop2][WARN] Player %s tried to equip foreign owned item %i", ply:Nick( ), itemId )
		self:startView( "Pointshop2View", "displayError", ply, "Could not equip item: You don't own this item." )
		return
	end
	
	if not Pointshop2.IsItemValidForSlot( item, slotName ) then
		KLogf( 3, "[Pointshop2][WARN] Player %s tried to equip item %i into slot %s (not valid for slot)", ply:Nick( ), itemId, slotName )
		self:startView( "Pointshop2View", "displayError", ply, "Could not equip item: You can't put it into this slot." )
		return
	end
	
	local slot
	for k, v in pairs( ply.PS2_Slots ) do
		if v.slotName == slotName then
			slot = v
		end
	end
	if not slot then
		slot = Pointshop2.EquipmentSlot:new( )
		slot.ownerId = ply.kPlayerId
		slot.slotName = slotName
		ply.PS2_Slots[slot.id] = slot
	end
	
	Pointshop2.DB.SetBlocking( true )
	Pointshop2.DB.DoQuery( "BEGIN" )
	
	local moveOldItemDef = Deferred( )
	if slot.itemId then
		local oldItem = KInventory.ITEMS[slot.itemId]
		if not oldItem then
			KLogf( 2, "[ERROR] Unsynced item %i in slot %s", slot.itemId, slot.slotName )
		end
		
		ply.PS2_Inventory:addItem( oldItem )
		:Then( function( )
			moveOldItemDef:Resolve( )
			oldItem:OnHolster( ply )
			self:startView( "Pointshop2View", "playerUnequipItem", player.GetAll( ), ply, oldItem.id )
		end, function( errid, err )
			moveOldItemDef:Reject( errid, err )
		end )
	else
		moveOldItemDef:Resolve( )
	end
	
	moveOldItemDef:Then( function( )
		slot.itemId = item.id
		slot.Item = item
		return slot:save( )
	end )
	:Then( function( slot )
		return ply.PS2_Inventory:removeItem( item ) --unlink from inventory
	end )
	:Then( function( )
		item:OnEquip( ply )
		
		slot.Item = item
		self:startView( "Pointshop2View", "slotChanged", ply, slot )
		
		self:startView( "Pointshop2View", "playerEquipItem", player.GetAll( ), ply, item )
		
		Pointshop2.DB.DoQuery( "COMMIT" )
		Pointshop2.DB.SetBlocking( false )
	end )
	:Fail( function( errid, err )
		self:reportError( "Pointshop2View", ply, "Error equipping item", errid, err )
		
		Pointshop2.DB.DoQuery( "ROLLBACK" )
		Pointshop2.DB.SetBlocking( false )
	end )
end

function Pointshop2Controller:loadOutfits( )
	WhenAllFinished{ Pointshop2.StoredOutfit.getAll( ), Pointshop2.StoredOutfit.getVersionHash( ) }
	:Then( function( outfits, versionHash )
		
		local outfitsAssoc = {}
		for k, v in pairs( outfits ) do
			outfitsAssoc[v.id] = v.outfitData
		end
		
		local data = LibK.von.serialize( { outfitsAssoc } )
		local resource = LibK.GLib.Resources.RegisterData( "Pointshop2", "outfits", data )
		resource:SetVersionHash( versionHash )
		KLogf( 4, "[Pointshop2] Outfit package loaded, version " .. versionHash .. " " .. #outfitsAssoc .. " outfits." )
		
		self:startView( "Pointshop2View", "loadOutfits", player.GetAll( ), versionHash )
	end )
end
Pointshop2.DatabaseConnectedPromise:Done( function( )
	Pointshop2Controller:loadOutfits( )
end )
function Pointshop2Controller:SendInitialOutfitPackage( ply )
	local resource = LibK.GLib.Resources.Resources["Pointshop2/outfits"]
	if not resource then
		KLogf( 4, "[Pointshop2] Outfit package not loaded yet, trying again later" )
		timer.Simple( 1, function( ) self:SendInitialOutfitPackage( ply ) end )
		return
	end
	self:startView( "Pointshop2View", "loadOutfits", player.GetAll( ), resource:GetVersionHash( ) )
end
hook.Add( "LibK_PlayerInitialSpawn", "InitialRequestOutfits", function( ply )
	timer.Simple( 1, function( )
		Pointshop2Controller:getInstance( ):SendInitialOutfitPackage( ply )
	end )
end )

function Pointshop2Controller:searchPlayers( ply, subject, attribute )
	local attributeTranslate = { ["Name"] = "name", ["Steam ID"] = "player", ["Profile ID"] = "steam64" }
	if not attributeTranslate[attribute] then
		local def = Deferred( )
		def:Reject( "Invalid attribute " .. attribute )
		return def:Promise( )
	end
	
	
	return LibK.Player.findPlayers( subject, attributeTranslate[attribute] )
	:Then( function( players ) 
		local ids = {}
		local playerNames = {}
		for k, v in pairs( players ) do
			table.insert( ids, tonumber( v.id ) )
			table.insert( playerNames, { id = v.id, name = v.name, lastConnected = v.updated_at } )
		end
		
		local def = Deferred( )
		
		if #ids == 0 then
			def:Resolve( {} )
			return def:Promise( )
		end
		
		Pointshop2.Wallet.getDbEntries( "WHERE ownerId IN (" .. table.concat( ids, ', ' ) .. ")" )
		:Done( function( wallets )
			for k, v in pairs( playerNames ) do
				for _, wallet in pairs( wallets ) do
					if wallet.ownerId == v.id then
						v.Wallet = wallet
					end
				end
			end
			def:Resolve( playerNames )
		end )
		:Fail( function( errid, err )
			def:Fail( 1, "Error fetching wallets: " .. err )
		end	)
		
		return def:Promise( )
	end )
end

function Pointshop2Controller:getUserDetails( ply, kPlayerId )
	local def = Deferred( )
	
	WhenAllFinished{ LibK.Player.findById( kPlayerId ), 
					 Pointshop2.Wallet.findByOwnerId( kPlayerId ), 
					 KInventory.Inventory.findByOwnerId( kPlayerId )
	}:Then( function( ply, wallet, inventory )
		ply.wallet = wallet
		ply.inventory = inventory
		return inventory:loadItems( )
		:Then( function( )
			return ply
		end )
	end )
	:Done( function( plyInfo )
		def:Resolve( plyInfo )
	end )
	:Fail( function( errid, err )
		def:Reject( errid, err )
	end )
	
	return def:Promise( )
end