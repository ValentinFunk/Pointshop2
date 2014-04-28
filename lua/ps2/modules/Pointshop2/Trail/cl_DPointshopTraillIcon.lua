local PANEL = {}

function PANEL:Init( )
	self.image = vgui.Create( "DImage", self )
	self.image:Dock( FILL )
end

function PANEL:SetItemClass( itemClass )
	self.BaseClass.SetItemClass( self, itemClass )
	
	self.image:SetMaterial( itemClass.material )
end

function PANEL:SetItem( item )
	self:SetItemClass( item.class )
end

derma.DefineControl( "DPointshopTrailIcon", "", PANEL, "DPointshopItemIcon" )