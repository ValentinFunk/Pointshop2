local PANEL = {}

function PANEL:Init( )
	self.choice = vgui.Create( "DRadioChoice", self )
	self.choice:Dock( FILL )
	
	local snapshotChoice = self.choice:AddOption( "Use Snapshot" )
	
	local container = vgui.Create( "DPanel", snapshotChoice )
	container:Dock( TOP )
	container:DockMargin( 100, 0, 0, 0 )
	container:SetTall( 128 )
	function container:Paint( ) end
	snapshotChoice:SetTall( 128 )
	
	self.snapshotPreview = vgui.Create( "DPreRenderedModelPanel", container )
	self.snapshotPreview.forceRender = true
	self.snapshotPreview:SetModel( "models/player/kleiner.mdl" )
	
	local sliders = vgui.Create( "DPanel", container )
	sliders:Dock( FILL )
	sliders:DockMargin( self.snapshotPreview:GetWide( ) + 5, 0, 5, 5 )
	function sliders:Paint( w, h )
	end
	self.sliders = sliders
	
	self.iconViewInfo = {
		["fov"] = 75,
		["angles"] = Angle(7.5625, 182.59375, 0),
		["origin"] = Vector(35.5625, 0.125, 69.84375),
	}
	
	local params = {
		x = { function( newVal ) 
				self.iconViewInfo.origin.x = newVal
			end, 
			-1000,
			1000,
			self.iconViewInfo.origin.x
		},
		y = { function( newVal )
				self.iconViewInfo.origin.y = newVal
			end,
			-1000,
			1000,
			self.iconViewInfo.origin.y
		}, 
		z = { function( newVal ) 
				self.iconViewInfo.origin.z = newVal
			end, 
			-1000,
			1000,
			self.iconViewInfo.origin.z
		},
		pitch = { function( newVal )
				self.iconViewInfo.angles.p = newVal
			end,
			-360, 
			360,
			self.iconViewInfo.angles.p
		},
		yaw = { function( newVal ) 
				self.iconViewInfo.angles.y = newVal
			end,
			-360, 
			360,
			self.iconViewInfo.angles.y
		},
		fov = {
			function( newVal ) 
				self.iconViewInfo.fov = newVal 
			end,
			10,
			90,
			self.iconViewInfo.fov
		}
	}
	self.params = params
	
	local label = vgui.Create( "DLabel", sliders )
	label:SetText( "Drag the grey buttons to adjust" )
	label.OwnLine = true
	label:SizeToContents( )
	label:Dock( TOP )
	
	for k, name in pairs{ "x", "y", "z", "pitch", "yaw", "fov" } do
		local infoTbl = params[name]
		
		local slider = vgui.Create( "DPanel", sliders )
		slider:SetTall( 12 )
		slider:Dock( TOP )
		slider:DockMargin( 0, 5, 0, 0 )
		function slider.Paint( ) end
		
		slider.lbl = vgui.Create( "DLabel", slider )
		slider.lbl:SetText( name )
		slider.lbl:Dock( LEFT )
		slider.lbl:SizeToContents( )
		slider.lbl:SetWide( 50 )
		
		slider.scratch = vgui.Create( "DNumberScratch", slider )
		slider.scratch:SetImageVisible( false )
		slider.scratch:SetWide( 25 ) 
		slider.scratch:Dock( LEFT )
		slider.scratch.OnValueChanged = function( _self )
			infoTbl[1]( _self:GetFloatValue( ) )
			self.snapshotPreview:SetViewInfo( self.iconViewInfo )
			slider.lbl2:SetText( math.Round( _self:GetFloatValue( ), 2 ) )
			
			self:ViewInfoChanged( self.iconViewInfo )
		end
		slider.scratch:SetMin( infoTbl[2] )
		slider.scratch:SetMax( infoTbl[3] )
		
		local targetContainer = self.choice
		function slider.scratch:PaintScratchWindow()

			if ( !self:GetActive() ) then return end

			if ( self:GetZoom() == 0 ) then self:SetZoom( self:IdealZoom() ) end

			local w, h = targetContainer:GetWide() + 20, 196
			local x, y = ScrW()/2 - w/2, ScrH()/2 - 86

			render.SetScissorRect( x, y, x+w, y+h, true )
				self:DrawScreen( x, y, w, h )
			render.SetScissorRect( x, y, w, h, false )

		end		
		
		slider.lbl2 = vgui.Create( "DLabel", slider )
		slider.lbl2:SetText( 1 )
		slider.lbl2:Dock( LEFT )
		slider.lbl2:DockMargin( 5, 0, 0, 0 )
		
		slider.scratch:SetValue( infoTbl[4] )
		slider.scratch:OnValueChanged( )
		infoTbl.slider = slider.scratch
	end
	self.snapshotPreview:SetViewInfo( self.iconViewInfo )
	
	local materialChoice = self.choice:AddOption( "Use Material" )
	local materialInputBox = vgui.Create( "DTextEntry", materialChoice )
	materialInputBox:Dock( LEFT )
	materialInputBox:DockMargin( 100, 0, 0, 0 )
	materialInputBox:SetWide( 250 )
	materialInputBox:SetTall( 30 )
	materialInputBox:SetDisabled( false )
	materialChoice:SetChecked( false )
	self.materialInputBox = materialInputBox
	
	self.choice:DockMargin( 5, 5, 5, 5 )
	function self.choice.OnChange( )
		self.materialInputBox:SetDisabled( not materialChoice:GetChecked( ) )
		self.useCustomMaterial = materialChoice:GetChecked( )
	end
	self.choice:OnChange( )
end

function PANEL:PerformLayout( )
	self.sliders:DockMargin( self.snapshotPreview:GetWide( ) + 5, 0, 5, 5 )
end

function PANEL:ViewInfoChanged( iconViewInfo )
	
end

function PANEL:SetViewInfo( viewInfo )
	self.iconViewInfo = table.Copy( viewInfo )
	self.iconViewInfo.origin = self.iconViewInfo.origin + Vector( 0, 0, 0 ) --copy
	self.iconViewInfo.angles = self.iconViewInfo.angles + Angle( 0, 0, 0 )

	self.snapshotPreview:SetViewInfo( self.iconViewInfo )
	self.params.x.slider:SetValue( self.iconViewInfo.origin.x )
	self.params.y.slider:SetValue( self.iconViewInfo.origin.y )
	self.params.z.slider:SetValue( self.iconViewInfo.origin.z )
	self.params.fov.slider:SetValue( self.iconViewInfo.fov )
	self.params.pitch.slider:SetValue( self.iconViewInfo.angles.p )
	self.params.yaw.slider:SetValue( self.iconViewInfo.angles.y )
end

function PANEL:SetPacOutfit( pacOutfit )
	self.snapshotPreview:SetPacOutfit( pacOutfit )
end

function PANEL:SetIconSize( w, h )
	self.snapshotPreview:SetSize( w, h )
end

function PANEL:GetIconInfo( )
	local info = {}
	info.useMaterialIcon = self.useCustomMaterial
	info.iconMaterial = self.materialInputBox:GetText( )
	info.iconViewInfo = self.iconViewInfo
	return info
end

function PANEL:SetIconInfo( iconInfo )
	self:SetViewInfo( iconInfo.iconViewInfo )
	if iconInfo.useMaterialIcon then
		self.choice:SelectChoice( 2 )
		self.materialInputBox:SetText( iconInfo.iconMaterial )
	end
end

function PANEL:Paint( w, h )
end

vgui.Register( "DHatIconEditor", PANEL, "DPanel" )