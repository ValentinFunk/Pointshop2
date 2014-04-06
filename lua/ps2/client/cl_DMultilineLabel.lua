local PANEL = {}

function PANEL:Init()
	
end

function PANEL:PerformLayout( )
	self:SetToFullHeight( )
end

vgui.Register( "DMultilineLabel", PANEL, "RichText" )