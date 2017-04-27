local plyModel = hook.Run( "PS2_GsetPreviewModel" ) or "models/player/alyx.mdl"
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
local function paintActual(itemClass)
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
		pac.ForceRendering( true )
			pac.RenderOverride( entity, "opaque" )
			pac.RenderOverride( entity, "translucent", true )
			entity:DrawModel( )
			pac.RenderOverride( entity, "translucent", true )
		pac.ForceRendering( false )
		pac.FlashlightDisable( false )

		cam.IgnoreZ( false )
		render.SuppressEngineLighting( false )
	cam.End3D( )

	entity:RemovePACPart(outfit)
end


local mat_BlurX			= Material( "pp/blurx" )
local mat_BlurY			= Material( "pp/blury" )
local mat_Copy 			= Material( "pp/copy" )
local blurredRt, otherRt
local function blur( rt, x, y, w, h, sizex, sizey, passes )
	blurredRt = blurredRt or GetRenderTarget("BlurredRT", 512, 512)
	otherRt = otherRt or GetRenderTarget("TempRT", 512, 512)

	render.PushRenderTarget( blurredRt, 0, 0, 512, 512 )
	render.OverrideAlphaWriteEnable( true, true )
		render.Clear( 0, 0, 0, 255, true, true )

		-- Copy rt to blur texture
		mat_Copy:SetTexture( "$basetexture", rt )
		surface.SetMaterial(mat_Copy)
		surface.SetDrawColor(color_white)
		surface.DrawTexturedRectUV(0, 0, 512, 512, 0, 0, 1, 1)

		mat_BlurX:SetTexture( "$basetexture", blurredRt )
		mat_BlurY:SetTexture( "$basetexture", otherRt  )
		mat_BlurX:SetFloat( "$size", sizex )
		mat_BlurY:SetFloat( "$size", sizey )
		
		for i=1, passes+1 do
			render.SetRenderTarget( otherRt )
			surface.SetMaterial( mat_BlurX )
			surface.DrawTexturedRect(0, 0, 512, 512)

			render.SetRenderTarget( blurredRt )
			surface.SetMaterial( mat_BlurY )
			surface.DrawTexturedRect(0, 0, 512, 512)
		end
	render.OverrideAlphaWriteEnable( false )
	render.PopRenderTarget()
end

local UID = "ItemTextureRT"
local csgoBg = Material('materials/itembg-ps2.png')
function Pointshop2.RenderModelIcon(itemClass)
	local rt = GetRenderTarget( UID, 512, 512 )
	local mat = CreateMaterial( UID .. "_Mat", "UnlitGeneric", {
		["$basetexture"] = rt,
	} )

	local oldW, oldH = ScrW(), ScrH()
	local oldRt = render.GetRenderTarget( )
	render.SetRenderTarget( rt )
		render.Clear( 0, 0, 0, 255, true, true )
		render.SetViewPort( 0, 0, 512, 512 )
		cam.Start2D()
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial(csgoBg)
			surface.DrawTexturedRect(0, 0, 512, 512)
			paintActual(itemClass)
			blur(rt, 100, 100, 512, 512, 2, 2, 25)

			cam.IgnoreZ(true)
			mat:SetTexture( "$basetexture", blurredRt )
			surface.SetMaterial(mat)
			render.SetScissorRect( 0, 512 - 120, 512, 512, true ) -- Enable the rect
				surface.DrawTexturedRect(0, 0, 512, 512)
			render.SetScissorRect( 0, 0, 0, 0, false ) -- disable the rect
			cam.IgnoreZ(false)
		cam.End2D()
		render.SetViewPort( 0, 0, oldW, oldH )
	render.SetRenderTarget( oldRt )

	mat:SetTexture( "$basetexture", rt )
	return mat
end
