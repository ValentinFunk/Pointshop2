local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	local loading = vgui.Create( "DLoadingNotifier", self )
	loading:Dock( TOP )
	hook.Add( "PS2_PreReload", "Loading", function( )
		loading:Expand( )
	end )
	
	self.contentPanel = vgui.Create( "DPointshopContentPanel", self )
	self.contentPanel:Dock( FILL )
	self.contentPanel:EnableModify( )
	self.contentPanel:CallPopulateHook( "PS2_PopulateContent" )
	
	--Recreate content panel if items change
	hook.Add( "PS2_DynamicItemsUpdated", self, function( )
		self.contentPanel:Remove( )
		self:Init( )
		loading:Collapse( )
	end )
	
	derma.SkinHook( "Layout", "PointshopManagementTab_Items", self )
end

function PANEL:Paint( )
end

derma.DefineControl( "DPointshopManagementTab_Items", "", PANEL, "DPanel" )

Pointshop2:AddManagementPanel( "Manage Items", "pointshop2/settings12.png", "DPointshopManagementTab_Items", function( )
	return PermissionInterface.query( LocalPlayer(), "pointshop2 manageitems" )
end )