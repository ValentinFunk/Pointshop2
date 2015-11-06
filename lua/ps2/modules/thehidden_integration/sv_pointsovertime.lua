local S = function( id )
	return Pointshop2.GetSetting( "Hidden Integration", id )
end

function Pointshop2.UpdateHiddenPointsOverTime( )
	local points = S( "PointsOverTime.Points" )
	for k, ply in pairs( player.GetAll( ) ) do
		if not ply:IsHidden() and ply:Alive() and ply:Team( ) != TEAM_SPECTATOR then
			ply:PS2_AddStandardPoints( points, "Alive Bonus", true )
		end
	end
end

function Pointshop2.RegisterHiddenPOTtimer( )
	--Points over time is disabled for gamemodes with integration plugins
	if not S( "PointsOverTime.Enable" ) then
		return
	end

	local delayInSeconds = S( "PointsOverTime.Delay" ) * 60
	timer.Create( "Pointshop2_POTTheHidden", delayInSeconds, 0, function( )
		Pointshop2.UpdateHiddenPointsOverTime( )
	end )
end
hook.Add( "PS2_OnSettingsUpdate", "POTHiddenTimerUpdate", function( )
	Pointshop2.RegisterHiddenPOTtimer( )
end )
Pointshop2.SettingsLoadedPromise:Done( function( )
	Pointshop2.RegisterHiddenPOTtimer( )
end )
