local PANEL = {}

function PANEL:Init()
	self:SetVerticalScrollbarEnabled( false )
	self.maxHeight = false
	self._lastNumLines = 0
end

function PANEL:SetMaxHeight( maxHeight )
	self.maxHeight = maxHeight
end

function PANEL:Think()
	if self:GetNumLines() != self._lastNumLines then
		self._lastNumLines = self:GetNumLines()
		self:SizeToContents()
		self:SetFontInternal( self.font or self:GetSkin( ).TextFont or "Default" )
		self:InvalidateParent()
	end
end

function PANEL:SizeToContents()
	self:SetToFullHeight( )

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
