--If player is in spec and has no model equipped use a Combine as preview
hook.Add( "PS2_GetPreviewModel", "DefaultToHunter", function( )
	if LocalPlayer():Team() == TEAM_PROPS or LocalPlayer():Team() == TEAM_SPECTATOR then
		return {
			model = player_manager.TranslatePlayerModel( 'combine' ),
			bodygroups = "0",
			skin = 0
		}
	end
end )
