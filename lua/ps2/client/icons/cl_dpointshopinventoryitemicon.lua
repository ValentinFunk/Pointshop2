local PANEL = {}

function PANEL:Init( )
	self.isInventoryIcon = true
	self:SetSkin( Pointshop2.Config.DermaSkin )

	self:SetSize( 64, 64 )

	self:SetMouseInputEnabled( false )

	hook.Add( "PS2_InvItemIconSelected", self, function( _self, itemIcon, item )
		local selected = self.Selected or ( self.stackPanel and self.stackPanel.Selected )
		if itemIcon != self and selected then
			self.Selected = false
			if self.stackPanel then
				self.stackPanel.Selected = false
			end
			self:OnDeselected( )
		end
	end )
	hook.Add( "KInv_ItemsSplit", self, function( _self, info )
		hook.Run( "PS2_InvItemIconSelected" )

		if info.toSlot.itemStack.icon == self then
			self:Select( )
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
	if not self.item.class:IsValidForServer( Pointshop2.GetCurrentServerId( ) ) then
		surface.SetDrawColor( Color( 150, 100, 100, 150 ) )
		surface.DrawRect( 0, 0, w, h )
	end
end

function PANEL:OnSelected( )
end

function PANEL:OnDeselected( )
end

function PANEL:Select( )
	self.Selected = true

	local item = self.item
	if self.stackPanel then
		self.stackPanel.Selected = true
		item = self.stackPanel.items[1]
	end

	hook.Run( "PS2_InvItemIconSelected", self, item, self.stackPanel )
	self:OnSelected( )
end

function PANEL:OnMousePressed( mcode )
	self:GetParent( ):OnMousePressed( mcode )
	DPanel.OnMousePressed( self, mcode )
	self:Select( )
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopInvItemIcon" )

derma.DefineControl( "DPointshopInventoryItemIcon", "", PANEL, "DPanel" )
