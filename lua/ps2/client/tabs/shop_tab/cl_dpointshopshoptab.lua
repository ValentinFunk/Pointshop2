local PANEL = {}

function PANEL:Init( )
	self.rightBar = vgui.Create( "DPanel", self )
	self.rightBar:Dock( RIGHT )
	self.rightBar:SetWide( self.leftBar:GetWide( ) - 23 )
	Derma_Hook( self.rightBar, "Paint", "Paint", "InnerPanel" )
	
	self.previewPanel = vgui.Create( "DPointshopPreviewPanel", self.rightBar )
	self.previewPanel:Dock( TOP )
	self.previewPanel:SetTall( 320 )
	self.previewPanel:SetFOV( 43 )
	self.previewPanel:SetAnimated( true )
	
	self.descPanel = vgui.Create( "DPointshopItemDescription", self.rightBar )
	self.descPanel:Dock( TOP )
	hook.Add( "PS2_ItemIconSelected", self, function( self, panel, itemClass )
		if not IsValid( panel ) or not itemClass then
			self.descPanel:SelectionReset( )
			return
		end
		if self.descPanel.ClassName != itemClass.GetPointshopDescriptionControl( ) then
			self.descPanel:Remove( )
			self.descPanel = vgui.Create( itemClass.GetPointshopDescriptionControl( ), self.rightBar )
			self.descPanel:Dock( TOP )
		end
		self.descPanel:SetItemClass( itemClass )
	end )
	
	Pointshop2.previewPanel = self.previewPanel
	
	self:DoPopulate( )
	hook.Add( "PS2_DynamicItemsUpdated", self, function( )
		self:Clear( )
		self:DoPopulate( )
	end )
end

function PANEL:OnTabChanged( newTab )
	hook.Call( "PS2_ItemIconSelected" ) --Reset selection
end

function PANEL:DoPopulate( )
	local dataNode = Pointshop2View:getInstance( ):getCategoryOrganization( )
	for k, category in pairs( dataNode ) do 
		local sp = vgui.Create("DScrollPanel")
		local panel = vgui.Create( "DPointshopCategoryPanel", sp )
		panel:Dock(FILL)
		panel:SetCategory( category )
		self:addMenuEntry( category.self.label, category.self.icon, sp )
	end
end

derma.DefineControl( "DPointshopShopTab", "", PANEL, "DPointshopMenuedTab" )

Pointshop2:AddTab( "Shop", "DPointshopShopTab" )