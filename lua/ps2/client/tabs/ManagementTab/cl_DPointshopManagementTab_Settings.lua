local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	
end

derma.DefineControl( "DPointshopManagementTab_Settings", "", PANEL, "DPanel" )

Pointshop2:AddManagementPanel( "Settings", "pointshop2/advanced.png", "DPointshopManagementTab_Settings" )