local PANEL = {}

function PANEL:Init( )
	self.image = vgui.Create( "DCenteredImage", self )
	self.image:Dock( FILL )
	self.image:DockMargin( 5, 5, 5, 5 )
end

function PANEL:SetItem( item )
	self.BaseClass.SetItem( self, item )
	self.image:SetImage( item.material or item.class.material )
end


vgui.Register( "DPointshopMaterialInvIcon", PANEL, "DPointshopInventoryItemIcon" )