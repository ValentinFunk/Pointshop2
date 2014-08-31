local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self:DockPadding( 3, 3, 3, 3 )
	
	self:SetSize( 128, 128 )
	self.actualIcon = false
	
	self:SetMouseInputEnabled( true )
	
	self.Label = self:Add( "DLabel" )
	self.Label:Dock( BOTTOM )
	self.Label:SetContentAlignment( 5 )
	self.Label:DockMargin( 0, 4, 0, 4 )
	self.Label:SetTextColor( Color( 255, 255, 255, 255 ) )
	self.Label:SetExpensiveShadow( 1, Color( 0, 0, 0, 200 ) )
	--self.Label:SetFont( self:GetSkin( ).fontName )
	
	hook.Add( "PS2_ItemIconSelected", self, function( self, itemIcon )
		if itemIcon != self and self.Selected then
			self.Selected = false
			self:OnDeselected( )
		end
	end )
end

function PANEL:GetItemClass( )
	return self.itemClass
end

function PANEL:SetItemClass( itemClass )
	self.itemClass = itemClass
	
	local w, h = itemClass:GetPointshopIconDimensions( )
	self.Label:SetText( itemClass.PrintName )
	self.Label:SetFont( self:GetSkin( ).TextFont )
	self.Label:SizeToContents( )
	
	self:SetSize( w, h )
end

function PANEL:SetItem( item )
	self:SetItemClass( item.class )
end

function PANEL:DoRightClick()
	local canvas = self:GetParent():GetSelectionCanvas( )
	if IsValid( canvas ) and canvas:NumSelectedChildren( ) > 0 then
		hook.Run( "PS2_MultiItemSelectOpenMenu", canvas:GetSelectedChildren() )
		return 
	end
	self:OpenMenu( )
end

function PANEL:OpenMenu( )
	--For override
end

function PANEL:PaintOver( w, h )
	self:DrawSelections()
end

function PANEL:OnSelected( )
end

function PANEL:OnDeselected( )

end

function PANEL:OnMousePressed( mcode )
	DPanel.OnMousePressed( self, mcode )
	
	if mcode == MOUSE_RIGHT then
		self:DoRightClick( )
	end
	
	self.Selected = true
	hook.Run( "PS2_ItemIconSelected", self, self.item or self.itemClass )
	self:OnSelected( )
	return true
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopItemIcon" )

derma.DefineControl( "DPointshopItemIcon", "", PANEL, "DPanel" )