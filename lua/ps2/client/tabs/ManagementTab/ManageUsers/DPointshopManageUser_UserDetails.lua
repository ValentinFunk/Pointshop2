local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self:DockPadding( 10, 0, 10, 10 )
	
	local label = vgui.Create( "DLabel", self )
	label:SetText( "User Details" )
	label:SetColor( color_white )
	label:SetFont( self:GetSkin( ).TabFont )
	label:SizeToContents( )
	label:Dock( TOP )
end

function PANEL:PerformLayout( )
end

function PANEL:Paint( )
end

derma.DefineControl( "DPointshopManageUser_UserDetails", "", PANEL, "DPanel" )