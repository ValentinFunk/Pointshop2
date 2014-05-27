local PANEL = {}

function PANEL:Init( )
	self.image = vgui.Create( "DImage", self )
	self.image:Dock( TOP )
	self.image:SetSize( 64, 64 )
	self.image:DockMargin( 5, 0, 5, 5 )
end

function PANEL:SetItemClass( itemClass )
	self.BaseClass.SetItemClass( self, itemClass )
end

function PANEL:SetItem( item )
	self:SetItemClass( item.class )
end

function PANEL:PerformLayout( )
	self:SetTall( self.image:GetTall( ) + self.Label:GetTall( ) + 10 )
end

derma.DefineControl( "DPointshopHatIcon", "", PANEL, "DPointshopItemIcon" )