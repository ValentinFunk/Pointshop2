local PANEL = {}

function PANEL:Init( )
end

function PANEL:PerformLayout()
	self.BaseClass.PerformLayout(self)

	self.Label:SetWide(self:GetWide())
	self.Label:SetPos(0, self:GetTall() - 25)
	self.Label:SetTall(25)
end

function PANEL:SetItemClass( itemClass )
	self.BaseClass.SetItemClass( self, itemClass )
	
	if itemClass.iconInfo.inv.useMaterialIcon then
		self.image:SetImage( itemClass.iconInfo.inv.iconMaterial )
	end
end

function PANEL:SetItem( item )
	self:SetItemClass( item.class )
end

function PANEL:OnSelected( )
	hook.Run( "PACItemSelected", self.itemClass )
end

function PANEL:OnDeselected( )
	hook.Run( "PACItemDeSelected", self.itemClass )
end

derma.DefineControl( "DPointshopHatIcon", "", PANEL, "DCsgoItemIcon" )