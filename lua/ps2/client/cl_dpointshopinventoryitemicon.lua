local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self:SetSize( 64, 64 )
	
	self:SetMouseInputEnabled( false )

	hook.Add( "PS2_InvItemIconSelected", self, function( self, itemIcon )
		if itemIcon != self and self.Selected then
			self.Selected = false
			self:OnDeselected( )
		end
	end )
end

function PANEL:SetItem( item )
	self.item = item
end

function PANEL:DoRightClick()
	self:OpenMenu()
end

function PANEL:PaintOver( w, h )
	if self.Selected then
		surface.SetDrawColor( self:GetSkin( ).Highlight )
		surface.DrawOutlinedRect( 0, 0, w, h )
	end
	self:DrawSelections()
end

function PANEL:OnSelected( )
end

function PANEL:OnDeselected( )

end

function PANEL:OnMousePressed( mcode )
	self:GetParent( ):OnMousePressed( mcode )
	DPanel.OnMousePressed( self, mcode )
	self.Selected = true
	hook.Run( "PS2_InvItemIconSelected", self, self.item )
	self:OnSelected( )
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopInvItemIcon" )

derma.DefineControl( "DPointshopInventoryItemIcon", "", PANEL, "DPanel" )