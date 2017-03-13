function Pointshop2.UpdatePointsOverTime( )
	Pointshop2.StandardPointsBatch:begin( )

	local groupMultipliers = Pointshop2.GetSetting( "Pointshop 2", "PointsOverTime.GroupMultipliers" )
	local points = Pointshop2.GetSetting( "Pointshop 2", "PointsOverTime.Points" )
	for k, ply in pairs( player.GetAll( ) ) do
		if groupMultipliers[ply:GetUserGroup( )] then
			local bonus = groupMultipliers[ply:GetUserGroup( )] * points - points

			--Try to find a nice rank name
			local titleLookup = {}
			for k, v in pairs( PermissionInterface.getRanks( ) ) do
				titleLookup[v.internalName] = v.title
			end

			local rank = titleLookup[ply:GetUserGroup()] or ply:GetUserGroup( )
			-- Give points only if player is not afk
			if not ( Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.PotAfkCheck" ) and ply:GetNWBool( "playerafk", false ) ) then
				ply:PS2_AddStandardPoints( bonus, rank .. " Bonus", true )
			end
		end

		-- Give points only if player is not afk
		if not ( Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.PotAfkCheck" ) and ply:GetNWBool( "playerafk", false ) ) then
			ply:PS2_AddStandardPoints( points, "Playing on the Server" )
		end
	end

	Pointshop2.StandardPointsBatch:finish( )
end

function Pointshop2.RegisterPOTtimer( )
	--Points over time is disabled for gamemodes with integration plugins
	if Pointshop2.IsCurrentGamemodePluginPresent( ) and not Pointshop2.GetSetting( "Pointshop 2", "PointsOverTime.ForceEnable" ) then
		return
	end

	local delayInSeconds = Pointshop2.GetSetting( "Pointshop 2", "PointsOverTime.Delay" ) * 60
	timer.Create( "Pointshop2_POT", delayInSeconds, 0, function( )
		Pointshop2.UpdatePointsOverTime( )
	end )
end
hook.Add( "PS2_OnSettingsUpdate", "POTTimerUpdate", function( )
	Pointshop2.RegisterPOTtimer( )
end )
Pointshop2.SettingsLoadedPromise:Done( function( )
	Pointshop2.RegisterPOTtimer( )
end )
