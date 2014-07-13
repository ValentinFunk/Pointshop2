local PANEL = {}

function PANEL:Init( )
	self:SetSize( 100, 124 )

	self.icon = vgui.Create( "DImage", self )
	self.icon:Dock( FILL )
	self.icon:SetTall( 100 - 24 )
	
	self.label = vgui.Create( "DLabel", self )
	self.label:SetFont( self:GetSkin( ).fontName )
	self.label:Dock( BOTTOM )
	self.label:SetContentAlignment( 5 ) 
	self.label:SetTall( 24 )
	Derma_Hook( self.label, "Paint", "Paint", "BigButtonLabel" )
	
	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( true )
	
	derma.SkinHook( "Layout", "BigButton", self )
end

Derma_Hook( PANEL, "Paint", "Paint", "BigButton" )

derma.DefineControl( "DBigButton", "", PANEL, "DPanel" )