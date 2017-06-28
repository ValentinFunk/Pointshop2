local function hookProp()
    local ENT = scripted_ents.GetStored( 'ph_prop' )
    -- Called when we take damge
    function ENT:OnTakeDamage(dmg)
    	local pl = self:GetOwner()
    	local attacker = dmg:GetAttacker()
    	local inflictor = dmg:GetInflictor()

    	-- Health
    	if pl && pl:IsValid() && pl:Alive() && pl:IsPlayer() && attacker:IsPlayer() && dmg:GetDamage() > 0 then
    		self.health = self.health - dmg:GetDamage()
    		pl:SetHealth(self.health)

    		if self.health <= 0 then
    			pl:KillSilent()

    			if inflictor && inflictor == attacker && inflictor:IsPlayer() then
    				inflictor = inflictor:GetActiveWeapon()
    				if !inflictor || inflictor == NULL then inflictor = attacker end
    			end

    			net.Start( "PlayerKilledByPlayer" )

    			net.WriteEntity( pl )
    			net.WriteString( inflictor:GetClass() )
    			net.WriteEntity( attacker )

    			net.Broadcast()
                hook.Run( "PS2_PH_PropKilled", pl, inflictor, attacker )

    			MsgAll(attacker:Name() .. " found and killed " .. pl:Name() .. "\n")

    			attacker:AddFrags(1)
    			pl:AddDeaths(1)
    			attacker:SetHealth(math.Clamp(attacker:Health() + GetConVar("HUNTER_KILL_BONUS"):GetInt(), 1, 100))

    			pl:RemoveProp()
    		end
    	end
    end
end

LibK.WhenAddonsLoaded{ "Pointshop2" }:Then( hookProp )