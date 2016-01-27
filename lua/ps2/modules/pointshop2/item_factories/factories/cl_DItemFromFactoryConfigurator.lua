local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self.settings = {}

	self.infoPanel = vgui.Create( "DInfoPanel", self )
	self.infoPanel:Dock( TOP )
	self.infoPanel:SetInfo( "Random Item from Category",
[[This item factory is used to create a random item from a category. Pick the category below.

You can choose to weight the item by price: This means that items with a higher price get chosen less frequently. The chance is automatically calculated to match the price differences.
If you leave the option unticked all items have the same chance. Premium points are valued as 10 times normal points.
]]
	)
	self.infoPanel:DockMargin( 0, 0, 0, 5 )

	self.contentPanel = vgui.Create( "DPointshopContentPanel", self )
	self.contentPanel:Dock( FILL )
	--self.contentPanel:EnableModify( )
	self.contentPanel:CallPopulateHook( "PS2_PopulateContent", true )

	hook.Add( "PS2_CategorySelected", self, function( self, node, categoryInfo )
		if node.specialNode or not categoryInfo then
			--Uncategorized or root node
			return
		end

		self.actualSettings.settings["ManualSettings.CategoryName"] = categoryInfo.self.label
		self.lbl:SetText( "Selected Category: " .. categoryInfo.self.label )
		self.lbl:SizeToContents( )
	end )

	self.actualSettings = vgui.Create( "DSettingsPanel", self )
	self.actualSettings:Dock( TOP )
	self.actualSettings:AutoAddSettingsTable( Pointshop2.ItemFromCategoryFactory.Settings )
	self.actualSettings:DockMargin( 0, 0, 0, 5 )
	self:InvalidateLayout()

	self.bottomPanel = vgui.Create( "DPanel", self )
	self.bottomPanel:Dock( BOTTOM )
	self.bottomPanel:SetTall( 40 )
	Derma_Hook( self.bottomPanel, "Paint", "Paint", "InnerPanelBright" )

	self.lbl = vgui.Create( "DLabel", self.bottomPanel )
	self.lbl:SetText( "Selected Category: None" )
	self.lbl:SetFont( self:GetSkin( ).TabFont )
	self.lbl:SetColor( color_white )
	self.lbl:DockMargin( 0, 5, 0, 5 )
	self.lbl:SizeToContents( )
end

function PANEL:Edit( settingsTbl )
	self.actualSettings:SetData( settingsTbl )
	--Ignore
end

function PANEL:GetSettingsForSave( )
	if self.actualSettings.settings["ManualSettings.CategoryName"] == nil then
		Derma_Message( "Please select a category", "Error" )
		return
	end
	return self.actualSettings.settings
end

function PANEL:PerformLayout( )
end

function PANEL:Paint( w, h )

end

vgui.Register( "DItemFromCategoryFactoryConfigurator", PANEL, "DPanel" )
