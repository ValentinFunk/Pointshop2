local PANEL = {}

function PANEL:Init( )
	if IsValid( self.Label ) then return end

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
	--self.Label:SetExpensiveShadow( 1, Color( 0, 0, 0, 200 ) )

	self.iconContainer = self.iconContainer or vgui.Create( "DIconLayout", self )
	self.iconContainer:SetSpaceX( 5 )
	self.iconContainer:SetPos(8, 8)
	--self.iconContainer:DockMargin( 5, 5, 5, 0 )
	self.iconContainer:SetTall( 12 )
	--self.iconContainer:Dock( TOP )
	function self.iconContainer:Think( )
		if #self:GetChildren( ) == 0 then
			self:SetVisible( false )
		end
	end
	--self.Label:SetFont( self:GetSkin( ).fontName )

	hook.Add( "PS2_ItemIconSelected", self, function( self, itemIcon )
		if itemIcon != self and self.Selected then
			self.Selected = false
			self:OnDeselected( )
		end
	end )
end

local function mul(c, f)
	return Color(c.r * f, c.g * f, c.b * f)
end

function PANEL:SetRarity(rarityInfo, hack)
	local rc = rarityInfo.color
	local c = mul(rc, 1.1)
	function self.Label:Paint(w, h)
		surface.SetDrawColor(c)
		surface.DrawRect(0, 0, w, h)
	end
	self.Label:SetTall(self:GetTall() * 0.234375)
	if not hack then
		self.Label:DockMargin( 0, 0, 0, 0 )
		self:DockPadding( 1, 1, 1, 1 )
	end

    // Counting the perceptive luminance - human eye favors green color... 
    local a = 1 - ( 0.299 * rc.r + 0.587 * rc.g + 0.114 * rc.b)/255;

    if (a < 0.5) then
       self.Label:SetColor( mul(rc, 0.2) )
    else
       self.Label:SetColor( color_white )
	   self.Label:SetExpensiveShadow( 1, mul(rc, 0.4) )
	end
end

function PANEL:PerformLayout()
	self.iconContainer = self.iconContainer or vgui.Create( "DIconLayout", self )
	if IsValid(self.iconContainer) then
		self.iconContainer:SetWidth(self:GetWide())
	end
end

function PANEL:PaintOver(w, h)
	self.iconContainer:SetPaintedManually(true)
	self.iconContainer:PaintManual()
	self.iconContainer:SetPaintedManually(false)

	if self.noSelect then
		return
	end
	self:DrawSelections()
	if self.drawPrices then
		if not self.itemClass then return end
		if not LocalPlayer():PS2_CanBuyItem( self.itemClass ) then
			surface.SetDrawColor( 255, 0, 0, 10 )
			surface.DrawRect( 0, 0, w, h )
		end
	end
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

	if itemClass:isPremiumItem( ) then
		local icon = self.iconContainer:Add( "DImage" )
		icon:SetMaterial( Material( "pointshop2/donation_small.png", "noclamp smooth" ) )
		icon:SetSize( 12, 12 )
	end

	if itemClass.Ranks and #itemClass.Ranks > 0 then
		local icon = self.iconContainer:Add( "DImage" )
		icon:SetMaterial( Material( "pointshop2/sign_small.png", "noclamp smooth" ) )
		icon:SetSize( 12, 12 )
	end

	if itemClass.Servers and #itemClass.Servers > 0 then
		local icon = self.iconContainer:Add( "DImage" )
		icon:SetMaterial( Material( "pointshop2/rack1.png", "noclamp smooth" ) )
		icon:SetSize( 12, 12 )
	end

	hook.Run( "PS2_ItemIconSetClass", self, itemClass )

	self:SetSize( w, h )
end

function PANEL:SetItem( item )
	self:SetItemClass( item.class )
end

function PANEL:DoRightClick()
	if self.noEditMode then
		return
	end

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

function PANEL:OnSelected( )
end

function PANEL:OnDeselected( )

end

function PANEL:Select( )
	if self.noSelect then
		return
	end

	self.Selected = true
	self.item =  self.item and KInventory.ITEMS[self.item.id]
	hook.Run( "PS2_ItemIconSelected", self, self.item or self.itemClass )
	self:OnSelected( )
end

function PANEL:OnMousePressed( mcode )
	if self.noSelect then
		return
	end

	DPanel.OnMousePressed( self, mcode )

	if mcode == MOUSE_RIGHT then
		self:DoRightClick( )
	end

	self:Select( )
	return true
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopItemIcon" )

derma.DefineControl( "DPointshopItemIcon", "", PANEL, "DPanel" )
