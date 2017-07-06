local MurderSetting = function(id)
	return Pointshop2.GetSetting("Murder Integration", id)
end

local playersInRound = { }
hook.Add("OnStartRound", "PS2_MUBeginRound", function()
	for k, v in pairs(player.GetAll()) do
		if v:Alive() then
			playersInRound[k] = v
		end
	end
end)

hook.Add("PlayerPickupLoot", "PS2_PlayerPickupLoot", function(ply, ent)
	ply:PS2_AddStandardPoints( MurderSetting("Kills.PickupLoot"), "Found Loot", true)
end)

// Only if the hook is defined. Not defined by default. Be aware.
// 1 Murderer wins
// 2 Murderer loses
// 3 Murderer rage quit
hook.Add("OnEndRoundResult", "PS2_MUEndRound", function(result)
	if result == 2 then
		for k, v in pairs(player.GetAll()) do
			if not table.HasValue(playersInRound, v) then
				continue
			end

			if v:GetMurderer() then
				continue
			end

			if v:Alive() and MurderSetting("RoundWin.BystanderAlive") then
				v:PS2_AddStandardPoints(MurderSetting("RoundWin.BystanderAlive"), "Bonus for survival", true)
			end
			if MurderSetting("RoundWin.Bystander") then
				v:PS2_AddStandardPoints(MurderSetting("RoundWin.Bystander"), "Won the round")
			end

		end
	elseif result == 1 then
		for k, v in pairs( player.GetAll()) do
			if not v:GetMurderer() then
				continue
			end
		end
	end
	playersInRound = { }

	hook.Call("Pointshop2GmIntegration_RoundEnded")
end)

hook.Add("PlayerDeath", "PS2_PlayerDeath", function(victim, inflictor, attacker)
	if victim == attacker then
		return
	end

	if attacker:GetMurderer() then
		attacker:PS2_AddStandardPoints(MurderSetting("Kills.MurderKillsBystander"), "Killed Bystander")
	else -- Bystander
		if victim:GetMurderer() and MurderSetting("Kills.BystanderKillsMurderer") then
			attacker:PS2_AddStandardPoints(MurderSetting("Kills.BystanderKillsMurderer"), "Killed the Murderer")
		end

	end

end)

local function onlyMurderer(ply) 
	if not ply:GetMurderer() then
		return false
	end
end
hook.Add( "PS2_WeaponShouldSpawn", "OnlyMurderer", onlyMurderer )