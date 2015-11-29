local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self.infoPanel = vgui.Create( "DInfoPanel", self )
	self.infoPanel:Dock( TOP )
	self.infoPanel:SetInfo( "Points Giver", 
[[This item factory is used to create items that give points to players when redeemed. ]] 
	)
	self.infoPanel:DockMargin( 0, 0, 0, 5 )

	self.actualSettings = vgui.Create( "DSettingsPanel", self )
	self.actualSettings:Dock( FILL )
	self.actualSettings:AutoAddSettingsTable( Pointshop2.PointsFactory.Settings )
	self:InvalidateLayout()
end

function PANEL:OnDone( )

end

function PANEL:Edit( settingsTbl )
	self.actualSettings:SetData( settingsTbl )
end

function PANEL:GetSettingsForSave( )
	return self.actualSettings.settings
end

function PANEL:Paint( w, h )
end

function PANEL:PerformLayout( )
	if IsValid( self.actualSettings ) then
		self.actualSettings:SizeToChildren( false, true )
	end
end

function PANEL:Paint( w, h )

end

vgui.Register( "DPointsFactoryConfigurator", PANEL, "DPanel" )