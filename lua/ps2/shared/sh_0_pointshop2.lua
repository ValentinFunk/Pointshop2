Pointshop2 = KInventory --mean hack to share databases, Pointshop2 = {}

--[[
	Pointshop2 Main file, last modifed on 19.01.2018, Revision {{ user_id }}
--]]

--Find all registered items that use the pointshop base
function Pointshop2.GetRegisteredItems( )
	local pointshopItems = {}
	for className, itemClass in pairs( KInventory.Items ) do
		if subclassOf( KInventory.Items.base_pointshop_item, itemClass ) then
			if itemClass.isBase then
				continue
			end

			table.insert( pointshopItems, itemClass )
		end
	end
	return pointshopItems
end

function Pointshop2.GetItemClassByName( name )
	return KInventory.Items[name]
end

/*
	Warning: convenience function to be used with care. Item names are NOT unique!
*/
function Pointshop2.GetItemClassByPrintName( name )
	local itemClass
	for _, class in pairs( KInventory.Items ) do
		if string.lower( class:GetPrintName( ) ) == string.lower( name ) then
			itemClass = class
			break
		end
	end
	return itemClass
end

--[[
	hookName = {
		item1,
		item2,
		item3
	}
]]--
Pointshop2.ITEM_HOOK_LOOKUP = {}
local ITEM_HOOK_LOOKUP = Pointshop2.ITEM_HOOK_LOOKUP

-- Called when the item is equipped
function Pointshop2.ActivateItemHooks(item)
	dp("ActivateItemHooks", item)
	local class = item.class
	local hookNames = {}
	repeat
		local registeredHooks = class.static._registeredHooks or {}
		for hookName, _ in pairs(registeredHooks) do
			ITEM_HOOK_LOOKUP[hookName] = ITEM_HOOK_LOOKUP[hookName] or {}
			if not table.HasValue(ITEM_HOOK_LOOKUP[hookName], item) then
				table.insert(ITEM_HOOK_LOOKUP[hookName], item)
			end
		end
		class = class.super
	until class == Object	
end

function Pointshop2.DeactivateItemHooks(item)
	dp("DeactivateItemHooks", item)
	local class = item.class
	for hookName, tbl in pairs(ITEM_HOOK_LOOKUP) do
		ITEM_HOOK_LOOKUP[hookName] = LibK._.filter(tbl, function(_item) 
			return _item != item
		end)
	end
end

/*
	The hook specified in name is called for every item that is equipped by a player.
	Arguments are passed unmodified and unfiltered.
*/
Pointshop2.ITEM_HOOK_REGISTRY = { }
function Pointshop2.AddItemHook( hookName, itemClass )
	if itemClass.name == "DummyClass" then return end

	itemClass.static._registeredHooks = itemClass.static._registeredHooks or {}
	itemClass.static._registeredHooks[hookName] = true
	hook.Add(hookName, "PS2_ItemHooks_" .. hookName, function(...)
		local itemsForThisHook = ITEM_HOOK_LOOKUP[hookName] or {}
		local toRemove = {}
		for k, item in ipairs(itemsForThisHook) do
			-- Owner of the item has disconnected, remove the item from the hook lookup
			if not IsValid(item:GetOwner()) then
				toRemove[item] = true
				continue
			end

			if item[hookName] then
				item[hookName](item, ...)
			end
		end

		if #toRemove > 0 then
			-- Remove items with invalid owners
			ITEM_HOOK_LOOKUP[hookName] = LibK._.filter(itemsForThisHook, function(item) 
				return not toRemove[item]
			end)
		end
	end)
end

