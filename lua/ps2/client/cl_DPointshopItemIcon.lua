local PANEL = {}

function PANEL:Init( )
end

function PANEL:SetItemClass( itemClass )
	if itemClass.Model then
		
	end
end

function PANEL:SetItem( item )
end

function PANEL:OnModified( )
	error( "mode" )
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( 255, 0, 0 )
	surface.DrawRect( 0, 0, w, h )
end
derma.DefineControl( "DPointshopItemIcon", "", PANEL, "DPanel" )