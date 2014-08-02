Pointshop2View = class( "Pointshop2View" )
Pointshop2View.static.controller = "Pointshop2Controller" 
Pointshop2View:include( BaseView )

hook.Add( "InitPostEntity", "InitializePlayers", function( )
	for k, ply in pairs( player.GetAll( ) ) do
		ply.PS2_EquippedItems = ply.PS2_EquippedItems or {}
		ply.PS2_Slots = {}
	end
	LocalPlayer().PS2_Inventory = {}
	
	Pointshop2View:getInstance( ) --Create the view
end )

local GLib = LibK.GLib

function Pointshop2View:initialize( )
	--Dynamic Properties
	self.itemMappings = {}
	self.itemCategories = {}
	self.itemProperties = {}
	
	self.fullyInitialized = false
	
	self.clPromises = {
		InventoryReceived = Deferred( ),
		OutfitsReceived = Deferred( ),
		SettingsReceived = Deferred( ),
		DynamicsReceived = Deferred( )
	}
	
	local promises = {}
	for k, v in pairs( self.clPromises ) do
		table.insert( promises, v:Promise( ) )
	end
	
	Pointshop2.ClInitialized = WhenAllFinished( promises )
	
	Pointshop2.ClInitialized:Done( function( )
		self.fullyInitialized = true
		KLogf( 5, "[Pointshop2] Pointshop2 is now ready for use" )
	end )
end

local function resolveIfWaiting( deferred )
	if deferred._promise._state == "pending" then
		deferred:Resolve( )
	end
end

function Pointshop2View:toggleMenu( )
	if self.loaderAttached then	
		--In the loading message, handlers are already registered
		return 
	end
	
	if self.fullyInitialized then
		Pointshop2:ToggleMenu( )
	else
		self.loaderAttached = true
		
		local f = vgui.Create("DFrame" )
		f:SetSkin( Pointshop2.Config.DermaSkin )
		f:SetSize( 300, 130 )
		f:SetPos( ScrW() / 2 - f:GetWide( ) / 2, 0 )
		f:SetTitle( "Pointshop 2" )
		
		local lbl = vgui.Create( "DLabel", f )
		lbl:SetText( "Loading Pointshop2, please wait a second.\nThe menu will open automatically." )
		lbl:Dock( TOP )
		lbl:SizeToContents( )
		
		local loading = vgui.Create( "DLoadingNotifier", f )
		loading:Dock( TOP )
		loading:Expand( )
		
		Pointshop2.ClInitialized:Done( function( )
			Pointshop2:ToggleMenu( ) --Open the menu
		end )
		:Fail( function( errid, err )
			self:displayError( "There was an error loading Pointshop 2. Please tell an admin: " .. errid .. ": " .. err, "Error" )
		end )
		:Always( function( )
			f:Remove( )
			self.loaderAttached = false
		end )
	end
end

function Pointshop2View:walletChanged( newWallet )
	local ply
	for k, v in pairs( player.GetAll( ) ) do
		if v:GetNWInt( "KPlayerId" ) == newWallet.ownerId then
			v.PS2_Wallet = newWallet
			KLogf( 5, "[PS2] Received Wallet of %s: %i pts, %i premPts", v:Nick( ), newWallet.points, newWallet.premiumPoints )
			ply = v
		end
	end
	hook.Run( "PS2_WalletChanged", newWallet, ply ) 
end 

