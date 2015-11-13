local uid = "PS2RT_PsreRender" .. math.random( 0, 1000000000 ) --not the cleanest but should work
local rt = GetRenderTarget( uid, 128, 128 )
local mat = CreateMaterial( uid .. "mat", "UnlitGeneric", {
	["$basetexture"] = rt,
	["$translucent"] = "1"
	--["$vertexcolor"] = 1,
	--["$vertexalpha"] = 1
} )

function post3d(self)
	local oldRt = render.GetRenderTarget( )
	local w, h = ScrW(), ScrH()
	render.SetViewPort(0, 0, 128, 128)
	render.SetRenderTarget( rt )
		render.Clear( 0, 0, 0, 2, true, true )
        cam.Start2D()
            for k, v in pairs(LocalPlayer().PS2_EquippedItems) do
                if instanceOf(KInventory.Items.base_texthat, v) then
                    draw.SimpleTextOutlined( v.text or "Change Me", "PS2_MediumLarge", ScrW() / 2, ScrH() / 2, v.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, v.outlineColor )
				end
            end
		--draw.SimpleTextOutlined( "Preview Text", "PS2_MediumLarge", ScrW() / 2, ScrH() / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_white )
		cam.End2D()
	render.SetRenderTarget( oldRt )
	render.SetViewPort( 0, 0, w, h )

	mat:SetTexture( "$basetexture", rt )
end

local function postDrawModel( self )
	cam.IgnoreZ(true)
	render.SetMaterial(mat)
	render.SetBlend(0)

	render.SuppressEngineLighting( true )
		render.ResetModelLighting( 1, 1, 1 )
		render.PushFilterMag(TEXFILTER.ANISOTROPIC);
        render.PushFilterMin(TEXFILTER.ANISOTROPIC);

		render.CullMode(1) -- MATERIAL_CULLMODE_CW
		render.DrawQuadEasy( self.Entity:GetPos() + self.Entity:GetUp() * 77, self.Entity:GetForward(), 128 / 4, 128 / 4, Color(255, 255, 255), 180 )
		render.CullMode(0) -- MATERIAL_CULLMODE_CCW
		render.DrawQuadEasy( self.Entity:GetPos() + self.Entity:GetUp() * 77, self.Entity:GetForward(), 128 / 4, 128 / 4, Color(255, 255, 255), 180 )

		render.PopFilterMag( );
        render.PopFilterMin( );
	render.SuppressEngineLighting(false);
	cam.IgnoreZ(false)
end

hook.Add( "PS2_InvPreviewPanelPaint_PostDrawModel", "texthat", function( self )
	postDrawModel( self )
end )

hook.Add( "PS2_PreviewPanelPaint_PostDrawModel", "texthat", function( self )
	postDrawModel( self )
end )

hook.Add( "PS2_InvPreviewPanelPaint_PostStart3D", "texthat", function( self )
	post3d( self )
end )

hook.Add( "PS2_PreviewPanelPaint_PostStart3D", "texthat", function( self )
	post3d( self )
end )
