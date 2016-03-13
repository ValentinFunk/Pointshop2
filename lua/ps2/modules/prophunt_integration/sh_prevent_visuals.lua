local function hideOnProps(ply)
	if ply:Team() != TEAM_HUNTERS then
		return false
	end
end
hook.Add( "PS2_VisualsShouldShow", "OnlyHunters", hideOnProps )
hook.Add( "PS2_PlayermodelShouldShow", "OnlyHunters", hideOnProps )
hook.Add( "PS2_WeaponShouldSpawn", "OnlyHunters", hideOnProps )
