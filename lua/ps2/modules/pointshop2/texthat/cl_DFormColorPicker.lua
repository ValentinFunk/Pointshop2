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
    frm:SetSize( 240, 300 )
    frm:Center( )

    local picker = vgui.Create( "DColorMixer", frm )
    picker:SetColor( self.color )
    picker:Dock( TOP )

    local saveBtn = vgui.Create( "DButton", frm )
    saveBtn:Dock( TOP )
    saveBtn:SetText( "Use" )
    function saveBtn.DoClick( )
        self.color = picker:GetColor( )
        self:OnColorChanged( picker:GetColor( ) )
        frm:Remove( )
    end
end

-- FOr override
function PANEL:OnColorChanged( color )
end

vgui.Register( "DFormColorPicker", PANEL, "DButton" )

local PANEL = {}

function PANEL:Init( )

end

function PANEL:Paint( w, h )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( self.Material )

    local matrix = Matrix()
    matrix:Rotate( Angle( 0, 70, 0 ) )
    matrix:Translate( Vector( w / 2, 0, 0 ) )




    local oldW, oldH = ScrW(), ScrH()
render.SetViewPort( 0, 0, w, h )
cam.Start2D()
cam.PushModelMatrix( matrix )
	surface.DrawTexturedRect( 0, 0, w, h )
    cam.PopModelMatrix( )
cam.End2D()
render.SetViewPort( 0, 0, oldW, oldH )

	surface.SetDrawColor( 0, 0, 0, 250 )
	self:DrawOutlinedRect()

	surface.DrawRect( self.LastX, 0, 3, h )

	surface.SetDrawColor( 255, 255, 255, 250 )
	surface.DrawRect( self.LastX - 1, 0, 1, h )
end

vgui.Register( "DVerticalRGBPicker", PANEL, "DRGBPicker")
