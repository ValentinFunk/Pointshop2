local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self:DockPadding( 10, 0, 10, 10 )
	
	local label = vgui.Create( "DLabel", self )
	label:SetText( "Local Settings" )
	label:SetColor( color_white )
	label:SetFont( self:GetSkin( ).TabFont )
	label:SizeToContents( )
	label:Dock( TOP )
	label:DockMargin( 0, 0, 0, 5 )
	
	self.scroll = vgui.Create( "DScrollPanel", self )
	self.scroll:Dock( FILL )
	
	self.actualSettings = vgui.Create( "DSettingsPanel", self.scroll )
	self.actualSettings:Dock( TOP )
	self.actualSettings:AutoAddSettingsTable( Pointshop2.ClientSettings.SettingsTable )
	self.actualSettings:DockMargin( 0, 0, 0, 5 )
	self.actualSettings:SetWide( 250 )
	self.actualSettings:SetData( Pointshop2.ClientSettings.Settings )
	
	self.buttonBar = vgui.Create( "DIconLayout", self.scroll )
	self.buttonBar:SetBorder( 0 )
	self.buttonBar:SetSpaceX( 5 )
	self.buttonBar:DockMargin( 0, 0, 0, 0 )
	self.buttonBar:Dock( TOP )
	
	self.saveButton = vgui.Create( "DButton", self.buttonBar )
	self.saveButton:SetText( "Save" )
	self.saveButton:SetSize( 80, 25 )
	self.saveButton:PerformLayout( )
	self.saveButton:Paint( 10, 10 )
	function self.saveButton.DoClick( )
		Pointshop2.ClientSettings.SaveSettings( self.actualSettings.settings )
		Pointshop2.ClientSettings.LoadSettings( )
		Derma_Message( "Your settings have been saved. Some settings may require a reconnect to apply." )
	end
end

function PANEL:Paint( )
end


derma.DefineControl( "DPointshopClientSettings", "", PANEL, "DPanel" )

Pointshop2:AddInventoryPanel( "My Settings", "pointshop2/advanced.png", "DPointshopClientSettings" )