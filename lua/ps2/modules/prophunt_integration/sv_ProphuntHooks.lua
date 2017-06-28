Pointshop2.PropHunt = {}

local S = function( id )
	return Pointshop2.GetSetting( "Prop Hunt Integration", id )
end

function Pointshop2.PropHunt.PreRoundStart( num )
	if team.NumPlayers( TEAM_PROPS ) == 0 or team.NumPlayers( TEAM_HUNTERS ) == 0 then return end
	GAMEMODE.ps2TeamPlayers = GAMEMODE.ps2TeamPlayers or {
		[TEAM_PROPS] = {},
		[TEAM_HUNTERS] = {}
	}

	for k, v in pairs( player.GetAll( ) ) do
		GAMEMODE.ps2TeamPlayers[v:Team()] = GAMEMODE.ps2TeamPlayers[v:Team()] or {}
		table.insert( GAMEMODE.ps2TeamPlayers[v:Team()],  v )
	end

	if #player.GetAll( ) > S('RoundWin.MinimumPlayers') then
		GAMEMODE.Jackpot = #player.GetAll( ) * S('RoundWin.TimeJackpotPerPlayer')
		for k, v in pairs( player.GetAll( ) ) do
			if v:Team() == TEAM_HUNTERS then
				v:PS2_DisplayInformation( "Round started. Points pot is at " .. GAMEMODE.Jackpot .. " points. It decreases by " .. math.floor( GAMEMODE.Jackpot / ( GAMEMODE.RoundLength / 60 ) ) .. " points every minute, kill the Props quickly for maximum reward!" )
			end
		end
		GAMEMODE.PS2_NoPoints = false
	else
		GAMEMODE.PS2_NoPoints = true
		Pointshop2.BroadcastInfo( "No points will be given this round. Minimum of " .. S('RoundWin.MinimumPlayers') .. " players required" )
	end
end

function Pointshop2.PropHunt.SetRoundResult( result )
	if GAMEMODE.PS2_NoPoints then
		return
	end

	if result == 1001 then
		return
	end

	GAMEMODE.ps2TeamPlayers = GAMEMODE.ps2TeamPlayers or {
		[TEAM_PROPS] = {},
		[TEAM_HUNTERS] = {}
	}

	Pointshop2.StandardPointsBatch:begin( )
	if result == TEAM_PROPS then
		for k, v in pairs( GAMEMODE.ps2TeamPlayers[TEAM_PROPS] ) do
			if not IsValid( v ) then
				return
			end

			if v:Alive() and v:Team( ) == TEAM_PROPS then
				v:PS2_AddStandardPoints( S('RoundWin.AliveBonus'), 'Alive Bonus', true )
			end
			v:PS2_AddStandardPoints( S('RoundWin.PropsWin'), 'Winning the round' )
		end
	end

	if result == TEAM_HUNTERS then
		local aliveHuntersCount = 0
		for k, v in pairs( GAMEMODE.ps2TeamPlayers[TEAM_HUNTERS] ) do
			if IsValid( v ) and v:Alive() and v:Team() == TEAM_HUNTERS then
				aliveHuntersCount = aliveHuntersCount + 1
			end
		end
		for k, v in pairs( GAMEMODE.ps2TeamPlayers[TEAM_HUNTERS] ) do
			if not IsValid( v ) then
				return
			end

			if v:Alive() and v:Team( ) == TEAM_HUNTERS then
				v:PS2_AddStandardPoints( S('RoundWin.AliveBonus'), 'Alive Bonus', true )
			end
			local timeElapsed = GetGlobalFloat( "RoundEndTime" ) - CurTime()
			timeElapsed = timeElapsed > 0 and timeElapsed or GAMEMODE.RoundLength
			local pot = GAMEMODE.Jackpot * ( 1 - timeElapsed / GAMEMODE.RoundLength )
			v:PS2_AddStandardPoints( math.floor( pot / aliveHuntersCount ), 'Winning the round', true )
		end
	end
	Pointshop2.StandardPointsBatch:finish( )

	hook.Call( "Pointshop2GmIntegration_RoundEnded" )
end

function Pointshop2.PropHunt.OnPropKilled( victim, inflictor, attacker )
	if attacker:IsPlayer( ) and not GAMEMODE.PS2_NoPoints then
		attacker:PS2_AddStandardPoints( S("Kills.HunterKillsProp"), "Killed Prop" )
	end
end
hook.Add( "PS2_PH_PropKilled", "PH_PropKilled", Pointshop2.PropHunt.OnPropKilled )

local function installHooks( )
	GAMEMODE.OriginalSetRoundResult = GAMEMODE.OriginalSetRoundResult or GAMEMODE.SetRoundResult -- need to use this as fretta resets timer before OnRoundResult
	GAMEMODE.OriginalPreRoundStart = GAMEMODE.OriginalPreRoundStart or GAMEMODE.PreRoundStart

	function GAMEMODE:SetRoundResult( result, resulttext )
		Pointshop2.PropHunt.SetRoundResult( result )
		GAMEMODE.OriginalSetRoundResult( self, result, resulttext )
	end

	function GAMEMODE:PreRoundStart( num )
		GAMEMODE.OriginalPreRoundStart( self, num )
		Pointshop2.PropHunt.PreRoundStart( num )
	end
end

LibK.WhenAddonsLoaded{ "Pointshop2" }:Then( installHooks )
hook.Add( "OnReloaded", "PS2_ReloadPropHuntHooks", installHooks )
