local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self.weightPanel:Remove( )
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( color_black )
	surface.DrawRect( 0, 0, w, h )
end

derma.DefineControl( "DPointshopInventoryPanel", "", PANEL, "DInventory" )