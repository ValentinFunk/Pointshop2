local PANEL = {}

function PANEL:InitText( )
    self:SetSkin( Pointshop2.Config.DermaSkin )

    self.lbl = vgui.Create( "DLabel", self )
	self.lbl:Dock( FILL )
	self.lbl:SetColor( color_white )
	self.lbl:SetTextColor( color_white )
	self.lbl:SetText( "" )
	self.lbl:SetFont( self:GetSkin( ).DermaDefault )
	self.lbl:SetContentAlignment( 5 )
end

-- Default Paint
function PANEL:Paint( w, h )
    derma.Hook( "Paint", "PointshopItemIcon" )
    draw.SimpleTextOutlined( "Text Hat", "DermaDefault", w / 2, h / 2, self.itemClass.color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, self.itemClas.outlineColor )
end

function PANEL:Think( )
    if self.itemClass.rainbow then
        self.lbl:SetColor( HSVToColor( CurTime() * 20 % 360, 1, 1 ) )
    end
end

vgui.Register( "DTexthatItemIcon", PANEL, "DPointshopItemIcon" )
