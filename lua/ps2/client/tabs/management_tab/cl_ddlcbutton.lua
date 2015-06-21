local PANEL = {}

function PANEL:Init( )
	self:SetSize( 120, 144 )
	
	self.icon:Remove( )
	self.icon = vgui.Create( "DCenteredImage", self )
	self.icon:Dock( FILL )
	self.icon:DockMargin( 10, 10, 10, 10 )
	self.icon:SetTall( 100 - 24 )
	self.icon:SetMouseInputEnabled( false )
	
	self.badge = vgui.Create( "DLabel", self )
	self.badge:Dock( TOP )
	self.badge:SetContentAlignment( 5 ) 
	self.badge:SetTall( 24 )
	Derma_Hook( self.badge, "Paint", "Paint", "BigButtonLabel" )
end

function PANEL:SetDlc( dlc )
	self.dlc = dlc
	
	self.label:SetText( dlc.name )
	self.icon:SetMaterial( Material( dlc.icon, "noclamp smooth" ) )
	
	if dlc.isOwned( ) then
		self.badge:SetText( "Owned" )
		self.badge:SetFont( self:GetSkin().SmallTitleFont )
		self.badge:SetColor( Color( 0, 255, 0 ) )
	else
		self.badge:SetText( "Not Owned" )
		self.badge:SetColor( Color( 255, 0, 0, 100 ) )
		self.icon:SetImageColor( Color( 150, 150, 150 ) )
	end
end

function PANEL:OnMousePressed( mcode )
	gui.OpenURL( self.dlc.dlcLink )
end	

function PANEL:ApplySchemeSettings( )
	self.badge:SetFont( self:GetSkin( ).TextFont or "DermaDefault" )
end

Derma_Hook( PANEL, "Paint", "Paint", "BigButton" )

derma.DefineControl( "DDlcButton", "", PANEL, "DBigButton" )