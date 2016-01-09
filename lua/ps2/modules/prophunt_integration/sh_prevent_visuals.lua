local function hideOnProps(ply)
	if ply:Team() == TEAM_PROPS then
		return false
	end
end
hook.Add( "PS2_VisualsShouldShow", "HideOnProps", hideOnProps )
hook.Add( "PS2_PlayermodelShouldShow", "HideOnProps", hideOnProps)
