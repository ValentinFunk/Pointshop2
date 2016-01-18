local function hideOnProps(ply)
	if ply:Team() == TEAM_SEEKING then
		return false
	end
end
hook.Add( "PS2_VisualsShouldShow", "HideOnSeekers", hideOnProps )
hook.Add( "PS2_PlayermodelShouldShow", "HideOnSeekers", hideOnProps )
--hook.Add( "PS2_WeaponShouldSpawn", "HideOnSeekers", hideOnProps )
