local PANEL = {}

function PANEL:Init( )
	self.image = vgui.Create( "DImage", self )
	self.image:Dock( FILL )
end

function PANEL:SetItem( item )
	self.item = item 
	self.image:SetMaterial( item.class.material )
end

vgui.Register( "DPointshopHatInvIcon", PANEL, "DPointshopInventoryItemIcon" )