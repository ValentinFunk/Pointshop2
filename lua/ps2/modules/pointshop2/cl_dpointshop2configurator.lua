local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self:SetTitle( "Pointshop2 Basic Settings" )
	self:SetSize( 300, 600 )
	
	self:AutoAddSettingsTable( Pointshop2.GetModule( "Pointshop 2" ).Settings.Server, self )
	self:AutoAddSettingsTable( Pointshop2.GetModule( "Pointshop 2" ).Settings.Shared, self )
end

function PANEL:DoSave( )
	Pointshop2View:getInstance( ):saveSettings( self.mod, "Shared", self.settings )
end

derma.DefineControl( "DPointshop2Configurator", "", PANEL, "DSettingsEditor" )