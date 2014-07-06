--If player is in spec and has no model equipped use a Terrorist as preview model
hook.Add( "PS2_GetPreviewModel", "DefaultToTerrorist", function( )
	if LocalPlayer():IsSpec( ) then
		return GAMEMODE.playermodel or "models/player/phoenix.mdl"
	end
end )