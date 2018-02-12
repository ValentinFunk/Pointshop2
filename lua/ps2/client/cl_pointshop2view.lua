Pointshop2View = class( "Pointshop2View" )
Pointshop2View.static.controller = "Pointshop2Controller"
Pointshop2View:include( BaseView )

LibK.InitPostEntityPromise:Done( function( )
	for k, ply in pairs( player.GetAll( ) ) do
		ply.PS2_EquippedItems = ply.PS2_EquippedItems or {}
		ply.PS2_Slots = ply.PS2_Slots or {}
	end
	LocalPlayer().PS2_Inventory = LocalPlayer().PS2_Inventory or {}

	timer.Simple( 0.5, function( )
		Pointshop2View:getInstance( ) --Create the view
	end )
end )

local GLib = LibK.GLib

function Pointshop2View:initialize( )
	self.SlotChanges = {} -- Prevents uncaching of items during slot changes

	--Dynamic Properties
	self.itemMappings = {}
	self.itemCategories = {}
	self.itemProperties = {}

	self.fullyInitialized = false

	self.clPromises = {
		InventoryReceived = Deferred( ),
		OutfitsReceived = Deferred( ),
		SettingsReceived = Deferred( ),
		DynamicsReceived = Deferred( ),
		SlotsReceived = Deferred( )
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

local function notifyError()
	if not IsValid(LocalPlayer()) then
		timer.Simple(2, notifyError)
		return
	end

	if LocalPlayer():IsAdmin() and ( not pac or not pace ) then
		Pointshop2View:getInstance():displayError( "[CRITICAL][ADMIN ONLY] PAC3 is not installed correctly. Expect errors! Please install PAC3 from GitHub: bit.ly/getpac3", 1000 )
	end

	if LocalPlayer():IsAdmin() and ( not pac.FlashlightDisable or not pace.selectControl ) then
		Pointshop2View:getInstance():displayError( "[CRITICAL][ADMIN ONLY] Your PAC3 version is outdated and will cause errors. Please download the newest PAC version from GitHub: bit.ly/getpac3.", 1000 )
	end
end
hook.Add("InitPostEntity", "ErrorNotifier", function() timer.Simple(2, notifyError) end)

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
		local startTime = SysTime( )
		Pointshop2:ToggleMenu( )
		KLogf( 5, "[Pointshop 2] Menu opened in %s", LibK.GLib.FormatDuration( SysTime() - startTime ) )
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
			self:displayError( "There was an error loading Pointshop 2. Please tell an admin: " .. errid .. ": " .. err )
		end )
		:Always( function( )
			f:Remove( )
			self.loaderAttached = false
		end )
	end
end

function Pointshop2View:showRepairDatabase( message )
	local notification = vgui.Create( "KNotificationPanel" )
	notification:setText( message )
	notification:setIcon( "icon16/exclamation.png" )
	notification.sound = "kreport/electric_deny2.wav"
	notification:SetSkin( Pointshop2.Config.DermaSkin )
	notification.duration = 360

	local btn = vgui.Create( "DButton", notification )
	btn:SetText( "Repair Database" )
	function btn.DoClick() 
		self:controllerAction( "fixDatabase" )
	end
	btn:SizeToContents()
	btn:Dock( TOP )
	btn:DockMargin( 5, 5, 5, 5 )
	btn:SetTall( 30 )
	notification:SetMouseInputEnabled( true )
	btn:SetMouseInputEnabled( true )

	LocalPlayer( ).notificationPanel:addNotification( notification )
end

function Pointshop2View:HandleDecodeError( func, errClass )
	KLogf( 1, "Error decoding call for %s, faulty class %s", func, errClass )
	if not LocalPlayer():IsAdmin() then
		self:displayError( "There was an error loading Pointshop 2 Data. Please tell an admin: Error calling " .. func .. " faulty class: " .. errClass )
	else
		self:showRepairDatabase( "[ADMIN ONLY] There was an error loading Pointshop 2 Data. The recommended step is to try repairing the database. The worst thing that can happen is that some items end up in uncategorized.\nIf you want to be 100% sure please take a database backup before running the repair!\n You need reset permissions to be able to perform this action." )
	end
end