function Pointshop2.LoadPersistentItem( persistentItem )
	if not persistentItem then
		debug.Trace( )
	end

	local baseClass = Pointshop2.GetItemClassByName( persistentItem.ItemPersistence.baseClass )
	if not baseClass then
		KLogf( 2, "[WARN] Invalid base class %s", persistentItem.ItemPersistence.baseClass )
		debug.Trace( )
		return
	end

	local className = tostring( persistentItem.ItemPersistence.id )
	local internalName = "KInventory.Items." .. className
	KInventory.Items[className] = class( internalName, baseClass )
	KInventory.Items[className].static.className = className
	KInventory.Items[className].static.originFilePath = "Pointshop2_Generated"
	KInventory.Items[className].static._persistenceId = persistentItem.id
	KInventory.Items[className].static.isBase = false

	baseClass.generateFromPersistence( KInventory.Items[className], persistentItem )

	KLogf( 4, "    -> Loaded persistent item %s", className )
	return KInventory.Items[className]
end

--Get all item classes that were dynamically created from mysql
function Pointshop2.GetPersistentItems( )
	local persistent = {}
	for k, v in pairs( Pointshop2.GetRegisteredItems( ) ) do
		if v.originFilePath == "Pointshop2_Generated" then
			table.insert( persistent, v )
		end
	end
	return persistent
end

function Pointshop2.GetCreatorControlForClass( itemClass )
	local base = itemClass.super.className
	for _, mod in pairs( Pointshop2.Modules ) do
		for _, itemInfo in pairs( mod.Blueprints ) do
			if itemInfo.base == base then
				return itemInfo.creator
			end
		end
	end
end

function Pointshop2.GetPersistenceClassForItemClass( itemClass )
	local baseClass = itemClass
	while baseClass do
		if baseClass.getPersistence( ) then
			return baseClass.getPersistence( )
		end
		baseClass = baseClass.super
	end
end

function Pointshop2.GetItemInSlot( ply, slotName )
	if not ply.PS2_Slots then
		return nil
	end

	if CLIENT then
		return ply.PS2_Slots[slotName]
	end

	for k, slot in pairs( ply.PS2_Slots ) do
		if slot.itemId then
			return KInventory.ITEMS[slot.itemId]
		end
	end
end

function Pointshop2.GetServerById( id )
	local servers = Pointshop2.GetSetting("Pointshop 2", "InternalSettings.Servers" )
	for k, v in pairs( servers ) do
		if v.id == id then
			return v
		end
	end
end

function Pointshop2.GetServerIpAndPort( )
	return unpack( string.Split( game.GetIPAddress(), ":" ) )
end

function Pointshop2.CalculateServerHash( )
	local ip, port = Pointshop2.GetServerIpAndPort( )
	return util.CRC( ip .. port )
end

local serverId
function Pointshop2.GetCurrentServerId( )
	if not serverId then
		serverId = Pointshop2.GetSetting( "Pointshop 2", "InternalSettings.ServerId" )
	end
	return serverId
end

Pointshop2.GamemodeModules = {}
function Pointshop2.NotifyGamemodeModuleLoaded( gamemodeName, mod )
	Pointshop2.GamemodeModules[gamemodeName] = mod
end

function Pointshop2.IsCurrentGamemodePluginPresent( )
	return Pointshop2.GetCurrentGamemodePlugin( ) != nil
end

function Pointshop2.GetCurrentGamemodePlugin( )
	return Pointshop2.GamemodeModules[engine.ActiveGamemode( )]
end

function Pointshop2.GetCategoryByName( name )
	local categories, mappings
	if CLIENT then
		categories, mappings = Pointshop2View:getInstance( ).itemCategories, Pointshop2View:getInstance( ).itemMappings
	else
		categories, mappings = Pointshop2Controller:getInstance( ).itemCategories, Pointshop2Controller:getInstance( ).itemMappings
	end

	local category
	for k, v in pairs( categories ) do
		if v.label == name then
			category = table.Copy( v )
			break
		end
	end
	if not category then
		return false
	end

	category.items = {}
	--Populate with item mappings
	for k, v in pairs( mappings ) do
		if v.categoryId == category.id then
			table.insert( category.items, Pointshop2.GetItemClassByName( v.itemClass ) )
		end
	end

	return category
end

