Pointshop2.Modules = {}

function Pointshop2.GetModule( modName )
	for k, v in pairs( Pointshop2.Modules ) do
		if v.Name == modName then
			return v
		end
	end
end

Pointshop2.Settings = {
	Server = {},
	Shared = {}
}

function Pointshop2.RegisterModule( modTable )
	table.insert( Pointshop2.Modules, modTable )
	KLogf( 4, "     -> Module %s registered!", modTable.Name )
end

function Pointshop2.GetSetting( modName, path )
	if not Pointshop2.Settings.Shared[modName] and not ointshop2.Settings.Shared[modName]  then
		error( "Invalid module " .. modName .. ": Couldn't find any settings" )
	end
	local setting
	if Pointshop2.Settings.Shared[modName][path] != nil then
		setting = Pointshop2.Settings.Shared[modName][path]
	elseif Pointshop2.Settings.Server[modName][path] != nil then
		setting = Pointshop2.Settings.Server[modName][path]
	end
	if setting == nil then
		error( "Setting " .. path .. " could not be found" )
	end
	return Pointshop2.Settings[modName][path]
end

local function recursiveSettingsInitialize( settings, storedSettings, cacheTable, path )
	for name, value in pairs( settings ) do
		local newPath
		if path then
			newPath = path .. "." .. name
		else
			newPath = name
		end
		if istable( value ) then
			recursiveSettingsInitialize( value, storedSettings, cacheTable, newPath )
		else
			if storedSettings[newPath] != nil then
				cacheTable[newPath] = storedSettings[newPath]
			else
				cacheTable[newPath] = value
			end
		end
	end
end

--Called by controller
function Pointshop2.InitializeModuleSettings( modTable )
	if not modTable.Settings then
		local def = Deferred( )
		def:Resolve( )
		return def:Promise( )
	end
	
	return Pointshop2.StoredSetting.findAllByPlugin( modTable.Name )
	:Done( function( storedSettings )
		local storedMap = {}
		for k, v in pairs( storedSettings ) do
			storedMap[v.path] = v.value
		end
		
		for k, realm in pairs{"Shared", "Server"} do
			if not modTable.Settings[realm] then
				continue
			end
			
			Pointshop2.Settings[realm][modTable.Name] = {}
			recursiveSettingsInitialize( modTable.Settings[realm], storedMap, Pointshop2.Settings[realm][modTable.Name] )
		end
	end )
end

local function includeFolder( folder )
	local files, folders = file.Find( folder .. "/*", "LUA" )
	for k, filename in pairs( files ) do
		local realmPrefix = string.sub( filename, 1, 2 )
		if ( realmPrefix != "sh" and realmPrefix != "cl" and realmPrefix != "sv" ) or filename[3] != "_" then
			KLogf( 2, "[ERROR] Couldn't determine realm of file %s! Please name your file sh_*/cl_*/sv_*.lua", filename )
			continue
		end
		local fullpath = folder .. "/" .. filename
		if SERVER and ( realmPrefix == "sh" or realmPrefix == "cl" ) then
			AddCSLuaFile( fullpath )
		end
		print( filename, realmPrefix )
		if SERVER and ( realmPrefix == "sh" or realmPrefix == "sv" ) then
			include( fullpath )
		elseif CLIENT then
			include( fullpath ) --client only sees sh and cl files so no need to check realm
		end
	end
	
	for k, v in pairs( folders ) do
		includeFolder( folder .. "/" .. v )
	end
end
 
includeFolder( "ps2/modules" )