local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	
	
	derma.SkinHook( "Layout", "PointshopManagementTab_Servers", self )
end

function PANEL:Paint( )
end

derma.DefineControl( "DPointshopManagementTab_Servers", "", PANEL, "DPanel" )

Pointshop2:AddManagementPanel( "Manage Servers", "pointshop2/rack1.png", "DPointshopManagementTab_Servers", function( )
	return PermissionInterface.query( LocalPlayer(), "pointshop2 manageservers" )
end )