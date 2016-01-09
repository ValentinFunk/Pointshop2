local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self:SetTitle( "Prop Hunt Reward Settings" )
	self:SetSize( 300, 600 )

	self:AutoAddSettingsTable( Pointshop2.GetModule( "Prop Hunt Integration" ).Settings.Server, self )
end

function PANEL:DoSave( )
	Pointshop2View:getInstance( ):saveSettings( self.mod, "Server", self.settings )
end

derma.DefineControl( "DPropHuntConfigurator", "", PANEL, "DSettingsEditor" )
