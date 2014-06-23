local TTTConfig = Pointshop2.Config.TTT.PointsAwarded

local delayedRewards = {}
local function delayReward( ply, points, message, small )
	if TTTConfig.Kills.DelayReward then
		table.insert( delayedRewards, { ply = ply, points = points, message = message, small = small } )
	else
	
	end
end

local function applyDelayedRewards( )
	for k, v in ipairs( delayedRewards )  do
		v.ply:PS2_AddStandardPoints( v.points, v.message, v.small )
	end
end

hook.Add( "TTTEndRound", "PS2_TTTEndRound", function( result )
	applyDelayedRewards( )
	
	if result == WIN_INNOCENT then
		for k, v in pairs( player.GetAll( ) ) do
			if v:IsActiveTraitor( ) then
				continue
			end
			if v:GetCleanRound( ) and TTTConfig.RoundWin.CleanRound then
				v:PS2_AddStandardPoints( TTTConfig.RoundWin.CleanRound, "Clean round bonus", true )
			end
			if v:Alive( ) and TTTConfig.RoundWin.InnocentAlive then
				v:PS2_AddStandardPoints( TTTConfig.RoundWin.InnocentAlive, "Alive bonus", true )
			end
			if TTTConfig.RoundWin.Innocent then
				v:PS2_AddStandardPoints( TTTConfig.RoundWin.Innocent, "Winning the round" )
			end
			
		end
	elseif result == WIN_TRAITOR then
		for k, v in pairs( player.GetAll( ) ) do
			if not v:IsActiveTraitor( ) then
				continue
			end
			if v:Alive( ) and TTTConfig.RoundWin.TraitorAlive then
				v:PS2_AddStandardPoints( TTTConfig.RoundWin.TraitorAlive, "Alive bonus", true )
			end
			if TTTConfig.RoundWin.Traitor then
				v:PS2_AddStandardPoints( TTTConfig.RoundWin.Traitor, "Winning the round" )
			end
		end
	end
end )

hook.Add( "TTTFoundDNA", "PS2_TTTFoundDNA", function( ply, dnaOwner, ent )
	if TTTConfig.Misc.DnaFound then
		v:PS2_AddStandardPoints( TTTConfig.RoundWin.DnaFound, "Retrieved DNA", true )
	end
	
	ply.hasDnaOn = ply.hasDnaOn or {}
	ply.hasDnaOn[dnaOwner] = true
end )

hook.Add( "PlayerDeath", "PS2_PlayerDeath", function( victim, inflictor, attacker )
	if ply == attacker then
		return
	end
	
	local victimRole = victim:GetRole( )
	local attackerRole = attacker:GetRole( )
	
	if attackerRole == ROLE_TRAITOR then
		if victimRole == ROLE_INNOCENT and TTTConfig.Kills.TraitorKillsInno then
			attacker:PS2_AddStandardPoints( TTTConfig.Kills.TraitorKillsInno, "Killed Innocent" )
		elseif victimRole == ROLE_DETECTIVE and TTTConfig.Kills.TraitorKillsDetective then
			attacker:PS2_AddStandardPoints( TTTConfig.Kills.TraitorKillsDetective, "Killed Detective" )
		end
	elseif attackerRole == ROLE_DETECTIVE then
		if victimRole == ROLE_TRAITOR and TTTConfig.Kills.DetectiveKillsTraitor then
			if TTTConfig.Kills.DetectiveDnaBonus and attacker.hasDnaOn and attacker.hasDnaOn[victim] then
				delayReward( attacker, TTTConfig.Kills.DetectiveDnaBonus, "DNA bonus" )
			end
			delayReward( attacker, TTTConfig.Kills.DetectiveKillsTraitor, "Killed Traitor" )
		end
	elseif attackerRole == ROLE_INNOCENT then
		if victimRole == ROLE_TRAITOR and TTTConfig.Kills.InnoKillsTraitor then
			delayReward( attacker, TTTConfig.Kills.InnoKillsTraitor, "Killed Traitor" )
		end
	end
end )

