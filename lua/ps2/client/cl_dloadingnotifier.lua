local PANEL = {}

AccessorFunc( PANEL, "openSize", "OpenSize" )

function PANEL:Init( )
	self:SetOpenSize( 50 )

	self.loadingText = vgui.Create( "DLabel", self )
	self.loadingText:Dock( FILL )
	self.loadingText:SetText( "Loading..." )
	self.loadingText:SetContentAlignment( 5 )

	self:SetTall( 0 )
end

function PANEL:Expand( )
	self:SizeTo( self:GetWide( ), self:GetOpenSize( ), 0.3 )
end

function PANEL:Collapse( )
	self:SizeTo( self:GetWide( ), 0, 0.3 )
end

function PANEL:Think( )
	local dots = string.rep( ".", math.floor( CurTime( ) % 3 + 1 ) )
	self.loadingText:SetText( "Loading" ..  dots )
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( self:GetSkin( ).Highlight )
	surface.DrawRect( 4, self:GetTall() - 10, self:GetWide() - 8, 5 )

	surface.SetDrawColor( 50, 50, 0, 255 )
	surface.DrawRect( 5, self:GetTall() - 9, self:GetWide() - 10, 3 )

	local w = self:GetWide() * 0.25
	local x = math.fmod( SysTime() * 200, self:GetWide() + w ) - w

	if ( x + w > self:GetWide() - 11 ) then w = ( self:GetWide() - 11 ) - x end
	if ( x < 0 ) then w = w + x; x = 0 end

	surface.SetDrawColor( self:GetSkin( ).Highlight )
	surface.DrawRect( 5 + x, self:GetTall() - 9, w, 3 )
end


derma.DefineControl( "DLoadingNotifier", "", PANEL, "DPanel" )
