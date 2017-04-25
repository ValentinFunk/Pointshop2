local function disableForZombies(ply)
	if ply:Team() == TEAM_UNDEAD then
		return false
	end
end
hook.Add( "PS2_PlayermodelShouldShow", "Hide; TEAM_UNDEAD", disableForZombies )
hook.Add( "PS2_WeaponShouldSpawn", "Hide; TEAM_UNDEAD", disableForZombies )