local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self:DockPadding( 10, 0, 10, 10 )
	
	local label = vgui.Create( "DLabel", self )
	label:SetText( "Select an item type" )
	label:SetFont( self:GetSkin( ).TabFont )
	label:SizeToContents( )
	label:Dock( TOP )
	
	for k, mod in pairs( Pointshop2.Modules ) do
		local modPanel = vgui.Create( "DPanel", self )
		Derma_Hook( modPanel, "Paint", "Paint", "InnerPanelBright" )
		modPanel:DockMargin( 0, 5, 0, 5 )
		modPanel:DockPadding( 8, 8, 8, 8 )
		modPanel:Dock( TOP )
		function modPanel:PerformLayout( )
			self.items:SizeToChildren( false, true )
			self:SizeToChildren( false, true )
		end
		
		modPanel.label = vgui.Create( "DLabel", modPanel )
		modPanel.label:DockMargin( 0, -5, 0, 8 )
		modPanel.label:SetFont( self:GetSkin( ).SmallTitleFont )
		modPanel.label:SetText( mod.Name )
		modPanel.label:SizeToContents( )
		modPanel.label:Dock( TOP )
		
		modPanel.items = vgui.Create( "DIconLayout", modPanel )
		modPanel.items:SetSpaceX( 5 )
		modPanel.items:SetSpaceY( 5 )
		modPanel.items:DockMargin( 0, 0, 8, 0 )
		modPanel.items:Dock( TOP )
		
		for _, itemInfo in pairs( mod.Blueprints ) do
			local iconButton = modPanel.items:Add( "DCreateItemButton" )
			iconButton:SetItemInfo( itemInfo )
		end
	end
	
	derma.SkinHook( "Layout", "DPointshopManagementTab_CreateItem", self )
end

function PANEL:Paint( )
end

derma.DefineControl( "DPointshopManagementTab_CreateItem", "", PANEL, "DPanel" )

Pointshop2:AddManagementPanel( "Create Items", "pointshop2/wizard.png", "DPointshopManagementTab_CreateItem" )