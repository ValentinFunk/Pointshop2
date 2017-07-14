-- Adapted from MDave's MIT Licensed code. Now ISC
Pointshop2.IconQueue = Pointshop2.IconQueue or LibK.CircularQueue()
Pointshop2.IconPromises  =  {}

local queue = Pointshop2.IconQueue
local promises  = Pointshop2.IconPromises

local function getIconUID( itemClass )
	return "ps2/2" .. itemClass.UUID:lower()
end
Pointshop2.GetIconPath = getIconUID

local function getIconPath( itemClass )
	return string.format( "spawnicons/%s_256.png", getIconUID(itemClass) )
end

function Pointshop2.RequestIcon( itemClass, forceRender )
	local iconID  = getIconUID( itemClass )
	local pending = promises[iconID]
	if pending then
		if getPromiseState(pending) == "pending" then
			return pending
		end

		if not forceRender then
			return pending
		end
	end

	-- Check if the icon exists
	local path = getIconPath( itemClass )
	if file.Exists( "materials/" .. path, "GAME" ) and not forceRender then
		return Promise.Resolve(Material( path ))
	end

	promises[iconID] = Deferred()
	queue:Add( itemClass )
	return promises[iconID]
end

do
	Pointshop2.rIcon  = Pointshop2.rIcon  or vgui.Create( "ModelImage" )
	Pointshop2.rModel = Pointshop2.rModel or ClientsideModel( "error" )

	local rIcon  = Pointshop2.rIcon
	local rModel = Pointshop2.rModel

	local rTable = {
		ent = rModel,
		
		cam_pos = Vector(),
		cam_ang = Angle(),
		cam_fov = 90
	}

	local rTexture


	rIcon:SetVisible( false )
	rIcon:SetSize( 256, 256 )

	rModel:SetNoDraw( true )

	function rModel:RenderOverride()
		if not rTexture then return end
		cam.Start2D()
			surface.SetDrawColor( 255, 255, 255 )

			render.PushFilterMin( TEXFILTER.ANISOTROPIC );
			render.PushFilterMag( TEXFILTER.ANISOTROPIC );
				surface.SetMaterial( rTexture )
				surface.DrawTexturedRectUV( 0, 0, 512, 512, 0, 0, 1, 1 )
			render.PopFilterMag( )
			render.PopFilterMin( )
		cam.End2D()
	end

	hook.Add( "HUDPaint", "TShop: ProcessIconQueue", function()
		if queue:IsEmpty() then
			return
		end

		-- Render icon
		local itemClass = queue:Pop()

		rTexture = Pointshop2.RenderModelIcon(itemClass)

		rIcon:SetModel( getIconUID( itemClass ) )
		rIcon:RebuildSpawnIconEx( rTable )
	end )

	hook.Add( "SpawniconGenerated", "TShop: IconPopulate", function( model, image )
		local pending = promises[model]

		if pending then
			local path = image:gsub( "materials\\", "" )
			local icon = Material( path )

			-- Force the icon to refresh
			icon:GetTexture( "$basetexture" ):Download()

			pending:Resolve(icon)
			hook.Run( "PS2_ItemIconChanged", model, icon )
		end

		if !pending then
			print( "no prom for ", model )
		end
	end )

end