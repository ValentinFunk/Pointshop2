local function hideOnHidden(ply)
	if ply:Team() == TEAM_HIDDEN then
		return false
	end
end
hook.Add( "PS2_VisualsShouldShow", "Hide; TEAM_HIDDEN", hideOnHidden )
hook.Add( "PS2_PlayermodelShouldShow", "Hide; TEAM_HIDDEN", hideOnHidden )
