local PANEL = { }

function PANEL:Init()
	self:SetSkin(Pointshop2.Config.DermaSkin)
	self:SetTitle("Murder Reward Settings")
	self:SetSize(300, 600)
	
	self:AutoAddSettingsTable(Pointshop2.GetModule("Murder Integration").Settings.Server, self)
end

function PANEL:DoSave( )
	Pointshop2View:getInstance():saveSettings(self.mod, "Server", self.settings)
end

derma.DefineControl("DMurderConfigurator", "", PANEL, "DSettingsEditor")