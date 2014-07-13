local PANEL = {}

function PANEL:Init( )
	hook.Call( "PS2_InvPreviewPanelPaint_Init", GAMEMODE, self )
end

function PANEL:Paint( w, h )
	--You can use this to overwrite the entire preview rendering
	if hook.Call( "PS2_InvPreviewPanelPaint", GAMEMODE, self ) == false then
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
	
	hook.Call( "PS2_InvPreviewPanelPaint_PreStart3D", GAMEMODE, self )
	
	local w, h = self:GetSize()
	cam.Start3D( self.vCamPos, ang, self.fFOV, x, y, w, h, 5, self.FarZ )
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
	
	hook.Run( "PS2_InvPreviewPanelPaint_PreDrawModel", self )
	self.Entity:DrawModel()
	hook.Run( "PS2_InvPreviewPanelPaint_PostDrawModel", self )
	
	render.SuppressEngineLighting( false )
	cam.IgnoreZ( false )
	cam.End3D()
	
	hook.Run( "PS2_InvPreviewPanelPaint_PostStart3D", self )
	
	self.LastPaint = RealTime()
end


derma.DefineControl( "DPointshopInventoryPreviewPanel", "", PANEL, "DPointshopPreviewPanel" )