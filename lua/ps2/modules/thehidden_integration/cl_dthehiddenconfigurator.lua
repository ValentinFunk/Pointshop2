local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self:SetTitle( "The Hidden Reward Settings" )
	self:SetSize( 300, 600 )
	
	self:AutoAddSettingsTable( Pointshop2.GetModule( "Hidden Integration" ).Settings.Server, self )
	self:AutoAddSettingsTable( Pointshop2.GetModule( "Hidden Integration" ).Settings.Shared, self )
end

function PANEL:DoSave( )
	Pointshop2View:getInstance( ):saveSettings( self.mod, "Shared", self.settings )
end

derma.DefineControl( "DTheHiddenConfigurator", "", PANEL, "DSettingsEditor" )