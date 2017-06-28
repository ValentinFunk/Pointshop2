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
	local moduleLoaded = false
	for k, v in pairs( Pointshop2.Modules ) do
		if v.Name == modTable.Name then
			moduleLoaded = true
			break
		end
	end
	
	if moduleLoaded then return end -- AutoReload/module reload support right here.
	
	table.insert( Pointshop2.Modules, modTable )
	KLogf( 4, "     -> Module %s registered!", modTable.Name )
end

function Pointshop2.GetSetting( modName, path )
	if not Pointshop2.Settings.Server[modName] and not Pointshop2.Settings.Shared[modName]  then
		error( "Invalid module " .. modName .. ": Couldn't find any settings" )
	end
	
	local setting
	if Pointshop2.Settings.Shared[modName] and Pointshop2.Settings.Shared[modName][path] != nil then
		setting = Pointshop2.Settings.Shared[modName][path]
	elseif SERVER and Pointshop2.Settings.Server[modName][path] != nil then
		setting = Pointshop2.Settings.Server[modName][path]
	end
	if setting == nil then
		error( "Setting " .. modName .. ":" .. path .. " could not be found" )
	end
	
	local setting = Pointshop2.Settings.Server[modName] and Pointshop2.Settings.Server[modName][path]
	if setting == nil then
		setting = Pointshop2.Settings.Shared[modName][path]
	end
	return setting
end

function Pointshop2.recursiveSettingsInitialize( settings, storedSettings, cacheTable, path )
	for name, value in pairs( settings ) do
		if name == "info" then
			continue
		end
		
		local newPath
		if path then
			newPath = path .. "." .. name
		else
			newPath = name
		end
		if istable( value ) and value.value == nil then
			Pointshop2.recursiveSettingsInitialize( value, storedSettings, cacheTable, newPath )
		else
			if storedSettings[newPath] != nil then
				cacheTable[newPath] = storedSettings[newPath]
			else
				if istable( value ) then 
					cacheTable[newPath] = value.value
				else
					cacheTable[newPath] = value
				end
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
	
	--Give the module a chance to resolve settings via promise
	local resolve = modTable.Resolve and modTable.Resolve( ) or Promise.Resolve( )
	return WhenAllFinished{ Pointshop2.StoredSetting.findAllByPlugin( modTable.Name ), resolve }
	:Then( function( storedSettings )
		local storedMap = {}
		for k, v in pairs( storedSettings ) do
			-- Never load nodb settings. They should not end up in the DB but this could be caused by
			-- using old DB versions.
			local pathRoot = string.Explode( ".", v.path )[1]
			local settingsMeta = modTable.Settings.Shared[pathRoot] or modTable.Settings.Server[pathRoot]
			if settingsMeta and ( ( settingsMeta.info and settingsMeta.info.noDbSetting ) or settingsMeta.noDbSetting ) then
				continue
			end

			storedMap[v.path] = v.value
		end
		
		for k, realm in pairs{"Shared", "Server"} do
			if not modTable.Settings[realm] then
				continue
			end
			
			Pointshop2.Settings[realm][modTable.Name] = {}
			Pointshop2.recursiveSettingsInitialize( modTable.Settings[realm], storedMap, Pointshop2.Settings[realm][modTable.Name] )
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

function Pointshop2.LoadModules( )
	local files, folders = file.Find( "ps2/modules/*", "LUA" )
	for k, folder in pairs( folders ) do
		local shouldLoad, detectedName = true, ""
		local env = {
			Pointshop2 = {
				RegisterModule = function( mod )
					detectedName = mod.Name
					if mod.RestrictGamemodes then
						if not table.HasValue( mod.RestrictGamemodes, engine.ActiveGamemode( ) ) then
							shouldLoad = false
						end
					end
				end,
				NotifyGamemodeModuleLoaded = function( )
				end
			},
		}
		setmetatable( env, { __index = _G } )
		
		local func = CompileFile( "ps2/modules/" .. folder .. "/sh_module.lua" )
		if func then
			setfenv( func, env )
			func( )
			if shouldLoad then
				includeFolder( "ps2/modules/" .. folder )
			else
				KLogf( 4, "\t-> Module %s not loaded, not valid for gamemode %s", detectedName, engine.ActiveGamemode() )
			end
		else
			KLogf( 3, "Error loading module %s, sh_module.lua not found", folder )
		end
	end
end