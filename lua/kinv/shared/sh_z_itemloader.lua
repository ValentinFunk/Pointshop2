KInventory.Items = {} --Item Registry

--Load the item into a dummy ITEM table, to find out what ITEM.baseClass is
local function getBaseClass( filepath )
	local ITEM = class( "DummyClass" ) --gets auto garbage collected
	ITEM.static.AllowRPC = function() end
	local environment = {}
	environment.ITEM = ITEM
	setmetatable( environment, { __index = _G } ) --make sure that func can access the real _G
	local func = CompileFile( filepath )
	if not func then
		KLogf( 2, "      -> [ERROR] Couldn't load item file %s", filepath )
		return
	end

	setfenv( func, environment ) -- _G for func now becomes environment
	func( )

	return ITEM.baseClass
end

local function loadItem( filepath, filename )
	--Check filename format
	local realm = string.sub( filename, 1, 2 )
	if ( realm != "sh" and realm != "cl" and realm != "sv" ) or filename[3] != "_" then
		KLogf( 2, "[ERROR] Item %s has an invalid realm %s! Please name your file sh_/cl_/sv_item_name.lua", filepath, realm )
		return
	end

	local withoutRealm = string.sub( filename, 4, #filename )
	withoutRealm = string.lower( withoutRealm )
	withoutRealm = string.gsub( withoutRealm, "^%d+_", "" ) --Remove load order e.g. sv_0_itembase.lua
	local className = string.gsub( withoutRealm, ".lua", "" )
	local internalName = "KInventory.Items." .. className

	local baseItem = KInventory.Item
	local baseClassName = getBaseClass( filepath )
	if baseClassName then
		baseItem = KInventory.Items[baseClassName]
		if not baseItem then
			KLogf( 2, "     -> [ERROR] Invalid base %s for item %s", baseClassName, className )
			return
		end
	end

	--Set up the environment for the function
	local environment = {}
	--Create a new Class for each item class
	KInventory.Items[className] = class( internalName, getClass( baseItem.name ) )
	KInventory.Items[className].static.className = className
	--make it accessible via ITEM
	environment.ITEM = KInventory.Items[className]
	setmetatable( environment, { __index = _G } ) --make sure that func can access the real _G

	local func = CompileFile( filepath )
	if not func then
		KLogf( 2, "      -> [ERROR] Couldn't load item file %s", filename )
		KInventory.Items[className] = nil --remove the class
		return
	end

	setfenv( func, environment ) -- _G for func now becomes environment
	func( )

	KInventory.ApplyMixins(className)

	--lastly give the class it's className. Internal classname can be accessed with .name
	KInventory.Items[className].static.className = className
	KInventory.Items[className].static.originFilePath = filepath

	if string.find( filename, "_base_" ) then
		KInventory.Items[className].static.isBase = true
	else
		KInventory.Items[className].static.isBase = false

		-- Give file generated things an uuid for static icons
		local disallowed = {"/", "\\", ".", " "}
		local uid = filepath
		for k, v in pairs(disallowed) do
			uid = string.Replace(uid, v, "_")
		end
		KInventory.Items[className].static.UUID = uid
	end

	KLogf( 4, "     -> Item %s (Base: %s) loaded!", className, baseItem.className or "No Base" )
end

local function includeFolder( folder )
	local files, folders = file.Find( folder .. "/*", "LUA" )
	for k, filename in pairs( files ) do
		local realmPrefix = string.sub( filename, 1, 2 )
		local fullpath = folder .. "/" .. filename
		if SERVER and ( realmPrefix == "sh" or realmPrefix == "cl" ) then
			AddCSLuaFile( fullpath )
		end
		loadItem( fullpath, filename )
	end

	for k, v in pairs( folders ) do
		includeFolder( folder .. "/" .. v )
	end
end

function KInventory.loadAllItems()
	includeFolder( "kinv/items" )
end