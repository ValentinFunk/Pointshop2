local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	

end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopEquipmentSlot" )
derma.DefineControl( "DPointshopEquipmentSlot", "", PANEL, "DPanel" )