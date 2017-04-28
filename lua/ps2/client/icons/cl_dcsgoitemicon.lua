--[[
    Base for CSGO Style item icons (prerendered)
]]--
local PANEL = {}

function PANEL:Init( )
	self.image = vgui.Create( "DImage", self )
	self.image:SetSize( 128, 128 )
	self.image:SetMouseInputEnabled( false )
	self.image:SetPos( 0, 0 )

	self.Label:Dock( NODOCK )
	function self.Label:Paint(w, h)
		surface.SetDrawColor( 47, 47, 47, 200 )
		surface.DrawRect(0, 0, w, h)
	end
end

function PANEL:PerformLayout()
	DPointshopItemIcon.PerformLayout(self)

	self.Label:SetWide(self:GetWide())
	self.Label:SetPos(0, self:GetTall() - 25)
	self.Label:SetTall(25)
end

function PANEL:SetItemClass( itemClass )
	DPointshopItemIcon.SetItemClass( self, itemClass )
    Pointshop2.RequestIcon(itemClass, self):Then(function(icon)
        if IsValid(self) then
            self.image:SetMaterial(icon)
        end
    end)
end

function PANEL:SetItem( item )
	self:SetItemClass( item.class )
end

local function drawOutlinedBox( x, y, w, h, thickness, clr )
	surface.SetDrawColor( clr )
	for i=0, thickness - 1 do
		surface.DrawOutlinedRect( x + i, y + i, w - i * 2, h - i * 2 )
	end
end

function PANEL:PaintOver(w, h)
	DPointshopItemIcon.PaintOver(self, w, h)

	self.Label:SetPaintedManually(true)
	self.Label:PaintManual()
	self.Label:SetPaintedManually(false)
	
	if self.Selected or self.Hovered or self:IsChildHovered( 2 ) then
		drawOutlinedBox( 0, 0, w, h, 3, self:GetSkin().Highlight )
	end
end

derma.DefineControl( "DCsgoItemIcon", "", PANEL, "DPointshopItemIcon" )