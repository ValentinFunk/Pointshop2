local PANEL = {}

function PANEL:Init()
	self:SetVerticalScrollbarEnabled( false )
	self.maxHeight = false
	self._lastNumLines = 0
	self.textHeight = 12
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
	self:SetFontInternal( self.font or self:GetSkin( ).TextFont or "Default" )
end

function PANEL:Paint()
	self.textHeight = draw.GetFontHeight( self.font or self:GetSkin( ).TextFont or "Default" )
end

function PANEL:SizeToContents()
	self:SetTall( math.max(self:GetNumLines( ) * self.textHeight * 1.2 + 5, self.textHeight * 1.2 * 2 ) )

	if self.maxHeight then
		if self:GetTall( ) > self.maxHeight then
			self:SetTall( self.maxHeight )
			self:SetVerticalScrollbarEnabled( true )
		else
			self:SetVerticalScrollbarEnabled( false )
		end
	end

	self:SetTall( self:GetTall() )
end

vgui.Register( "DMultilineLabel", PANEL, "RichText" )
