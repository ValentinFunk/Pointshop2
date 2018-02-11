local PANEL = {}

function PANEL:Init( )
	self:ApplyModelInfo( Pointshop2:GetPreviewModel( ) )
	hook.Add( "PS2_DoUpdatePreviewModel", self, function( self )
		self:ApplyModelInfo( Pointshop2:GetPreviewModel( ) )
	end )
	
	hook.Call( "PS2_PreviewPanelPaint_Init", GAMEMODE, self )
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

function PANEL:LayoutEntity( entity )
	if ( self.bAnimated ) then
		self:RunAnimation()
	end
	
	self.Angles = self.Angles or Angle( 0, 0, 0 )
	if ( self.Pressed ) then
		local mx, my = gui.MousePos()
		self.Angles = self.Angles - Angle( 0, ( self.PressX or mx ) - mx, 0 )
		
		self.PressX, self.PressY = gui.MousePos()
	end

	entity:SetAngles( self.Angles )
end

function PANEL:Think( )
	self.Angles = self.Angles or Angle( 0, 0, 0 )
	if not self.Pressed then
		self.Angles = self.Angles + Angle( 0, FrameTime( ) * 20, 0 )
	end
end

--Hold&drag to rotate
function PANEL:DragMousePress()
	self.PressX, self.PressY = gui.MousePos()
	self.Pressed = true
end

function PANEL:DragMouseRelease( ) 
	self.Pressed = false 
end

function PANEL:Paint( w, h )
	--You can use this to overwrite the entire preview rendering
	if hook.Call( "PS2_PreviewPanelPaint", GAMEMODE, self ) == false then
		return
	end
	
	
	derma.SkinHook( "Paint", "InnerPanel", self, w, h )
	
	if ( !IsValid( self.Entity ) ) then return end
	
	local x, y = self:LocalToScreen( 0, 0 )
	
	self:LayoutEntity( self.Entity )
	
	local ang = self.aLookAngle
	if ( !ang ) then
		ang = (self.vLookatPos-self.vCamPos):Angle()
	end
	
	hook.Call( "PS2_PreviewPanelPaint_PreStart3D", GAMEMODE, self )
	
	local w, h = self:GetSize()
	cam.Start3D( self.vCamPos * 1.1, ang, self.fFOV, x, y, w, h, 5, self.FarZ )
	
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
	
	local curparent = self
	local rightx = self:GetWide()
	local leftx = 0
	local topy = 0
	local bottomy = self:GetTall()
	local previous = curparent
	while( curparent:GetParent() != nil ) do
		curparent = curparent:GetParent()
		local x, y = previous:GetPos()
		topy = math.Max( y, topy + y )
		leftx = math.Max( x, leftx + x )
		bottomy = math.Min( y + previous:GetTall(), bottomy + y )
		rightx = math.Min( x + previous:GetWide(), rightx + x )
		previous = curparent
	end
	render.SetScissorRect( leftx, topy, rightx, bottomy, true )
	
	hook.Call( "PS2_PreviewPanelPaint_PreDrawModel", GAMEMODE, self )
	self.Entity:DrawModel()
	hook.Call( "PS2_PreviewPanelPaint_PostDrawModel", GAMEMODE, self )
	render.SetScissorRect( 0, 0, 0, 0, false )
	
	render.SuppressEngineLighting( false )
	cam.IgnoreZ( false )
	cam.End3D()
	
	hook.Call( "PS2_PreviewPanelPaint_PostStart3D", GAMEMODE, self )
	
	self.LastPaint = RealTime()
end


derma.DefineControl( "DPointshopPreviewPanel", "", PANEL, "DModelPanel" )