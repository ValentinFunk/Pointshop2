local PANEL = {}

function PANEL:Init( )
end

function PANEL:SetItemClass( itemClass )
end

function PANEL:SetItem( item )
end

function PANEL:OnModified( )
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( 255, 0, 0 )
	surface.DrawRect( 0, 0, w, h )
end
derma.DefineControl( "DPointshopItemIcon", "", PANEL, "DPanel" )