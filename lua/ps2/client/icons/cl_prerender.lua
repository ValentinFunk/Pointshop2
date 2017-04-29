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
local g_rt, g_mat
function Pointshop2.RenderModelIcon(itemClass, newMaterial)
	local rt, mat
	if newMaterial then
		rt = GetRenderTarget( LibK.GetUUID(), 512, 512 )
		mat = CreateMaterial( LibK.GetUUID() .. "_Mat", "UnlitGeneric", {
			["$basetexture"] = rt,
		} )
	else
		g_rt = g_rt or GetRenderTarget( UID, 512, 512 )
		rt = g_rt
		
		g_mat = g_mat or CreateMaterial( UID .. "_Mat", "UnlitGeneric", {
			["$basetexture"] = rt,
		} )
		mat = g_mat
	end

	local oldW, oldH = ScrW(), ScrH()
	local oldRt = render.GetRenderTarget( )
	render.SetRenderTarget( rt )
		render.Clear( 0, 0, 0, 255, true, true )
		render.SetViewPort( 0, 0, 512, 512 )
		cam.Start2D()
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial(csgoBg)
			surface.DrawTexturedRect(0, 0, 512, 512)
			if not itemClass.PaintIcon then
				KLogf(1, "Item class %s(%s) is missing a PaintIcon", itemClass.name, itemClass.PrintName)
			elseif Pointshop2.DbgOverrideIcon then 
				Pointshop2.DbgOverrideIcon(itemClass)
			else
				itemClass:PaintIcon()
			end
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

local materialsCached = {}
function Pointshop2.RenderMaterialIcon(material)
	if not materialsCached[material] then
		materialsCached[material] = Pointshop2.RenderModelIcon({
			PaintIcon = function() --prerender context viewport is always 512x512
				surface.SetMaterial(Material(material))
				surface.DrawTexturedRect(64 + 60, 64 + 15, 512 - 120 - 128, 512 - 120 - 128)
			end
		}, true)
	end	
	return materialsCached[material]
end