local S = function( id )
	return Pointshop2.GetSetting( "ZS Integration", id )
end
	

hook.Add( "EndRound", "PS2_ZSEndRound", function( result )
	//Msg("EndRound called")	                     																					//DEBUGLINE
	if result == TEAM_SURVIVORS then
		for k, v in pairs( player.GetAll( ) ) do
			if v:Team() == TEAM_SURVIVORS  then
				v:PS2_AddStandardPoints( S("RoundWin.Human"), "Survived!" )
			end	
		end
	else
		for k, v in pairs( player.GetAll( ) ) do
			if v:Team() == TEAM_UNDEAD then
				v:PS2_AddStandardPoints( S("RoundWin.Zombie"), "Devour all humans!" )	
			end			
		end
	end
	hook.Call( "Pointshop2GmIntegration_RoundEnded" )
end )

hook.Add("LastHuman","PS2_LastHuman", function( ply )	//This hook is called every second, adjust your points accordingly
	//Msg("RoundWin.LastHuman called victim: " .. ply:Nick() .. "\n")																	//DEBUGLINE
	if S("RoundWin.LastHumanToDie") then
		ply:PS2_AddStandardPoints( S("RoundWin.LastHumanToDie"), "Last man on earth" )		
	end	
end)

hook.Add("PlayerRedeemed", "PS2_PlayerRedeemed", function( ply)
	//Msg("PlayerRedeemed called Redeemed: " .. ply:Nick() .. "\n")        																//DEBUGLINE
	if S("Redeemed.Redeem") then
		ply:PS2_AddStandardPoints( S("Redeemed.Redeem"), "Redeemed!" )
	end
end)

hook.Add( "HumanKilledZombie", "PS2_HumanKillZombie", function( victim, attacker, dmginfo, headshot, suicide )
	//Msg("HumanKilledzombie called, victim: " .. victim:Nick() .. " team victim: " .. victim:Team() .. " Victims zombieclass: 
	//		" .. victim:GetZombieClassTable().Name .. " IsBoss:" .. tostring(victim:GetZombieClassTable().Boss) .. " isHeadCrab: 
	//		" .. tostring(victim:IsHeadcrab()) .. " attacker: " .. attacker:Nick() .. " team attacker: " .. attacker:Team() .. "\n")	//DEBUGLINE
	
	if victim == attacker then
		//Msg("HumanKilledZombie called, was suicide \n")																				//DEBUGLINE
		return
	end	
		if victim:Team() == TEAM_UNDEAD then			
			if victim:IsHeadcrab() and S("Kills.HumanKillsHeadcrab") then								//Only checks for headcrabs
				attacker:PS2_AddStandardPoints( S("Kills.HumanKillsHeadcrab"), "Killed a Headcrab" )
			elseif victim:GetZombieClassTable().Boss and S("Kills.HumanKillsBoss") then					//Only checks for Bosses
				attacker:PS2_AddStandardPoints( S("Kills.HumanKillsBoss"), "Killed a Boss" )
			elseif victim:GetZombieClassTable().Name == "Crow" and S("HumanKillsCrow") then				//Use this structure to add more custom zombie class checks
				attacker:PS2_AddStandardPoints( S("Kills.HumanKillsCrow"), "Killed a Crow" )
			elseif S("Kills.HumanKillsZombie") then														//Everything else
				attacker:PS2_AddStandardPoints( S("Kills.HumanKillsZombie"), "Killed a Zombie" )	
			end			
		end	
end )

hook.Add( "ZombieKilledHuman", "PS2_HumanKillZombie", function( victim, attacker, dmginfo, headshot, suicide )
	//Msg("ZombieKilledHuman called, victim: " .. victim:Nick() .. " team victim: " .. victim:Team() .. 
	//		" attacker: " .. attacker:Nick() .. " team attacker: " .. attacker:Team() .. "\n")  										//DEBUGLINE
	if victim == attacker then	
		//Msg("ZombieKilledHuman called, was suicide \n")																				//DEBUGLINE
		return
	end	
	if attacker:Team() == TEAM_UNDEAD then
		if victim:Team() == TEAM_SURVIVORS then				
			if attacker:IsHeadcrab() and S("Kills.HeadcrabKillsHuman") then														
				attacker:PS2_AddStandardPoints( S("Kills.HeadcrabKillsHuman"), "Killed a Survivor" )
			elseif attacker:GetZombieClassTable().Boss and S("Kills.BossKillsHuman") then
				attacker:PS2_AddStandardPoints( S("Kills.BossKillsHuman"), "Killed a Survivor" )
			elseif S("Kills.ZombieKillsHuman") then
				attacker:PS2_AddStandardPoints( S("Kills.ZombieKillsHuman"), "Killed a Survivor" )	
			end
		end
	end
end )

hook.Add("PlayerRepairedObject", "PS2_RepairObject", function ( ply, object, repaired, wep )
	//Msg("PlayerRepairedObject called: player: " .. ply:Nick() .. " repairedamount: " .. repaired .. "\n")								//DEBUGLINE
	if (repaired > 0) and S("Barricades.RepairObject") then
		ply:PS2_AddStandardPoints( S("Barricades.RepairObject"), "Repaired!" )
	end
end)

