--[[
    Provides a renderer for Hat Icons.
]]--

local plyModel = hook.Run( "PS2_GetPreviewModel" ) or "models/player/alyx.mdl"
local entity = ClientsideModel( plyModel, RENDER_GROUP_OPAQUE_ENTITY )
pac.SetupENT( entity )
entity:SetNoDraw(true)
entity:SetIK( false )
local colAmbientLight = Color( 50, 50, 50 )
local colColor = Color( 255, 255, 255, 255 )
local directionalLight = {
	[BOX_TOP] = Color(255, 255, 255),
	[BOX_FRONT] = Color(255, 255, 255)
}
local function PaintHatIcon(itemClass)
	local outfit = itemClass.getOutfitForModel(plyModel)
	pac.SetupENT( entity )
	entity:AttachPACPart(outfit)
    entity:FrameAdvance( 100 )


	local viewInfo = itemClass.iconInfo.shop.iconViewInfo
	for i = 1, 100 do
		pac.Think()
	end
	
	cam.Start3D( viewInfo.origin, viewInfo.angles, viewInfo.fov - 20, 0, 0, 512, 512, 5, 4096 )
		cam.IgnoreZ( true )
		render.SuppressEngineLighting( true )
		render.SetLightingOrigin( entity:GetPos() )
		render.ResetModelLighting( colAmbientLight.r/255, colAmbientLight.g/255, colAmbientLight.b/255 )
		render.SetColorModulation( colColor.r/255, colColor.g/255, colColor.b/255 )
		render.SetBlend( 1 )

		for i=0, 6 do
			local col = directionalLight[ i ]
			if ( col ) then
				render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
			end
		end

		pac.FlashlightDisable( true )
			pac.RenderOverride( entity, "opaque" )
			pac.RenderOverride( entity, "translucent", true )
			entity:DrawModel( )
			pac.RenderOverride( entity, "translucent", true )
		pac.FlashlightDisable( false )

		cam.IgnoreZ( false )
		render.SuppressEngineLighting( false )
	cam.End3D( )

	entity:RemovePACPart(outfit)
end


local HatRendererMixin = {}
function HatRendererMixin:included( klass )
    klass.static.PaintIcon = function(cls)
        PaintHatIcon(cls)
    end
end
Pointshop2.RegisterItemClassMixin( "base_hat", HatRendererMixin )