local PANEL = {}

function PANEL:InitText( )
    self:SetSkin( Pointshop2.Config.DermaSkin )
end

-- Default Paint
function PANEL:Paint( w, h )
    derma.SkinHook( "Paint", "PointshopItemIcon", self, w, h )
    if self.itemClass.rainbow then
        self.itemClass.color = HSVToColor( RealTime() * 20 % 360, 1, 1 )
    end
    draw.SimpleTextOutlined( "Text Hat", self:GetSkin().TabFont, w / 2, h / 2, self.itemClass.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, self.itemClass.outlineColor )
end

function PANEL:Think( )
end

vgui.Register( "DTexthatItemIcon", PANEL, "DPointshopItemIcon" )
