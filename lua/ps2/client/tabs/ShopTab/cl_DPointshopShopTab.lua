local PANEL = {}

function PANEL:Init( )
	self:DoPopulate( )
	hook.Add( "PS2_DynamicItemsUpdated", self, function( )
		self:Clear( )
		self:DoPopulate( )
	end )
end

function PANEL:DoPopulate( )
	local dataNode = Pointshop2View:getInstance( ):getCategoryOrganization( )
	for k, category in pairs( dataNode ) do 
		local panel = vgui.Create( "DPointshopCategoryPanel" )
		panel:SetCategory( category )
		self:addMenuEntry( category.self.label, category.self.icon, panel )
	end
end

derma.DefineControl( "DPointshopShopTab", "", PANEL, "DPointshopMenuedTab" )

Pointshop2:AddTab( "Shop", "DPointshopShopTab" )