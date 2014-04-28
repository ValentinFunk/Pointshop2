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
	local pCanvas = self:GetSelectionCanvas()
	if ( IsValid( pCanvas ) && pCanvas:NumSelectedChildren() > 0 ) then
		return hook.Run( "PS2_SpawnlistOpenGenericMenu", pCanvas )
	end

	self:OpenMenu()
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
	self.Selected = true
	hook.Run( "PS2_ItemIconSelected", self, self.item or self.itemClass )
	self:OnSelected( )
	return true
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopItemIcon" )

derma.DefineControl( "DPointshopItemIcon", "", PANEL, "DPanel" )