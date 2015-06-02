local PANEL = {}

function PANEL:Init( )
	self.image = vgui.Create( "DCenteredImage", self )
	self.image:Dock( FILL )
	self.image:SetMouseInputEnabled( false )
	self.image:DockMargin( 5, 5, 5, 5 )
end

function PANEL:SetItemClass( itemClass )
	self.BaseClass.SetItemClass( self, itemClass )
	self.image:SetImage( itemClass.material )
end

function PANEL:SetItem( item )
	self:SetItemClass( item.class )
end

derma.DefineControl( "DPointshopMaterialIcon", "", PANEL, "DPointshopItemIcon" )