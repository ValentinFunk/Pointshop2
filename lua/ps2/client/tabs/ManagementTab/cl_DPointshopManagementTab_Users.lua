local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
end

derma.DefineControl( "DPointshopManagementTab_Users", "", PANEL, "DPanel" )

Pointshop2:AddManagementPanel( "Manage Users", "pointshop2/user48.png", "DPointshopManagementTab_Users" )