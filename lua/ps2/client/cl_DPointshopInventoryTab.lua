local PANEL = {}

function PANEL:Init( )
	
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopInventoryTab" )
derma.DefineControl( "DPointshopInventoryTab", "", PANEL, "DPanel" )

Pointshop2:AddTab( "Inventory", "DPointshopInventoryTab" )