local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self:DockPadding( 10, 0, 10, 10 )
	
	local label = vgui.Create( "DLabel", self )
	label:SetText( "Export or import Pointshop 2 data" )
	label:SetColor( color_white )
	label:SetFont( self:GetSkin( ).TabFont )
	label:SizeToContents( )
	label:Dock( TOP )
	
	local modPanel = vgui.Create( "DPanel", self )
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
	modPanel.label:SetText( "Select an action" )
	modPanel.label:SizeToContents( )
	modPanel.label:Dock( TOP )
	
	modPanel.items = vgui.Create( "DIconLayout", modPanel )
	modPanel.items:SetSpaceX( 5 )
	modPanel.items:SetSpaceY( 5 )
	modPanel.items:DockMargin( 0, 0, 8, 0 )
	modPanel.items:Dock( TOP )
	
	for label, btnInfo in pairs{
		Export = { func = self.ExportItems, icon = "pointshop2/small65.png" },
		Import = { func = self.ImportItems, icon = "pointshop2/download7.png" }
	} 
	do
		local button = modPanel.items:Add( "DBigButton" )
		button.icon:SetImage( btnInfo.icon )
		button.label:SetText( label )
		button.DoClick = function( )
			func( self )
		end
	end
	
	derma.SkinHook( "Layout", "DPointshopManagementTab_ExportImport", self )
end

function PANEL:ExportItems( )
	Pointshop2View:getInstance( ):exportItems( )
end

function PANEL:ImportItems( itemFile )
	Pointshop2View:getInstance( ):importItems( itemFile )
end

function PANEL:Paint( )
end

derma.DefineControl( "DPointshopManagementTab_ExportImport", "", PANEL, "DPanel" )

Pointshop2:AddManagementPanel( "Export / Import", "pointshop2/two259.png", "DPointshopManagementTab_ExportImport", function( )
	--Experimental Feature, Currently hardcoded to devs
	return table.HasValue( {
		"STEAM_0:0:19299911",
		"STEAM_0:0:39587206"
	}, LocalPlayer():SteamID( ) )
end )