function Pointshop2View:walletChanged( newWallet, tries )
	tries = tries or 0
	local ply
	for k, v in pairs( player.GetAll( ) ) do
		if v:GetNWInt( "KPlayerId" ) == newWallet.ownerId then
			v.PS2_Wallet = newWallet
			KLogf( 5, "[PS2] Received Wallet of %s: %i pts, %i premPts", v:Nick( ), newWallet.points, newWallet.premiumPoints )
			ply = v
		end
	end
	if not ply and tries < 100 then
		timer.Simple( 0.5, function( )
			self:walletChanged( newWallet, tries + 1 )
		end )
	end
	hook.Run( "PS2_WalletChanged", newWallet, ply )
end

function Pointshop2View:adminRemoveItem( ply, itemId )
	return self:controllerTransaction( "adminRemoveItem", itemId )
end

function Pointshop2View:receiveInventory( inventory )
	InventoryView:getInstance( ):receiveInventory( inventory ) --Needed for KInventory to work properly
	LocalPlayer().PS2_Inventory = inventory
	KLogf( 5, "[PS2] Received Inventory, %i items", #inventory:getItems( ) )
	for k, v in pairs( inventory:getItems( ) ) do
		KInventory.ITEMS[v.id] = v
	end
	hook.Run( "PS2_InvUpdate" )
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
				for _, v in pairs( item ) do
					LocalPlayer().PS2_Inventory.Items[k][_] = v
				end
				hook.Run( "PS2_ItemUpdated", LocalPlayer().PS2_Inventory.Items[k] )
				print( "Updated ", k )
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
		if v.Item then
			LocalPlayer().PS2_Slots[v.slotName] = v.Item
			KInventory.ITEMS[v.Item.id] = v.Item
		end
		hook.Run( "PS2_SlotChanged", v )
	end

	KLogf( 5, "[PS2] Received slots, %i slots", #slots )
	resolveIfWaiting( self.clPromises.SlotsReceived )
end

function Pointshop2View:slotChanged( slot )
	slot.Item = slot.Item and KInventory.ITEMS[slot.Item.id]
	LocalPlayer().PS2_Slots[slot.slotName] = slot.Item
	hook.Run( "PS2_SlotChanged", slot )

	if slot.Item then
		self.SlotChanges[slot.Item.id] = true
	end
end

function Pointshop2View:startBuyItem( itemClass, currencyType )
	return self:controllerTransaction( "buyItem", itemClass.className, currencyType )
	:Fail( function( err )
		self:displayError( "Error buying the item: " .. err )
	end )
end

function Pointshop2View:startSellItem( item )
	local def = Deferred()
	if Pointshop2.ClientSettings.GetSetting( "BasicSettings.AutoconfirmSale" ) then
		def:Resolve( true )
	else
		Derma_Query( "Are you sure you want to sell " .. item:GetPrintName() .. "?", "Selling an item", "Yes", function()
			def:Resolve( true )
		end, "No", function()
			def:Resolve( false )
		end )
	end

	return def:Promise( ):Then( function( confirmed )
		if confirmed then
			return self:controllerTransaction( "sellItem", item.id ):Done( function( )
				--TODO: Sound
				--Reset selection
				hook.Run( "PS2_InvItemIconSelected" )
			end )
		end
	end ):Fail( function( err )
		self:displayError( "Error selling the item: " .. err )
	end )
end

function Pointshop2View:receiveDynamicProperties( itemMappings, itemCategories, itemProperties )
	KLogf( 5, "[PS2] Received Dynamic Properties, %i items in %i categories (%i props)", #itemMappings, #itemCategories, #itemProperties )
	self.itemMappings = itemMappings
	self.itemCategories = itemCategories
	self.itemProperties = itemProperties

	return Pointshop2View:getInstance( ).clPromises.SettingsReceived:Then( function()
		--Load persistent items
		local startTime = SysTime( )
		for k, v in pairs( self.itemProperties ) do
			Pointshop2.LoadPersistentItem( v )
		end
		KLogf( 5, "[Pointshop 2] Persistent items loaded in %s", LibK.GLib.FormatDuration( SysTime() - startTime ) )

		local startTime = SysTime( )
		local tree = Pointshop2.BuildTree( self.itemCategories, self.itemMappings )
		KLogf( 5, "[Pointshop 2] Tree created in %s", LibK.GLib.FormatDuration( SysTime() - startTime ) )

		self.categoryItemsTable = tree or {}

		--Hacky, dunno why this is needed
		--hook.Call( "PS2_DynamicItemsUpdated" )
		timer.Simple( 0.1, function( )
			local startTime = SysTime( )
			hook.Call( "PS2_DynamicItemsUpdated" )
			KLogf( 5, "[Pointshop 2] Hook run in %s", LibK.GLib.FormatDuration( SysTime() - startTime ) )
		end )

		resolveIfWaiting( self.clPromises.DynamicsReceived )
	end )
end

/*
	Called when a shop item (item persistence) has been updated
*/
function Pointshop2View:updateItemPersistences( itemPersistences )
	if not self.itemProperties then
		KLogf(3, "[WARN] Player received item update but items weren't loaded yet")
		return
	end

	for _, itemPersistence in pairs( itemPersistences ) do
		-- Update persistence object cache
		for k, v in pairs( self.itemProperties ) do
			if v.itemPersistenceId == itemPersistence.itemPersistenceId then
				self.itemProperties[k] = itemPersistence
			end
		end
		
		-- Update class (KInventory.Items[id])
		local itemClass = Pointshop2.LoadPersistentItem( itemPersistence )
	
		-- Regenerate item
		if LibK.DermaInherits( itemClass:GetPointshopIconControl( ), "DCsgoItemIcon" ) then
			Pointshop2.RequestIcon( itemClass, true )
		end

		KLogf( 5, "[Pointshop 2] Reloaded item %s", itemPersistence.ItemPersistence.name )
	end

	-- Update Shop
	timer.Simple( 0.1, function( )
		local startTime = SysTime( )
		hook.Call( "PS2_DynamicItemsUpdated" )
		KLogf( 5, "[Pointshop 2] Hook run in %s", LibK.GLib.FormatDuration( SysTime() - startTime ) )
	end )
end

function Pointshop2View:loadDynamics( versionHash )
	GLib.Resources.Resources["Pointshop2/dynamics"] = nil --Force resource reset
	GLib.Resources.Get( "Pointshop2", "dynamics", versionHash, function( success, data )
		if not success then
			KLogf( 2, "[PS2][ERROR] Couldn't load dynamics resouce!" )
			return
		end

		local startTime = SysTime( )
		local dynamicsDecoded = util.JSONToTable( data )[1]
		KLogf( 5, "[PS2] Decoded dynamic info from resource (version %s) %s", versionHash, LibK.GLib.FormatDuration( SysTime() - startTime ) )

		self.dynamicsDecoded = dynamicsDecoded
		
		--Back to classes
		LibK.processNetTable( dynamicsDecoded[1] )
		LibK.processNetTable( dynamicsDecoded[2] )
		LibK.processNetTable( dynamicsDecoded[3] )

		--Pass to view
		local dynamicsHandled = self:receiveDynamicProperties( dynamicsDecoded[1], dynamicsDecoded[2], dynamicsDecoded[3] )

		--Inform server
		local kPlayerIdValid = Deferred()
		timer.Create( "CheckValidPlayerId", 0.1, 0, function()
			local loaded = true
			for k, v in pairs( player.GetAll( ) ) do
				if v == LocalPlayer( ) && v:GetNWInt("KPlayerId", -1) == -1 then
					loaded = false
				end
			end
			if loaded then
				kPlayerIdValid:Resolve( )
				timer.Destroy( "CheckValidPlayerId" )
			end
		end )
		WhenAllFinished{
			kPlayerIdValid:Promise(),
			dynamicsHandled
		}:Then(function()
			self:controllerAction( "dynamicsReceived" )
			KLogf(5, "[Pointshop 2] Dynamics loaded, ready to receive server calls")
		end)
	end )
end

function Pointshop2View:getPersistenceForClass( itemClass )
	if itemClass._persistenceId == "STATIC" then
		return "STATIC"
	end
	local persistenceClass = Pointshop2.GetPersistenceClassForItemClass( itemClass )
	for k, v in pairs( self.itemProperties ) do
		if v.id == itemClass._persistenceId and instanceOf( persistenceClass, v ) then
			return v
		end
	end
	return nil
end

function Pointshop2View:saveCategoryOrganization( categoryItemsTable )
	LibK.GLib.Transfers.Send( 0, "Pointshop2.CategoryOrganization", util.TableToJSON( categoryItemsTable ) )
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

function Pointshop2View:displayItemAddedNotify( item, text )
	local notification = vgui.Create( "DItemReceivedNotification" )
	notification:SetItem( item )
	if text and isstring( text ) then
		notification.lbl:SetText( text )
	end
	LocalPlayer( ).notificationPanel:addNotification( notification )
end

function Pointshop2View:getCategoryOrganization( )
	if not self.categoryItemsTable then
		return KLogf( 2, "[PS2] Couldn't create items table: nothing received from server yet!" )
	end

	return self.categoryItemsTable
end

function Pointshop2View:getShopCategory( )
	if not self.categoryItemsTable then
		return KLogf( 2, "[PS2] Couldn't create items table: nothing received from server yet!" )
	end

	for k, v in pairs( self.categoryItemsTable.subcategories or {} ) do
		if v.self.label == "Shop Categories" then
			return v
		end
	end

	return {
		items = {},
		subcategories = {}
	}
end

function Pointshop2View:getNoSaleCategory( )
	if not self.categoryItemsTable then
		return KLogf( 2, "[PS2] Couldn't create items table: nothing received from server yet!" )
	end

	for k, v in pairs( self.categoryItemsTable.subcategories or {} ) do
		if v.self.label == "Not for sale Items" then
			return v
		end
	end

	return {
		items = {},
		subcategories = {}
	}
end

function Pointshop2View:RegenerateIcons( )
	for _, itemClass in pairs( Pointshop2:GetRegisteredItems( ) ) do
		if not derma.Controls[itemClass:GetPointshopIconControl()] then
			print(itemClass:GetPointshopIconControl())
			continue
		end

	 	if LibK.DermaInherits( itemClass:GetPointshopIconControl(), "DCsgoItemIcon" ) then
			Pointshop2.RequestIcon( itemClass, true )
		end
	end
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
	hook.Run( "PS2_PreReload" )
	self:controllerAction( "saveModuleItem", saveTable )
end

Pointshop2.ITEMS = {}
//setmetatable( Pointshop2.ITEMS, { __mode = 'v' } ) --weak reference holder

function Pointshop2View:playerEquipItem( kPlayerId, item, isRetry )
	isRetry = isRetry or 0

	local ply
	for k, v in pairs( player.GetAll( ) ) do
		if tonumber( v:GetNWInt( "KPlayerId" ) ) == tonumber( kPlayerId ) then
			ply = v
		end
	end

	if not IsValid( ply ) then
		if isRetry >= 10 then
			KLogf( 4, "[PS2] Couldn't get it on retry D:" )
			return
		end
		if isRetry < 10 then
			KLogf( 4, "[PS2] Player equip on player that is not valid, trying again in 3s" )
			timer.Simple( 3, function( )
				self:playerEquipItem( kPlayerId, item, isRetry + 1 )
			end )
		end
		return
	end

	if KInventory.ITEMS[item.id] then
		item = KInventory.ITEMS[item.id]
	end

	ply.PS2_EquippedItems = ply.PS2_EquippedItems or {}
	ply.PS2_EquippedItems[item.id] = item
	item.owner = ply
	if not IsValid( item:GetOwner() ) then
		debug.Trace( )
		ErrorNoHalt( "Error in 0" )
	end

	--Delay to next frame to clear stack
	timer.Simple( 0, function( )
		item:OnEquip( )
	end )

	Pointshop2.ITEMS[item.id] = item

	if item.class:IsValidForServer( Pointshop2.GetCurrentServerId() ) then
		Pointshop2.ActivateItemHooks(item)
		hook.Run( "PS2_ItemEquipped", ply, item )
	end
end

function Pointshop2View:playerUnequipItem( ply, itemId )
	if Pointshop2.ITEMS[itemId] then
		Pointshop2.ITEMS[itemId]:OnHolster( ply )
		if ply.PS2_EquippedItems then
			ply.PS2_EquippedItems[itemId] = nil
		end
		hook.Run( "PS2_ItemUnequipped", ply, Pointshop2.ITEMS[itemId] )
		Pointshop2.DeactivateItemHooks(Pointshop2.ITEMS[itemId])
	end
end

function Pointshop2View:loadOutfits( versionHash )
	LibK.GLib.Resources.Resources["Pointshop2/outfits"] = nil --Force resource reset
	LibK.GLib.Resources.Get( "Pointshop2", "outfits", versionHash, function( success, data )
		if not success then
			KLogf( 2, "[PS2][ERROR] Couldn't load outfits resouce!" )
			return
		end
		Pointshop2.Outfits = util.JSONToTable( data )[1]
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
		Pointshop2.Settings.Shared = util.JSONToTable( data )[1]
		KLogf( 5, "[PS2] Decoded settings from resource (version %s)", versionHash )

		resolveIfWaiting( Pointshop2View:getInstance( ).clPromises.SettingsReceived )
		hook.Run( "PS2_OnSettingsUpdate" )
	end )
end

function Pointshop2View:saveSettings( mod, realm, settingsTbl )
	self.settingsPromises = self.settingsPromises or {}
	self.settingsPromises[mod.Name] = Deferred( )

	local outBuffer = GLib.StringOutBuffer( )
	outBuffer:String( mod.Name )
	outBuffer:String( realm )
	outBuffer:LongString( util.TableToJSON( settingsTbl ) )

	GLib.Transfers.Send( GLib.GetServerId( ), "Pointshop2.SettingsUpdate", outBuffer:GetString( ) )
	hook.Run( "PS2_SettingsSavingStart" )
	return self.settingsPromises[mod.Name]:Promise( )
end

-- This is called when a client saves serverside settings. Used to create visual indicator
-- of server settings saving.
function Pointshop2View:serverSettingsSaved( modName, err )
	if self.settingsPromises then
		if err then
			self.settingsPromises[modName]:Reject( err )
		else
			self.settingsPromises[modName]:Resolve( )
		end
	end
	hook.Run("PS2_ServerSettingsSaved")
end

function Pointshop2View:sendPoints( ply, points )
	return self:controllerTransaction( "sendPoints", ply, points )
end

function Pointshop2View:resetToDefaults( )
	self:controllerAction( "resetToDefaults" )
end

function Pointshop2View:fixDatabase( )
	self:controllerAction( "fixDatabase" )
end

function Pointshop2View:removeItem( itemClass, refund )
	hook.Run( "PS2_PreReload" )

	self:controllerTransaction( "removeItem", itemClass.className, refund )
	:Done( function( )
		KInventory.Items[itemClass.className] = nil
	end )
end

function Pointshop2View:removeItems( itemClasses, refund )
	hook.Run( "PS2_PreReload" )

	local classNames = {}
	for k, v in pairs( itemClasses ) do
		table.insert( classNames, v.className )
	end

	self:controllerTransaction( "removeItems", classNames, refund )
	:Done( function( removedNames )
		for k, className in pairs( removedNames ) do
			KInventory.Items[className] = nil
		end
	end )
end

function Pointshop2View:installDefaults( )
	self:controllerAction( "installDefaults" )
end

function Pointshop2View:installDlcPack( name )
	self:controllerAction( "installDlcPack", name )
end

function Pointshop2View:getServers( )
	return self:controllerTransaction( "adminGetServers" )
end

function Pointshop2View:migrateServer( server )
	return self:controllerTransaction( "migrateServer", server.id )
end

function Pointshop2View:removeServer( server )
	return self:controllerTransaction( "removeServer", server.id )
end

function Pointshop2View:updateServerRestrictions( itemClassNames, serverIds )
	hook.Run( "PS2_PreReload" )
	self:controllerAction( "updateServerRestrictions", itemClassNames, serverIds )
end

function Pointshop2View:requestMaterials( directory )
	return self:controllerTransaction( "requestMaterials", directory )
end

function Pointshop2View:adminGiveItem( kPlayerId, itemClass )
	return self:controllerTransaction( "adminGiveItem", kPlayerId, itemClass )
end

function Pointshop2View:displayInformation( infoStr, duration )
	local notification = vgui.Create( "KNotificationPanel" )
	notification:setText( infoStr )
	notification:setIcon( "icon16/information.png" )
	notification:SetSkin( "KReport" )
	notification.sound = "kreport/retro_deny.wav"
	if duration then
		notification.duration = duration
	end
	LocalPlayer( ).notificationPanel:addNotification( notification )

	return notification
end

function Pointshop2View:displayError( infoStr, duration )
	local notification = vgui.Create( "KNotificationPanel" )
	notification:setText( infoStr )
	notification:setIcon( "icon16/exclamation.png" )
	notification.sound = "kreport/electric_deny2.wav"
	notification:SetSkin( "KReport" )
	if duration then
		notification.duration = duration
	end
	LocalPlayer( ).notificationPanel:addNotification( notification )

	return notification
end

function Pointshop2View:updateRankRestrictions( itemClassNames, validRanks )
	hook.Run( "PS2_PreReload" )
	self:controllerAction( "updateRankRestrictions", itemClassNames, validRanks )
end