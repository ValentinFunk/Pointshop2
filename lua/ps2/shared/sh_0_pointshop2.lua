Pointshop2 = {}

--[[
	Pointshop2 Main file, last modifed on 06.07.2014, {{ user_id }}
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
						if instanceOf( itemClass, eqItem ) then
							eqItem[name]( eqItem, ... )
						end
					end
				end
			end
		end )
	else
		hook.Add( name, "PS2_Hook_" .. name .. itemClass.name, function( ... )
			for _, ply in pairs( player.GetAll( ) ) do
				for k, item in pairs( ply.PS2_EquipedItems or {} ) do
					if item.class.name == itemClass.name then
						item[name]( item, ... )
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

function Pointshop2.GetCurrentServerId( )
	return Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.ServerId" )
end