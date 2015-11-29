local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self.settings = {}
	
	self.infoPanel = vgui.Create( "DInfoPanel", self )
	self.infoPanel:Dock( TOP )
	self.infoPanel:SetInfo( "Single Item", 
[[This item factory is used to create a single item from the shop. Pick the item below.]] 
	)
	self.infoPanel:DockMargin( 0, 0, 0, 5 )

	self.contentPanel = vgui.Create( "DPointshopContentPanel", self )
	self.contentPanel:Dock( FILL )
	--self.contentPanel:EnableModify( )
	self.contentPanel:CallPopulateHook( "PS2_PopulateContent", true )
	
	hook.Add( "PS2_ItemIconSelected", self, function( self, panel, itemClass )
		self.lbl:SetText( "Selected Item: " .. itemClass.PrintName )
		self.lbl:SizeToContents( )
		self.settings["BasicSettings.ItemClass"] = itemClass.className
	end )
	
	self.bottomPanel = vgui.Create( "DPanel", self )
	self.bottomPanel:Dock( BOTTOM )
	self.bottomPanel:SetTall( 40 )
	Derma_Hook( self.bottomPanel, "Paint", "Paint", "InnerPanelBright" )
	
	self.lbl = vgui.Create( "DLabel", self.bottomPanel )
	self.lbl:SetText( "Selected Item: None" )
	self.lbl:SetFont( self:GetSkin( ).TabFont )
	self.lbl:SetColor( color_white )
	self.lbl:DockMargin( 0, 5, 0, 5 )
	self.lbl:SizeToContents( )
end

function PANEL:Edit( settingsTbl )
	--Ignore
end

function PANEL:GetSettingsForSave( )
	if self.settings["BasicSettings.ItemClass"] == nil then
		Derma_Message( "Please select an item", "Error" )
		return
	end
	return self.settings
end

function PANEL:PerformLayout( )
end

function PANEL:Paint( w, h )

end

vgui.Register( "DSingleItemFactoryConfigurator", PANEL, "DPanel" )