local PANEL = {}

function PANEL:Init( )
	self.leftBar = vgui.Create( "DPanel", self )
	self.leftBar:Dock( LEFT )
	self.leftBar:SetWide( 245 )
	Derma_Hook( self.leftBar, "Paint", "Paint", "InnerPanel" )
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopShopTab" )
derma.DefineControl( "DPointshopShopTab", "", PANEL, "DPanel" )

Pointshop2:AddTab( "Shop", "DPointshopShopTab" )