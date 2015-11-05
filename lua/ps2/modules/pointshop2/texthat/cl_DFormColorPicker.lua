local PANEL = {}

function PANEL:Init( )
    self.color = Color( 255, 0, 0 )
    self:SetText( "" )
end

function PANEL:SetColor( color )
    self.color = color
    self:OnColorChanged( self.color )
end

function PANEL:Paint( w, h )
    surface.SetDrawColor( self.color )
    surface.DrawRect( 0, 0, w, h )
end

function PANEL:DoClick( )
    local frm = vgui.Create("DFrame")
    frm:SetTitle("color")
    frm:SetSkin( Pointshop2.Config.DermaSkin )
    frm:MakePopup()
    frm:DoModal()

    local saveBtn = vgui.Create( "DButton", frm )
    saveBtn:Dock( TOP )
    saveBtn:SetText( "Use" )
    function saveBtn.DoClick( )
        self.color = picker:GetColor( )
        self:OnColorChanged( picker:GetColor( ) )
        frm:Remove( )
    end

    local picker = vgui.Create( "DColorMixer", frm )
    picker:SetColor( self.color )
    picker:Dock( TOP )
end

-- FOr override
function PANEL:OnColorChanged( color )
end

vgui.Register( "DFormColorPicker", PANEL, "DButton" )
