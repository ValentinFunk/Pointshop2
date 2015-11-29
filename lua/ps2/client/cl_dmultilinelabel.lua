local PANEL = {}

function PANEL:Init()
	self:SetVerticalScrollbarEnabled( false )
	hook.Add( "Think", self, function( ) self:SetFontInternal( self.font or self:GetSkin( ).TextFont or "Default" ) end )
	self.maxHeight = false
end

function PANEL:SetMaxHeight( maxHeight )
	self.maxHeight = maxHeight
end

function PANEL:PerformLayout( )
	self:SetToFullHeight( )
	self:SetTall( self:GetTall( ) + 5 )
	if self.maxHeight then
		if self:GetTall( ) > self.maxHeight then
			self:SetTall( self.maxHeight )
			self:SetVerticalScrollbarEnabled( true )
		else
			self:SetVerticalScrollbarEnabled( false )
		end
	end
end

vgui.Register( "DMultilineLabel", PANEL, "RichText" )
