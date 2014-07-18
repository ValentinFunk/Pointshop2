local PANEL = {}

function PANEL:Init( )
	self:SetLookAt( Vector( -100, 0, -10 ) )
	self:SetCamPos( Vector( 0, 0, 0 ) )
	self:SetDirectionalLight( BOX_RIGHT, Color( 255, 160, 80, 255 ) )
	self:SetDirectionalLight( BOX_LEFT, Color( 80, 160, 255, 255 ) )
	self:SetAmbientLight( Vector( -64, -64, -64 ) )
end

function PANEL:LayoutEntity( Entity )
	if ( self.bAnimated ) then self:RunAnimation() end
end

local mat = Material( "model/shiny" )
local mat_BlurX			= Material( "pp/blurx" )
local mat_BlurY			= Material( "pp/blury" )
function PANEL:Paint( w, h )
	if ( !IsValid( self.Entity ) ) then return end

	local x, y = self:LocalToScreen( 0, 0 )
	local w, h = self:GetSize()

	self:LayoutEntity( self.Entity )

	local ang = self.aLookAngle
	if ( !ang ) then
	ang = (self.vLookatPos-self.vCamPos):Angle()
	end
	
	if self.drawHover then
		local rt = GetRenderTarget( "_icontarget2" .. w .. h, w, h )
		if not self.mt2 then
			self.mt2 = CreateMaterial( "_icontarget2ww" .. w .. h, "UnlitGeneric" )
		end
		
		local oldRt = render.GetRenderTarget( )
		--local w, h = self:GetSize()
		local oldW, oldH = ScrW( ), ScrH( )
		render.SetRenderTarget( rt )
			render.Clear( 47, 47, 47, 255, true, true )
				
			cam.Start3D( self.vCamPos, ang, 25, 0, 0, w, h, 5, self.FarZ )
				cam.IgnoreZ( true )
				render.SuppressEngineLighting( true )
				render.MaterialOverride( Material( "models/shiny" ) )
					render.SetColorModulation( 1, 198.0 / 255, 0 )
					render.SetBlend( 1 )
					render.OverrideDepthEnable( true, false )
					self.Entity:DrawModel()
					render.OverrideDepthEnable( false )
					render.SetColorModulation( 0, 0, 0 )
				render.MaterialOverride( )
				render.SuppressEngineLighting( false )
				cam.IgnoreZ( false )
			cam.End3D()
		render.SetRenderTarget( oldRt )
		
		local effecttex = GetRenderTarget( "effec2ts"..w..h , w, h )
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
		self.mt2:SetTexture( "$basetexture", rt )
		
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
		
		self:DrawModel()
		
		render.SuppressEngineLighting( false )
	cam.IgnoreZ( false )
	cam.End3D()

	self.LastPaint = RealTime()
end

function PANEL:PlayPreviewAnimation( )
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

function PANEL:PlayIdleAnimation( )
	local iSeq = self.Entity:LookupSequence( "walk_all" )
	if ( iSeq <= 0 ) then iSeq = self.Entity:LookupSequence( "WalkUnarmed_all" ) end
	if ( iSeq <= 0 ) then iSeq = self.Entity:LookupSequence( "walk_all_moderate" ) end

	if ( iSeq > 0 ) then self.Entity:ResetSequence( iSeq ) end
end

derma.DefineControl( "DModelPanel_PlayerModel", "", PANEL, "DFixedModelPanel" )