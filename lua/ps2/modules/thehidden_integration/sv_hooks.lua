local S = function( id )
	return Pointshop2.GetSetting( "Hidden Integration", id )
end

hook.Add( "HDN_OnRoundChange", "HiddenPS2", function( state )
	if state == ROUND_ENDED then
		hook.Call( "Pointshop2GmIntegration_RoundEnded" )
	end
end )

hook.Add( "HDN_OnHiddenDeath", "HiddenPs2", function( hidden, attacker, dmginfo )
	Pointshop2.StandardPointsBatch:begin( )

	if IsValid( attacker ) then
		attacker:PS2_AddStandardPoints( S("Rewards.HiddenKilled"), "Killed the Hidden" )
	end

	if S("Player.RewardHiddenDamage") then
		for k, v in pairs( player.GetAll( ) ) do
			if IsValid( v ) and v != attacker then
				v:PS2_AddStandardPoints( S("Player.HiddenPointsPerHP") * v:GetHiddenDamage(), "Damaged the Hidden (" + v:GetHiddenDamage() + " HP)" )
			end
		end
	end

	Pointshop2.StandardPointsBatch:finish( )
end )

hook.Add( "HDN_OnWin", "HiddenPS2", function( team )
	Pointshop2.StandardPointsBatch:begin( )

	if team == TEAM_HUMAN then
		for k, v in pairs( player.GetAll( ) ) do
			if not v:IsHidden( ) then
				v:PS2_AddStandardPoints( S("Rewards.HumansWin"), "Winning the round" )
			end
		end
	end

	if team == TEAM_HIDDEN then
		for k, v in pairs( player.GetAll( ) ) do
			if v:IsHidden( ) then
				v:PS2_AddStandardPoints( S("Rewards.HiddenWins"), "Winning the round" )
			end
		end
	end

	Pointshop2.StandardPointsBatch:finish( )
end )

hook.Add( "HDN_GetScoreValue", "HiddenPs2", function( victim, killer )
	if killer:IsHidden( ) then
		killer:PS2_AddStandardPoints( S("Rewards.HumanKilled"), "Killed a Human" )
	end
end )

old = nil
local function ApplyHook_PlayerSetUpForRound( )
	local meta = FindMetaTable( "Player" )
	old = old or meta.SetUpForRound
	function meta:SetUpForRound( team )
		old( self, team )
		hook.Run( "PlayerSetModel", self )
		print( "SetUpForRound; PlaerSetModel")
	end

	GAMEMODE.PlayerSetModel = function() end
	KLog( 4, "Hooked TheHidden Player:SetUpForRound@" .. tostring( old ) )
end

LibK.WhenAddonsLoaded{ "Pointshop2" }:Then( ApplyHook_PlayerSetUpForRound )
hook.Add( "OnReloaded", "Replace", ApplyHook_PlayerSetUpForRound )
