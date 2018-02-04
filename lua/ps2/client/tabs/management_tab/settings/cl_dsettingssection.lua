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

function PANEL:CreateBaseSettingPanel( settingsPath, settingInfo )
	local panel = vgui.Create( "DPanel" )
	panel.Paint = function( ) end
	panel:DockPadding( 10, 0, 10, 0 )
	panel:SetTooltip( settingInfo.tooltip or "" )
	
	local label = vgui.Create( "DLabel", panel )
	label:SetText( settingInfo.label )
	label:Dock( LEFT )
	label:SizeToContents( )
	label:SetContentAlignment( 6 )
	panel.label = label
	
	return panel
end

function PANEL:CreateNumberSetting( settingsPath, settingInfo )
	local panel = self:CreateBaseSettingPanel( settingsPath, settingInfo )
	
	panel.numberWang = vgui.Create( "DNumberWang", panel )
	panel.numberWang:Dock( RIGHT )
	function panel.numberWang.OnValueChanged( wang, val )
		val = tonumber( val )
		self.listener:OnValueChanged( settingsPath, val )
	end
	
	function panel.SetValue( panel, val )
		panel.numberWang:SetMax( val < 1000 and 1000 or val * 10 )
		panel.numberWang:SetValue( val )
		self.listener:OnValueChanged( settingsPath, val )
	end
	
	return panel
end

function PANEL:CreateTextentrySetting( settingsPath, settingInfo )
    local panel = self:CreateBaseSettingPanel( settingsPath, settingInfo )
    
    panel.textEntry = vgui.Create( "DTextEntry", panel )
    panel.textEntry:Dock( RIGHT )
    panel.textEntry:SetUpdateOnType( true )
    function panel.textEntry.OnValueChange( wang, val )
        self.listener:OnValueChanged( settingsPath, val )
    end
    
    function panel.SetValue( panel, val )
        panel.textEntry:SetValue( val )
        self.listener:OnValueChanged( settingsPath, val )
    end
    
    return panel
end

function PANEL:CreateCheckboxSetting( settingsPath, settingInfo )
	local panel = self:CreateBaseSettingPanel( settingsPath, settingInfo )
	
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

function PANEL:CreateComboboxSetting( settingsPath, settingInfo )
	local panel = self:CreateBaseSettingPanel( settingsPath, settingInfo )
	
	panel.combobox = vgui.Create( "DComboBox", panel )
	panel.combobox:Dock( RIGHT )
	for k, v in pairs( settingInfo.possibleValues ) do
		panel.combobox:AddChoice( v )
	end
	function panel.combobox.OnSelect( _self, index, val )
		self.listener:OnValueChanged( settingsPath, val )
	end

	function panel.SetValue( panel, val )
		panel.combobox:ChooseOption( val )
		self.listener:OnValueChanged( settingsPath, val )
	end
	
	return panel
end 

function PANEL:AddSettingByType( settingsPath, settingInfo )
	local typeLookup = {
		boolean = "CreateCheckboxSetting",
		number = "CreateNumberSetting",
		option = "CreateComboboxSetting",
		string = "CreateTextentrySetting",
	}
	
	local valueType = settingInfo.type or type( settingInfo.value )
	local creatorFn = typeLookup[valueType]
	if not creatorFn then
		ErrorNoHalt( "No creator function found for " .. type( value ) )
		return
	end
	
	local settingPanel = self[creatorFn]( self, settingsPath, settingInfo )
	self:AddSettingPanel( settingPanel )
	if settingInfo.value then
		settingPanel:SetValue( settingInfo.value )
	end
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