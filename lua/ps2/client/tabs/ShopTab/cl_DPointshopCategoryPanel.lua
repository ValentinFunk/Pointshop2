local PANEL = {}

function PANEL:Init( )
	
end

function PANEL:SetCategory( category )
	self.category = category
end

function PANEL:Paint( w, h )
end

derma.DefineControl( "DPointshopCategoryPanel", "", PANEL, "DPanel" )