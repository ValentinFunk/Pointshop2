local PANEL = {}

function PANEL:Init( )
	self.modelPanel = vgui.Create( "DModelPanel", self )
	self.modelPanel:Dock( FILL )
	self.modelPanel:SetFOV( 25 )
	self.modelPanel:SetCamPos( Vector( 0, 0, 0 ) )
	self.modelPanel:SetDirectionalLight( BOX_RIGHT, Color( 255, 160, 80, 255 ) )
	self.modelPanel:SetDirectionalLight( BOX_LEFT, Color( 80, 160, 255, 255 ) )
	self.modelPanel:SetAmbientLight( Vector( -64, -64, -64 ) )
	self.modelPanel:SetAnimated( true )
	self.modelPanel.Angles = Angle( 0, 0, 0 )
	self.modelPanel:SetLookAt( Vector( -100, 0, -10 ) )
	self.modelPanel:SetMouseInputEnabled( false )
	function self.modelPanel:LayoutEntity( Entity )
		if ( self.bAnimated ) then self:RunAnimation() end
	end
	
	local mat = Material( "model/shiny" )
	local mat_BlurX			= Material( "pp/blurx" )
	local mat_BlurY			= Material( "pp/blury" )
	function self.modelPanel:Paint( w, h )
		if ( !IsValid( self.Entity ) ) then return end

		local x, y = self:LocalToScreen( 0, 0 )
		local w, h = self:GetSize()

		self:LayoutEntity( self.Entity )

		local ang = self.aLookAngle
		if ( !ang ) then
		ang = (self.vLookatPos-self.vCamPos):Angle()
		end
		
		if self:GetParent( ).Selected or self:GetParent( ).Hovered or self:GetParent( ):IsChildHovered( 2 ) then
			local rt = GetRenderTarget( "IconTarge28t", w, h )
			if not self.mt2 then
				self.mt2 = CreateMaterial( "IconxMat" .. w .. h, "UnlitGeneric" )
			end
			
			local oldRt = render.GetRenderTarget( )
			local w, h = self:GetSize()
			local oldW, oldH = ScrW( ), ScrH( )
			render.SetRenderTarget( rt )
				render.Clear( 47, 47, 47, 255, true, true )
					
				cam.Start3D( self.vCamPos, ang, 25, 0, 0, w, h, 5, self.FarZ )
					cam.IgnoreZ( true )
					render.SuppressEngineLighting( true )
					render.MaterialOverride( Material( "models/shiny" ) )
						render.SetColorModulation( 1, 198.0 / 255, 0 )
						render.SetBlend( 1 )
						self.Entity:DrawModel()
						render.SetColorModulation( 0, 0, 0 )
					render.MaterialOverride( )
					render.SuppressEngineLighting( false )
					cam.IgnoreZ( false )
				cam.End3D()
			render.SetRenderTarget( oldRt )
			
			local effecttex = GetRenderTarget( "effects"..w..h , w, h )
			mat_BlurX:SetTexture( "$basetexture", rt )
			mat_BlurX:SetFloat( "$size", 2 )
			mat_BlurY:SetTexture( "$basetexture", effecttex )
			mat_BlurY:SetFloat( "$size", 2 )
			
			render.SetRenderTarget( effecttex )
			render.Clear( 0, 0, 0, 255 )
			render.SetViewPort( 0, 0, w, h )
			cam.Start2D( )
				surface.SetMaterial( mat_BlurX )
				surface.DrawTexturedRect( 0, 0, w, h )
			cam.End2D( )
			render.SetRenderTarget( rt )
			cam.Start2D( )
				surface.SetMaterial( mat_BlurY )
				surface.DrawTexturedRect( 0, 0, w, h )
			cam.End2D( )
			render.SetViewPort( 0, 0, oldW, oldH )
			render.SetRenderTarget( oldRt )
			self.mt2:SetTexture( "$basetexture", effecttex )
			
			surface.SetDrawColor( color_white )
			surface.SetMaterial( self.mt2 )
			surface.DrawTexturedRect( 0, 0, w, h )
		end
		
		cam.Start3D( self.vCamPos, ang, 25, x, y, w, h, 5, self.FarZ )
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
			
			self.Entity:DrawModel()

		render.SuppressEngineLighting( false )
		cam.IgnoreZ( false )
		cam.End3D()

		self.LastPaint = RealTime()
	end
	
	function self.modelPanel:PlayPreviewAnimation( )
		local playermodel = "" 
		for name, model in pairs( player_manager.AllValidModels( ) ) do
			if model == self.Entity:GetModel( ) then
				playermodel = name
			end
		end
		local default_animations = { "idle_all_01", "menu_walk" }
		local anims = list.Get( "PlayerOptionsAnimations" )
		local anim = default_animations[ math.random( 1, #default_animations ) ]
		if ( anims[ playermodel ] ) then
			anims = anims[ playermodel ]
			anim = anims[ math.random( 1, #anims ) ]
		end

		local iSeq = self.Entity:LookupSequence( anim )
		if ( iSeq > 0 ) then self.Entity:ResetSequence( iSeq ) end
	end
	
	function self.modelPanel:PlayIdleAnimation( )
		local iSeq = self.Entity:LookupSequence( "walk_all" )
		if ( iSeq <= 0 ) then iSeq = self.Entity:LookupSequence( "WalkUnarmed_all" ) end
		if ( iSeq <= 0 ) then iSeq = self.Entity:LookupSequence( "walk_all_moderate" ) end

		if ( iSeq > 0 ) then self.Entity:ResetSequence( iSeq ) end
	end
end

function PANEL:OnSelected( )
	self.modelPanel:PlayPreviewAnimation( )
	Pointshop2.previewPanel._oldModel = Pointshop2.previewPanel.Entity:GetModel( )
	Pointshop2.previewPanel._oldBodygroups = {}
	for i = 0, Pointshop2.previewPanel.Entity:GetNumBodyGroups( ) - 1 do
		if Pointshop2.previewPanel.Entity:GetBodygroupCount( i ) <= 1 then 
			continue 
		end
		Pointshop2.previewPanel._oldBodygroups[i] = Pointshop2.previewPanel.Entity:GetBodygroup( i )
	end
	if self.modelPanel.Entity:SkinCount( ) > 1 then
		Pointshop2.previewPanel._oldSkin = Pointshop2.previewPanel.Entity:GetSkin( )
	else
		Pointshop2.previewPanel._oldSkin = nil
	end
	
	Pointshop2.previewPanel:SetModel( self.modelPanel.Entity:GetModel( ) )
	
	for i = 0, self.modelPanel.Entity:GetNumBodyGroups( ) - 1 do
		if self.modelPanel.Entity:GetBodygroupCount( i ) <= 1 then 
			continue 
		end
		Pointshop2.previewPanel.Entity:SetBodygroup( i, self.modelPanel.Entity:GetBodygroup( i ) )
	end
	if self.modelPanel.Entity:SkinCount( ) - 1 > 0 then
		Pointshop2.previewPanel.Entity:SetSkin( self.modelPanel.Entity:GetSkin( ) )
	end
end

function PANEL:OnDeselected( )
	self.modelPanel:PlayIdleAnimation( )
	Pointshop2.previewPanel:SetModel( Pointshop2.previewPanel._oldModel or LocalPlayer( ):GetModel( ) )
	
	for id, value in pairs( Pointshop2.previewPanel._oldBodygroups ) do
		Pointshop2.previewPanel.Entity:SetBodygroup( id, value )
	end
	if Pointshop2.previewPanel._oldSkin then
		Pointshop2.previewPanel.Entity:SetSkin( Pointshop2.previewPanel._oldSkin )
	end
end

function PANEL:SetItemClass( itemClass )
	self.BaseClass.SetItemClass( self, itemClass )
	
	local modelname = itemClass.model
	util.PrecacheModel( modelname )
	self.modelPanel:SetModel( modelname )
	self.modelPanel.Entity:SetPos( Vector( -100, 0, -61 ) )
	
	local groups = string.Explode( " ", itemClass.bodygroups ) 
	for k = 0, self.modelPanel.Entity:GetNumBodyGroups( ) - 1 do
		if ( self.modelPanel.Entity:GetBodygroupCount( k ) <= 1 ) then continue end
		self.modelPanel.Entity:SetBodygroup( k, groups[ k + 1 ] or 0 )
	end
	
	if self.modelPanel.Entity:SkinCount( ) - 1 > 0 then
		self.modelPanel.Entity:SetSkin( itemClass.skin )
	end
end

function PANEL:SetItem( item )
	self:SetItemClass( item.class )
end

function PANEL:SetSelected( b )
	self.Selected = b
end

derma.DefineControl( "DPointshopPlayerModelIcon", "", PANEL, "DPointshopItemIcon" )