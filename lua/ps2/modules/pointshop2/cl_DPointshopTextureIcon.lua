local function paintCentered(texId, w, h)
    surface.SetTexture( texId )
    surface.SetDrawColor( 255, 255, 255, 255 )
    local tw, th = surface.GetTextureSize( texId )
    local draw = math.min( w, h, math.max( tw, th ) )
    
    local x = ( w - draw ) / 2
    local y = ( h - draw ) / 2
    surface.DrawTexturedRect( x, y, draw, draw )
end

local PANEL = {}

function PANEL:Init( )
    self.image = vgui.Create( "DImage", self )
    self.image:Dock( FILL )
    self.image:SetMouseInputEnabled( false )
    self.image:DockMargin( 5, 5, 5, 5 ) 
end

function PANEL:SetItemClass( itemClass )
    self.BaseClass.SetItemClass( self, itemClass )
    if itemClass.texture then
        function self.image:Paint( w, h )
            paintCentered( itemClass.texture, w, h )
        end
    else
        ErrorNoHalt( "Invalid texture on item class " .. tostring( itemClass.name ) )
    end
end

function PANEL:SetItem( item )
    self:SetItemClass( item.class )
end

derma.DefineControl( "DPointshopTextureIcon", "", PANEL, "DPointshopItemIcon" )

local PANEL = {}

function PANEL:Init( )
    self.image = vgui.Create( "DImage", self )
    self.image:Dock( FILL )
    self.image:SetMouseInputEnabled( false )
    self.image:DockMargin( 5, 5, 5, 5 ) 
end

function PANEL:SetItem( item )
    self.BaseClass.SetItem( self, item )
    if item.class.texture then
        function self.image:Paint( w, h )
            paintCentered( item.class.texture, w, h )
        end
    else
        ErrorNoHalt( "Invalid texture on item class " .. tostring( item.class.name ) )
    end
end

derma.DefineControl( "DPointshopTextureInvIcon", "", PANEL, "DPointshopInventoryItemIcon" )