/*
	Used to send RPCs on items to client:
	Allows you to call client functions on items from the server with minimal effort.
	Should only be called on items that are equipped!
*/
if SERVER then
	util.AddNetworkString( "PS2_ItemClientRPC" )
	util.AddNetworkString( "PS2_ItemServerRPC" )

	function Pointshop2.ItemClientRPC( item, funcName, ... )
		net.Start( "PS2_ItemClientRPC" )
			net.WriteUInt( item.id, 32 )
			net.WriteString( funcName )
			net.WriteTable( { ... } )
		net.Broadcast( )
	end

	net.Receive( "PS2_ItemServerRPC", function( len, ply )
		local itemId = net.ReadUInt( 32 )
		local funcName = net.ReadString()
		local args = net.ReadTable( )
		if LibK.Debug then
			local argsStr = ""
			for k, v in pairs( args ) do
				argsStr = argsStr .. tostring( v )
				if k < #args then
					argsStr = argsStr .. ", "
				end
			end
			KLogf( 4, "Pointshop2.ItemServerRPC(%i, %s, %s) len %i", itemId, funcName, argsStr, len )
		end

		local item = Pointshop2.ITEMS[itemId]
		if not item then
			KLogf( 3, "[WARN] Received RPC for uncached item %i", itemId )
			return
		end
		if item:GetOwner( ) != ply then
			KLogf( 3, "[WARN] Player %s tried to RPC for other player's item %i", ply:Nick( ), itemId )
			return
		end
		if not item[funcName] then
			KLogf( 2, "[ERROR] Invalid RPC Method %s for itemId %s, name %s, class %s, method does not exist", funcName, itemId, item:GetPrintName( ), item.class.className or "" )
			return
		end

		if not item.class.static.RPCMethods[funcName] then
			KLogf( 2, "[ERROR] Invalid RPC Method %s for itemId %s, name %s, class %s, method is not whitelisted. Are you using ITEM.static.AllowRPC( funcName )?", funcName, itemId, item:GetPrintName( ), item.class.className or "" )
			return
		end

		item[funcName]( item, unpack( args ) )
	end )
else
	net.Receive( "PS2_ItemClientRPC", function( len )
		local itemId = net.ReadUInt( 32 )
		local funcName = net.ReadString()
		local args = net.ReadTable( )

		if LibK.Debug then
			local argsStr = ""
			for k, v in pairs( args ) do
				argsStr = argsStr .. tostring( v )
				if k < #args then
					argsStr = argsStr .. ", "
				end
			end
			KLogf( 4, "Pointshop2.ItemClientRPC(%i, %s, %s) len %i", itemId, funcName, argsStr, len )
		end

		local item = Pointshop2.ITEMS[itemId]
		if not item then
			KLogf( 3, "[WARN] Received RPC for uncached item %i", itemId )
			return
		end
		if not item[funcName] then
			KLogf( 3, "[WARN] Received invalid RPC method %s for item %s", funcName, item.class:GetPrintName( ) )
			return
		end
		item[funcName]( item, unpack( args ) )
	end )

	function Pointshop2.ItemServerRPC( item, funcName, ... )
		net.Start( "PS2_ItemServerRPC" )
			net.WriteUInt( item.id, 32 )
			net.WriteString( funcName )
			net.WriteTable( { ... } )
		net.SendToServer( )
	end
end

function Pointshop2.BuildTree( flatStructure, itemMappings )
	return Pointshop2.CategoryTree:new( flatStructure, itemMappings )
end

/*
	Developer utility Function, prints item names and their classes:
	1: Lamp Hat
	2: SMG1
*/
function Pointshop2.PrintItemClasses()
	local str = LibK._(Pointshop2.GetRegisteredItems()):chain()
		:map(function(item)
			return { className = item.className, name = item:GetPrintName() }
		end)
		:sort(function(a, b)
			if tonumber(a.className) and tonumber(b.className) then
				return tonumber(a.className) < tonumber(b.className)
			elseif tonumber(a) and not tonumber(b) then
				return false
			else
				return a.className < b.className
			end
		end)
		:map(function(entry)
			return entry.className .. ": " .. entry.name
		end)
		:join("\n")
		:value()
	return str
end