local PANEL = {}

function PANEL:Init( )
	self:DockPadding( 5, 5, 5, 5 )
	self.title = vgui.Create( "DLabel", self )
	self.title:Dock( TOP )
	self.title:SetFont( self:GetSkin().SmallTitleFont )
	self.title:SetColor( self:GetSkin().Colours.Label.Bright )
	self.title:SetText( "" ) 
	self.title:SizeToContents( )
	self.title:DockMargin( 5, 5, 5, 0 )
end

function PANEL:SetSettingsListener( listener )
	self.listener = listener
end

function PANEL:PerformLayout( )
	self:SizeToChildren( false, true )
end

function PANEL:CreateBaseSettingPanel( lbl )
	local panel = vgui.Create( "DPanel" )
	panel.Paint = function( ) end
	panel:DockPadding( 10, 0, 10, 0 )
	
	local label = vgui.Create( "DLabel", panel )
	label:SetText( lbl )
	label:Dock( LEFT )
	label:SizeToContents( )
	label:SetContentAlignment( 6 )
	panel.label = label
	
	return panel
end

function PANEL:CreateNumberSetting( lbl, settingsPath )
	local panel = self:CreateBaseSettingPanel( lbl )
	
	panel.numberWang = vgui.Create( "DNumberWang", panel )
	panel.numberWang:Dock( RIGHT )
	function panel.numberWang.OnValueChanged( wang, val )
		self.listener:OnValueChanged( settingsPath, val )
	end
	
	function panel.SetValue( panel, val )
		panel.numberWang:SetMax( 1000 )
		panel.numberWang:SetValue( val )
		self.listener:OnValueChanged( settingsPath, val )
	end
	
	return panel
end

function PANEL:CreateCheckboxSetting( lbl, settingsPath )
	local panel = self:CreateBaseSettingPanel( lbl )
	
	panel.container = vgui.Create( "DPanel", panel )
	panel.container.Paint = function( ) end
	panel.container:Dock( RIGHT )
	function panel.container:PerformLayout( )
		self:SizeToChildren( true, false )
		self.checkbox:SetPos( 0, ( self:GetTall( ) - self.checkbox:GetTall( ) ) / 2 )
	end
	
	panel.container.checkbox = vgui.Create( "DCheckBox", panel.container )
	function panel.container.checkbox.OnChange( chkbox, val )
		self.listener:OnValueChanged( settingsPath, val )
	end
	
	function panel.SetValue( panel, val )
		panel.container.checkbox:SetChecked( val )
		self.listener:OnValueChanged( settingsPath, val )
	end
	
	return panel
end

function PANEL:AddSettingByType( lbl, settingsPath, value )
	local typeLookup = {
		boolean = "CreateCheckboxSetting",
		number = "CreateNumberSetting",
	}
	local creatorFn = typeLookup[type( value )]
	if not creatorFn then
		ErrorNoHalt( "No creator function found for " .. type( value ) )
		return
	end
	
	local settingPanel = self[creatorFn]( self, lbl, settingsPath )
	self:AddSettingPanel( settingPanel )
	return settingPanel
end

function PANEL:AddSettingPanel( pnl )
	pnl:SetParent( self )
	pnl:Dock( TOP )
	pnl:DockMargin( 0, 5, 0, 0 )
end

function PANEL:AddCheckboxedSetting( pnl )
	
end

Derma_Hook( PANEL, "Paint", "Paint", "InnerPanel" )

derma.DefineControl( "DSettingsSection", "Used by DSettingsEditor", PANEL, "DPanel" )