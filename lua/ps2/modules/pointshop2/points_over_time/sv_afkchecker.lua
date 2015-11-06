-- Kindly provided by [HDG]2Sneaky 

local gametimer = SysTime()
function Wintermute()
	if (SysTime() - gametimer) < 60 then
		return
	end
	
	gametimer = SysTime()
	for k, v in pairs( player.GetAll() ) do
		if not v:Alive() then
			continue
		end
		
		local oldafkpos = v:GetNWInt("afkpos", Vector(0,0,0))
		local curafkpos = v:GetPos()
		if oldafkpos == curafkpos then
			local afktimer = v:GetNWInt("afktimer", 0)
			local newafktimer = afktimer + 1
			if newafktimer == 5 then
				v:PS2_DisplayInformation( "You are AFK, you will no longer receive points. Move to receive points again." )
				v:SetNWBool("playerafk", true)
			end
			v:SetNWInt("afktimer", (newafktimer) )
		else
			v:SetNWInt("afkpos", v:GetPos())
			v:SetNWInt("afktimer", 0 )
			v:SetNWBool("playerafk", false)
		end
	end
end

function Pointshop2.AfkCheckInit( )
	for k, v in pairs( player.GetAll( ) ) do
		v:SetNWInt( "afkpos", v:GetPos( ) )
		v:SetNWInt( "afktimer", 0 )
		v:SetNWBool( "playerafk", false )
	end
	
	if Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.PotAfkCheck" ) then
		hook.Add( "Tick", "afk think", Wintermute )
	else
		hook.Remove( "Tick", "afk think" )
	end
end

hook.Add( "PS2_OnSettingsUpdate", "POTTimerUpdate", function( )
        Pointshop2.AfkCheckInit( )
end )
Pointshop2.SettingsLoadedPromise:Done( function( )
        Pointshop2.AfkCheckInit( )
end )