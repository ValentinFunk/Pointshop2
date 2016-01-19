-- Grid with gutter

local PANEL = {}

function PANEL:Init( )
	--defaults
	self.tilesize = 10
	self.columnCount = 10
	self.gutter = 10
	self.AutoTilesize = false
end

function PANEL:SetTilesize( size )
	self.tilesize = size
end

function PANEL:SetColumnCount( columnCount )
	self.columnCount = columnCount
end

function PANEL:SetGutter( gutter )
	self.gutter = gutter
end

function PANEL:SizeToContents( )
	local elems = #self:GetChildren( )

	local rows = math.ceil( elems / self.columnCount )
	local height = rows * self.tilesize + ( rows - 1 ) * self.gutter
	local width  = self.columnCount * self.tilesize + ( self.columnCount  - 1) * self.gutter
	self:SetSize( width, height )
end

function PANEL:PerformLayout( )
	local gutter = self.gutter
	local size = self.AutoTilesize and ( self:GetWide( ) - self.gutter * ( self.columnCount - 1 ) ) / self.columnCount or self.tilesize

	local i = 0
	for k, v in pairs( self:GetChildren( ) ) do
		local row = math.floor( i / self.columnCount )
		local col = i - row * self.columnCount

		local x = col * size + col * gutter
		local y = row * size + row * gutter

		v:SetPos( x, y )

		if self.AutoTilesize then
			v:SetSize( size, size )
		end

		i = i + 1
	end
end

function PANEL:Paint( )
end

vgui.Register( "DFixedGrid", PANEL, "DPanel" )
