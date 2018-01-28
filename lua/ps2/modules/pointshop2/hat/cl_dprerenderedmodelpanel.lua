local PANEL = {}

local draw_localplayer = nil
if draw_localplayer == nil then
	hook.Add("ShouldDrawLocalPlayer", "pac_draw_2d_entity", function()
		if draw_localplayer == true then
			return true
		end
	end)
end

function PANEL:Init( )
	self.dirty = true
end

function PANEL:SetPacOutfit( outfit )
	if self.pacOutfit and IsValid( self.Entity ) then
		for k, oldOutf in pairs( self.Entity.pac_outfits ) do
			self.Entity:RemovePACPart( oldOutf:ToTable( ) )
		end
	end

	self.pacOutfit = outfit
	if not self.pacOutfit then
		error()
		return debug.Trace()
	end

	self.Entity:AttachPACPart( self.pacOutfit )

	for k, v in pairs( self.Entity.pac_outfits or {} ) do
		pac.HookEntityRender( self.Entity, v )
	end

	self:MarkDirty( )
end

function PANEL:SetViewInfo( viewInfo )
	self.viewInfo = viewInfo
	self:MarkDirty( )
end

function PANEL:SetModel( mdl )
	DModelPanel.SetModel( self, mdl )
	pac.SetupENT( self.Entity, "Owner" )
	self.Entity.Owner = self.Entity	
	if self.pacOutfit then
		self.Entity:AttachPACPart( self.pacOutfit )
	end
end

function PANEL:ApplyModelInfo( modelInfo )
	self:SetModel( modelInfo.model )

	local groups = string.Explode( " ", modelInfo.bodygroups )
	for k = 0, self.Entity:GetNumBodyGroups( ) - 1 do
		if ( self.Entity:GetBodygroupCount( k ) <= 1 ) then continue end
		self.Entity:SetBodygroup( k, groups[ k + 1 ] or 0 )
	end

	if self.Entity:SkinCount( ) - 1 > 0 then
		self.Entity:SetSkin( modelInfo.skin )
	end
end

function PANEL:Paint( w, h )
	-- self:PaintActual( w, h )
	if not self.rt then
		local uid = "PS2RT_PreRender" .. math.random( 0, 1000000000 ) --not the cleanest but should work
		self.rt = GetRenderTarget( uid, 256, 256 )
		self.mat = CreateMaterial( uid .. "mat", "UnlitGeneric", {
			["$basetexture"] = self.rt,
			--["$vertexcolor"] = 1,
			--["$vertexalpha"] = 1
		} )
	end

	if not self.dirty and not self.forceRender then
		self:PaintCached( w, h )
		return
	end

	render.PushRenderTarget(self.rt, 0, 0, 256, 256)
		local oldW, oldH = ScrW(), ScrH()
		local x,y = 0, 0 -- self:LocalToScreen(0, 0)
		render.Clear( 47, 47, 47, 255, true, true )
		-- render.SetViewPort(x, y, w, h)
		-- cam.Start2D()
		self:PaintActual( 256, 256 )
		-- cam.End2D()
		-- render.SetViewPort( 0, 0, oldW, oldH )
	render.PopRenderTarget()

	self.mat:SetTexture( "$basetexture", self.rt )

	self:PaintCached( w, h )

	self.LastPaint = RealTime()
	self.framesDrawn = self.framesDrawn or 0
	self.framesDrawn = self.framesDrawn + 1
	if self.framesDrawn > 10 then
		self.dirty = false
	end
end

function PANEL:MarkDirty( )
	self.framesDrawn = 0
	self.dirty = true
end

function PANEL:PaintCached( w, h )
	render.PushFilterMin( TEXFILTER.ANISOTROPIC );
	render.PushFilterMag( TEXFILTER.ANISOTROPIC );
		surface.SetDrawColor( color_white )
		surface.SetMaterial( self.mat )
		surface.DrawTexturedRectUV( 0, 0, w, h, 0, 0, w / 128, h / 128 )
	render.PopFilterMag( )
	render.PopFilterMin( )
end

function PANEL:PaintActual( w, h )
	if not IsValid( self.Entity ) or
	   not self.pacOutfit or
	   not self.viewInfo then
		return
	end

	pac.FrameNumber = pac.FrameNumber + 100
	if pac.Think then pac.Think() end
	
	cam.Start3D( self.viewInfo.origin, self.viewInfo.angles, self.viewInfo.fov - 20, 0, 0, w, h, 5, 4096 )
		cam.IgnoreZ( true )
		render.SuppressEngineLighting( true )
		render.SetLightingOrigin( self.Entity:GetPos() )
		render.ResetModelLighting( self.colAmbientLight.r/255, self.colAmbientLight.g/255, self.colAmbientLight.b/255 )
		render.SetColorModulation( self.colColor.r/255, self.colColor.g/255, self.colColor.b/255 )
		render.SetBlend( self.colColor.a/255 )

		for i=0, 6 do
			local col = self.DirectionalLight[ i ]
			if ( col ) then
				render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
			end
		end

		draw_localplayer = true
		pac.FlashlightDisable( true )
			pac.RenderOverride( self.Entity, "opaque" )
			pac.RenderOverride( self.Entity, "translucent", true )
			self.Entity:DrawModel( )
			pac.RenderOverride( self.Entity, "translucent", true )
		pac.FlashlightDisable( false )
		draw_localplayer = false

		cam.IgnoreZ( false )
		render.SuppressEngineLighting( false )
	cam.End3D( )
end

vgui.Register( "DPreRenderedModelPanel", PANEL, "DModelPanel" )
