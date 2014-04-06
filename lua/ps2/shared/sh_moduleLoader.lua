Pointshop2.Modules = {}

function Pointshop2.RegisterModule( modTable )
	table.insert( Pointshop2.Modules, modTable )
	KLogf( 4, "     -> Module %s registered!", modTable.Name )
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