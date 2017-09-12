local PANEL = {}

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
		return debug.Trace()
	end
	if IsValid( self.Entity ) then
		self.Entity:AttachPACPart( self.pacOutfit )
	end
	self:MarkDirty( )
end

function PANEL:SetViewInfo( viewInfo )
	self.viewInfo = viewInfo
	self:MarkDirty( )
end

function PANEL:SetModel( mdl )
	DModelPanel.SetModel( self, mdl )
	pac.SetupENT( self.Entity )
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

	local oldRt = render.GetRenderTarget( )
	render.SetRenderTarget( self.rt )
		render.Clear( 47, 47, 47, 255, true, true )
		self:PaintActual( w, h )
	render.SetRenderTarget( oldRt )

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
		surface.SetMaterial( self.mat )
		surface.DrawTexturedRectUV( 0, 0, w, h, 0, 0, w / 128, h / 128 )
	render.PopFilterMag( )
	render.PopFilterMin( )
end

function PANEL:PaintActual( w, h )
	if not IsValid( self.Entity ) or
	   not self.pacOutfit or
	   not self.viewInfo then
		--surface.SetDrawColor( 255, 0, 255, 100 )
		--surface.DrawRect( 0, 0, w, h )
		return
	end

	pac.Think()
	cam.Start3D( self.viewInfo.origin, self.viewInfo.angles, self.viewInfo.fov - 20, 0, 0, 256, 256, 5, 4096 )
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

		pac.FlashlightDisable( true )
			pac.RenderOverride( self.Entity, "opaque" )
			pac.RenderOverride( self.Entity, "translucent", true )
			self.Entity:DrawModel( )
			pac.RenderOverride( self.Entity, "translucent", true )
		pac.FlashlightDisable( false )

		cam.IgnoreZ( false )
		render.SuppressEngineLighting( false )
	cam.End3D( )
end

vgui.Register( "DPreRenderedModelPanel", PANEL, "DModelPanel" )
