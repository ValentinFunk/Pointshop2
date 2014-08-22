function Pointshop2.ApplyPacSettings( )
	// Disallow saving/applying outfits
	hook.Add("PrePACConfigApply", "Pointshop2CheckPACAccess", function( owner, data, bPac3 )
		if not IsValid( owner ) or not owner:IsPlayer( ) then
			return false, "invalid player" 
		end
		if Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.LimitPACAccess" ) then
			if not PermissionInterface.query( owner, "pointshop2 usepac" ) then
				return false, "Permission Denied"
			end
		end
		return true, ""
	end )
	
	// Disallow opening the editor
	hook.Add( "PrePACEditorOpen", "Pointshop2CheckPACAccess", function( ply )
		if Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.LimitPACAccess" ) then
			if not PermissionInterface.query( ply, "pointshop2 usepac" ) then
				return false
			end
		end
	end )
end

hook.Add( "PS2_OnSettingsUpdate", "ProtectPAC", function( )
	Pointshop2.ApplyPacSettings( )
end )
