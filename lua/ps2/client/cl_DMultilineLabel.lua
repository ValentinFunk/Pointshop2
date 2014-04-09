local PANEL = {}

function PANEL:Init()
	hook.Add( "Think", self, function( ) self:SetFontInternal( self:GetSkin( ).TextFont ) end )
end

function PANEL:PerformLayout( )
	self:SetToFullHeight( )
	self:SetTall( self:GetTall( ) + 5 )
end

vgui.Register( "DMultilineLabel", PANEL, "RichText" )