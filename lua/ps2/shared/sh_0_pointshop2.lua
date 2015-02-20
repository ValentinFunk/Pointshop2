Pointshop2 = KInventory --mean hack to share databases, Pointshop2 = {}

--[[
	Pointshop2 Main file, last modifed on 06.07.2014, Revision {{ user_id }}
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
	for _, class in pairs(KInventory.Items) do
		if string.lower(class.PrintName) == string.lower(name) then
			itemClass = class
			break
		end
	end
	return itemClass
end

/*
	The hook specified in name is called for every item that is equipped by a player.
	Arguments are passed unmodified and unfiltered.
*/
function Pointshop2.AddItemHook( name, itemClass )
	if itemClass.name == "DummyClass" then return end
	
	if SERVER then
		hook.Add( name, "PS2Hook_" .. name .. itemClass.name, function( ... )
			for _, ply in pairs( player.GetAll( ) ) do
				for _, slot in pairs( ply.PS2_Slots or {} ) do
					if slot.itemId and KInventory.ITEMS[slot.itemId] then
						local eqItem = KInventory.ITEMS[slot.itemId]
						eqItem.owner = ply
						if instanceOf( itemClass, eqItem ) then
							if not eqItem.class:IsValidForServer( Pointshop2.GetCurrentServerId( ) ) then
								break
							end
							eqItem[name]( eqItem, ... )
						end
					end
				end
			end
		end )
	else
		hook.Add( name, "PS2_Hook_" .. name .. itemClass.name, function( ... )
			for _, ply in pairs( player.GetAll( ) ) do
				for k, eqItem in pairs( ply.PS2_EquippedItems or {} ) do
					eqItem.owner = ply
					if instanceOf( itemClass, eqItem ) then
						if not eqItem.class:IsValidForServer( Pointshop2.GetCurrentServerId( ) ) then
							break
						end
						eqItem[name]( eqItem, ... )
					end
				end
			end 
		end )
	end
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
	for _, mod in pairs( Pointshop2.Modules ) do
		for _, itemInfo in pairs( mod.Blueprints ) do
			local baseClass = Pointshop2.GetItemClassByName( itemInfo.base )
			if subclassOf( baseClass, itemClass ) then
				return baseClass.getPersistence( )
			end
		end
	end
end

function Pointshop2.GetItemInSlot( ply, slotName )
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

function Pointshop2.CalculateServerHash( )
	return util.CRC( GetConVarString( "ip" ) .. GetConVarString( "hostport" ) )
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
	return Pointshop2.GamemodeModules[engine.ActiveGamemode( )] != nil
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