Pointshop2 = {}

function Pointshop2.LoadCategorySettings( )

end

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

function Pointshop2.AddItemHook( name, item )
	if item.name == "DummyClass" then return end
	
	hook.Add( name, "PS2Hook_" .. item.className, function( ... )
		for k, v in pairs( player.GetAll( ) ) do
			if v:PS2_HasItemEquipped( item.className ) then -- hooks are only called if the player has the item equipped
				item[name]( item, ... )
			end
		end
	end )
end

function Pointshop2.LoadPersistentItem( persistentItem )
	local baseClass = Pointshop2.GetItemClassByName( persistentItem.ItemPersistence.baseClass )
	
	local className = string.lower( string.Replace( persistentItem.ItemPersistence.name, " ", "_" ) ) .. persistentItem.id
	local internalName = "KInventory.Items." .. className
	KInventory.Items[className] = class( internalName, baseClass )
	KInventory.Items[className].static.className = className
	KInventory.Items[className].static.originFilePath = "Pointshop2_Generated"
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