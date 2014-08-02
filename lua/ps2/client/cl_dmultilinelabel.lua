local PANEL = {}

function PANEL:Init()
	self:SetVerticalScrollbarEnabled( false )
	hook.Add( "Think", self, function( ) self:SetFontInternal( self.font or self:GetSkin( ).TextFont or "Default" ) end )
end

function PANEL:PerformLayout( )
	self:SetToFullHeight( )
	self:SetTall( self:GetTall( ) + 5 )
end

vgui.Register( "DMultilineLabel", PANEL, "RichText" )