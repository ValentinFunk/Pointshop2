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
	
	function self.label:Paint( w, h )
		surface.SetDrawColor( self:GetSkin( ).InnerPanel )
		surface.DrawRect( 0, 0, w, h )
	end
	
	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( true )
	
	derma.SkinHook( "Layout", "DCreateItemButton", self )
end

function PANEL:OnMousePressed( )
	local creator = vgui.Create( self.itemInfo.creator )
	creator:Center( )
	creator:MakePopup( )
	creator:SetItemBase( self.itemInfo.base )
end

function PANEL:SetItemInfo( itemInfo )
	self.icon:SetImage( itemInfo.icon )
	self.label:SetText( itemInfo.label )
	self.itemInfo = itemInfo
end

Derma_Hook( PANEL, "Paint", "Paint", "CreateItemButton" )

derma.DefineControl( "DCreateItemButton", "", PANEL, "DPanel" )