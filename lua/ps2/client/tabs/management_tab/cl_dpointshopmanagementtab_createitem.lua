local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	local scroll = vgui.Create( "DScrollPanel", self )
	scroll:Dock( FILL )
	scroll:GetCanvas( ):DockPadding( 0, 0, 5, 5 )
	
	self:DockPadding( 10, 0, 10, 10 )
	
	local label = vgui.Create( "DLabel", scroll:GetCanvas( ) )
	label:SetText( "Select an item type" )
	label:SetColor( color_white )
	label:SetFont( self:GetSkin( ).TabFont )
	label:SizeToContents( )
	label:Dock( TOP )
	
	self.panels = vgui.Create( "DPanel", scroll:GetCanvas( ) )
	self.panels.Paint = function( a, w, h ) 
	end
	function self.panels:PerformLayout( )
		self:SizeToChildren( false, true )
	end
	self.panels:Dock( TOP )

	for k, mod in pairs( Pointshop2.Modules ) do
		if not mod.Blueprints or #mod.Blueprints == 0 then
			continue
		end
	
		local modPanel = vgui.Create( "DPanel", self.panels )
		Derma_Hook( modPanel, "Paint", "Paint", "InnerPanel" )
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

Pointshop2:AddManagementPanel( "Create Items", "pointshop2/wizard.png", "DPointshopManagementTab_CreateItem", function( )
	return PermissionInterface.query( LocalPlayer(), "pointshop2 createitems" )
end )