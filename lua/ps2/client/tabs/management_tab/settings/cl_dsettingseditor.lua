local PANEL = {}

function PANEL:Init( )
	self:SetTitle( "Settings Editor" )
	self.scroll = vgui.Create( "DScrollPanel", self )
	self.scroll:Dock( FILL )

	self.settings = {}
	self.settingsPanel = vgui.Create( "DSettingsPanel", self.scroll )
	self.settingsPanel:Dock( FILL )
	self.settingsPanel.settings = self.settings
	
	self.buttonBar = vgui.Create( "DIconLayout", self )
	self.buttonBar:SetBorder( 0 )
	self.buttonBar:SetSpaceX( 5 )
	self.buttonBar:DockMargin( 0, 0, 0, 0 )
	self.buttonBar:Dock( BOTTOM )
	
	self.saveButton = self:AddFormButton( vgui.Create( "DButton", self ) )
	self.saveButton:SetText( "Save" )
	self.saveButton:SetSize( 80, 25 )
	self.saveButton:PerformLayout( )
	self.saveButton:Paint( 10, 10 )
	function self.saveButton.DoClick( )
		if self:DoSave( ) != false then
			self:Close( )
		end
	end
end

function PANEL:OnValueChanged( path, value )
	self.settings[path] = value
end

function PANEL:AddFormButton( btn )
	btn:SetParent( self.buttonBar )
	return btn
end

function PANEL:AutoAddSettingsTable( tbl, settingListener )
	self.settingsPanel:AutoAddSettingsTable( tbl, settingListener )
end

function PANEL:SetData( data )
	self.settingsPanel:SetData( data )
end

function PANEL:SetModule( mod )
	self.mod = mod
end

function PANEL:DoSave( )
end

derma.DefineControl( "DSettingsEditor", "", PANEL, "DFrame" )