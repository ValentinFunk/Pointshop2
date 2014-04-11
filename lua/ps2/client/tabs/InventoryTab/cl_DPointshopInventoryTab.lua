local PANEL = {}

function PANEL:Init( )
	self.invPage =  vgui.Create( "DPointshopInventoryPanel", self )
	self:addMenuEntry( "Items", "pointshop2/briefcase3.png", self.invPage )
	
	self.tradePanel = vgui.Create( "DPanel" )
	self:addMenuEntry( "Trade", "pointshop2/transfer.png", self.tradePanel )
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopInventoryTab" )
derma.DefineControl( "DPointshopInventoryTab", "", PANEL, "DPointshopMenuedTab" )

Pointshop2:AddTab( "Inventory", "DPointshopInventoryTab" )