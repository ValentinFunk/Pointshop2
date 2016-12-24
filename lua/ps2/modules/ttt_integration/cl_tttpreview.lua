--If player is in spec and has no model equipped use a Terrorist as preview model
hook.Add( "PS2_GetPreviewModel", "DefaultToTerrorist", function( )
	if LocalPlayer():IsSpec() and not Pointshop2:IsPlayerModelEquipped( ) then
		return {
			model = GAMEMODE.playermodel or "models/player/phoenix.mdl",
			bodygroups = "0",
			skin = 0
		}
	end
end )

hook.Add( "TTTPlayerColor", "FixTTTModel", function( )
	hook.Run( "PS2_DoUpdatePreviewModel" )
end )

/*
Lebofly: one more thing for you, for TTT the preview model usually sticks being whatever playermodel you had equipped on say DR. Which is a problem if the servers don't both use custom player models
*/
hook.Add( "PlayerSpawn", "FixTTTPlayerModel", function( )
	hook.Run( "PS2_DoUpdatePreviewModel" )
end )