function Pointshop2View:receiveInventory( inventory )
	InventoryView:getInstance( ):receiveInventory( inventory ) --Needed for KInventory to work properly
	LocalPlayer().PS2_Inventory = inventory
	KLogf( 5, "[PS2] Received Inventory, %i items", #inventory:getItems( ) )
	
	resolveIfWaiting( self.clPromises.InventoryReceived )
end

function Pointshop2View:itemChanged( item )
	local found
	for k, v in pairs( LocalPlayer().PS2_Inventory.Items ) do
		if v.id == item.id then
			found = true
			if item.inventory_id != LocalPlayer().PS2_Inventory.id then
				--Item was removed
				LocalPlayer().PS2_Inventory.Items[k] = item
				hook.Run( "PS2_ItemRemoved", item )
			else
				--Item was updated
				LocalPlayer().PS2_Inventory.Items[k] = item
				hook.Run( "PS2_ItemUpdated", item )
			end
		end
	end
	
	if not found then
		--Item was added
		LocalPlayer().PS2_Inventory:addItem( item )
	end
end

function Pointshop2View:receiveSlots( slots )
	LocalPlayer().PS2_Slots = LocalPlayer().PS2_Slots or {}
	for k, v in pairs( slots ) do
		LocalPlayer().PS2_Slots[v.slotName] = v.Item
	end

	KLogf( 5, "[PS2] Received slots, %i slots", #slots )
end

function Pointshop2View:slotChanged( slot )
	LocalPlayer().PS2_Slots[slot.slotName] = slot.Item
	hook.Run( "PS2_SlotChanged", slot )
end

function Pointshop2View:startBuyItem( itemClass, currencyType )
	self:controllerAction( "buyItem", itemClass.className, currencyType )
end

function Pointshop2View:startSellItem( item )
	self:controllerTransaction( "sellItem", item.id )
	:Done( function( )
		--TODO: Sound
		--Reset selection
		hook.Run( "PS2_InvItemIconSelected" )
	end )
	:Fail( function( err )
		self:displayError( "Error selling the item: " .. err, "Error" )
	end )
end


function Pointshop2View:receiveDynamicProperties( itemMappings, itemCategories, itemProperties )
	KLogf( 5, "[PS2] Received Dynamic Properties, %i items in %i categories (%i props)", #itemMappings, #itemCategories, #itemProperties )
	self.itemMappings = itemMappings
	self.itemCategories = itemCategories
	self.itemProperties = itemProperties
	
	--Load persistent items
	for k, v in pairs( self.itemProperties ) do
		Pointshop2.LoadPersistentItem( v )
	end
	
	--Create Tree from the information
	local categoryItemsTable = {}
	for k, dbCategory in pairs( self.itemCategories ) do
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
		for k, dbItemMapping in pairs( self.itemMappings ) do
			if dbItemMapping.categoryId == newCategory.self.id then
				table.insert( newCategory.items, dbItemMapping.itemClass )
			end
		end
		
		--Put it in the right place into the tree
		if not dbCategory.parent then
			--Create Category in root
			table.insert( categoryItemsTable, newCategory )
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
	self.categoryItemsTable = categoryItemsTable
	
	local function sortCategories( cat )
		table.sort( self.categoryItemsTable, function( a, b )
			return a.self.id < b.self.id
		end )
	end
	sortCategories( cat )
	
	--Hacky, dunno why this is needed
	hook.Call( "PS2_DynamicItemsUpdated" )
	timer.Simple( 0.1, function( )
		hook.Call( "PS2_DynamicItemsUpdated" )
	end )
	
	resolveIfWaiting( self.clPromises.DynamicsReceived )
end

function Pointshop2View:loadDynamics( versionHash )
	GLib.Resources.Resources["Pointshop2/dynamics"] = nil --Force resource reset
	GLib.Resources.Get( "Pointshop2", "dynamics", versionHash, function( success, data )
		if not success then 
			KLogf( 2, "[PS2][ERROR] Couldn't load dynamics resouce!" )
			return
		end
		local dynamicsDecoded = LibK.von.deserialize( data )[1]
		KLogf( 5, "[PS2] Decoded dynamic info from resource (version %s)", versionHash ) 
		
		--Back to classes
		LibK.processNetTable( dynamicsDecoded[1] )
		LibK.processNetTable( dynamicsDecoded[2] )
		LibK.processNetTable( dynamicsDecoded[3] )
		
		--Pass to view
		self:receiveDynamicProperties( dynamicsDecoded[1], dynamicsDecoded[2], dynamicsDecoded[3] )
		
		--Inform server
		self:controllerAction( "dynamicsReceived" )
	end )
end

--This is a bit confusing, sorry
function Pointshop2View:getPersistenceForClass( itemClass )
	if itemClass._persistenceId == "STATIC" then
		return "STATIC"
	end
	for k, v in pairs( self.itemProperties ) do
		local persistenceClass = Pointshop2.GetPersistenceClassForItemClass( itemClass )
		if v.id == itemClass._persistenceId and instanceOf( persistenceClass, v ) then
			return v
		end
	end
	return nil
end

function Pointshop2View:saveCategoryOrganization( categoryItemsTable )
	self:controllerAction( "saveCategoryOrganization", categoryItemsTable )
end

function Pointshop2View:equipItem( item, slotName )
	if item then
		if LocalPlayer().PS2_Slots[slotName] and LocalPlayer().PS2_Slots[slotName].id == item.id then
			return
		end
		self:controllerAction( "equipItem", item.id, slotName )
	else
		self:controllerAction( "unequipItem", slotName )
	end
end

function Pointshop2View:displayItemAddedNotify( item )
	local notify = vgui.Create( "DNewItemPopup" )
	notify:SetItem( item )
	notify:MakePopup( )
	notify:InvalidateLayout( true )
	notify:Center( )
end

function Pointshop2View:getCategoryOrganization( )
	if not self.categoryItemsTable then
		return KLogf( 2, "[PS2] Couldn't create items table: nothing received from server yet!" )
	end
	
	return self.categoryItemsTable
end

function Pointshop2View:getUncategorizedItems( )
	local uncategorized = {}
	for _, itemClass in pairs( Pointshop2:GetRegisteredItems( ) ) do
		local found = false
		for _, itemMapping in pairs( self.itemMappings ) do
			if itemMapping.itemClass == itemClass.className then
				found = true
			end
		end
		if not found then 
			table.insert( uncategorized, itemClass )
		end
	end
	return uncategorized
end

function Pointshop2View:createPointshopItem( saveTable )
	self:controllerAction( "saveModuleItem", saveTable )
end

local ITEMS = {}
setmetatable( ITEMS, { __mode = 'v' } ) --weak reference holder

function Pointshop2View:playerEquipItem( ply, item )
	ply.PS2_EquippedItems = ply.PS2_EquippedItems or {}
	ply.PS2_EquippedItems[item.id] = item
	item:OnEquip( ply )
	ITEMS[item.id] = item
	hook.Run( "PS2_ItemEquipped", ply, item )
end

function Pointshop2View:playerUnequipItem( ply, itemId )
	if ITEMS[itemId] then
		ITEMS[itemId]:OnHolster( ply )
		ply.PS2_EquippedItems[itemId] = nil
	end
	hook.Run( "PS2_ItemUnequipped", ply, item )
end

function Pointshop2View:loadOutfits( versionHash )
	LibK.GLib.Resources.Resources["Pointshop2/outfits"] = nil --Force resource reset
	LibK.GLib.Resources.Get( "Pointshop2", "outfits", versionHash, function( success, data )
		if not success then 
			KLogf( 2, "[PS2][ERROR] Couldn't load outfits resouce!" )
			return
		end
		Pointshop2.Outfits = LibK.von.deserialize( data )[1]
		KLogf( 5, "[PS2] Decoded %i outfits from resource (version %s)", #Pointshop2.Outfits, versionHash ) 
		self:controllerAction( "outfitsReceived" )

		resolveIfWaiting( Pointshop2View:getInstance( ).clPromises.OutfitsReceived )
	end )
end

function Pointshop2View:searchPlayers( subject, attribute )
	return self:controllerTransaction( "searchPlayers", subject, attribute )
end

function Pointshop2View:getUserDetails( kPlayerId )
	if not kPlayerId or not type( kPlayerId ) == "number" then
		error( "Invalid Call" )
		debug.Trace( )
		return
	end
	return self:controllerTransaction( "getUserDetails", kPlayerId )
end

function Pointshop2View:adminChangeWallet( kPlayerId, currencyType, newValue )
	return self:controllerTransaction( "adminChangeWallet", kPlayerId, currencyType, newValue )
end

function Pointshop2View:addToPointFeed( message, points, small )
	Pointshop2.PointFeed:AddPointNotification( message, points, small )
end

function Pointshop2View:loadSettings( versionHash )
	GLib.Resources.Resources["Pointshop2/settings"] = nil --Force resource reset
	GLib.Resources.Get( "Pointshop2", "settings", versionHash, function( success, data )
		if not success then 
			KLogf( 2, "[PS2][ERROR] Couldn't load settings resouce!" )
			return
		end
		Pointshop2.Settings.Shared = LibK.von.deserialize( data )[1]
		KLogf( 5, "[PS2] Decoded settings from resource (version %s)", versionHash ) 
		
		resolveIfWaiting( Pointshop2View:getInstance( ).clPromises.SettingsReceived )
		hook.Run( "PS2_SettingsUpdated" )
	end )
end

function Pointshop2View:saveSettings( mod, realm, settingsTbl )
	local outBuffer = GLib.StringOutBuffer( )
	outBuffer:String( mod.Name )
	outBuffer:String( realm )
	outBuffer:LongString( LibK.von.serialize( settingsTbl ) )
	
	GLib.Transfers.Send( GLib.GetServerId( ), "Pointshop2.SettingsUpdate", outBuffer:GetString( ) )	
end

function Pointshop2View:sendPoints( ply, points )
	self:controllerAction( "sendPoints", ply, points )
end

function Pointshop2View:resetToDefaults( )
	self:controllerAction( "resetToDefaults" )
end

function Pointshop2View:fixDatabase( )
	self:controllerAction( "fixDatabase" )
end

function Pointshop2View:removeItem( itemClass, refund )
	self:controllerTransaction( "removeItem", itemClass.className, refund )
	:Done( function( )
		KInventory.Items[itemClass.className] = nil
	end )
end

function Pointshop2View:installDefaults( )
	self:controllerAction( "installDefaults" )
end