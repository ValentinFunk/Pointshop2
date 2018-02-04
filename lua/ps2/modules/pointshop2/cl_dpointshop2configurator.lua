local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self:SetTitle( "Pointshop2 Basic Settings" )
	self:SetSize( 300, 600 )
	
	self:AutoAddSettingsTable( Pointshop2.GetModule( "Pointshop 2" ).Settings.Server, self )
	self:AutoAddSettingsTable( Pointshop2.GetModule( "Pointshop 2" ).Settings.Shared, self )
end

function PANEL:Validate( settings )
	if self.settings["BasicSettings.SellRatio"] > 1 then
		return false, "Sell Ration should be smaller than 1. (e.g. return 50% of price -> sell ration 0.5)"
	end

	if self.settings["BasicSettings.SellRatio"] < 0 then
		return false, "Sell Ration should be greater or equal to 0"
	end

	if self.settings["BasicSettings.DefaultSlots"] > 500 then
		return false, "Inventory slots cannot be > 500"
	end

	if self.settings["BasicSettings.DefaultSlots"] < 1 then
		return false, "Inventory slots need to be at least 1"
	end

	if self.settings["BasicSettings.DefaultWallet.Points"] > 2000000000 then
		return false, "Default Points value is too large"
	end

	if self.settings["BasicSettings.DefaultWallet.Points"] < 0 then
		return false, "Default Points need to be >= 0"
	end

	if self.settings["BasicSettings.DefaultWallet.PremiumPoints"] < 0 then
		return false, "Default Donator need to be >= 0"
	end

	if self.settings["BasicSettings.DefaultWallet.PremiumPoints"] > 2000000000 then
		return false, "Default Donator Points value is too large"
	end

	return true
end

function PANEL:DoSave( )
	local success, err = self:Validate( self.settings )
	if not success then
		Derma_Message( err, "Cannot save settings" )
		return false
	end

	Pointshop2View:getInstance( ):saveSettings( self.mod, "Shared", self.settings )
end

derma.DefineControl( "DPointshop2Configurator", "", PANEL, "DSettingsEditor" )