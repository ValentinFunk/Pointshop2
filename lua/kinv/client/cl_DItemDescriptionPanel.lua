local PANEL = {}
function PANEL:Init( )
	self:SetSkin( INVCONFIG.dermaSkin )
	self:DockPadding( 5, 10, 5, 5 )
	self.titleLabel = vgui.Create( "DLabel", self )
	self.titleLabel:DockMargin( 5, 5, 5, 0 )
	self.titleLabel:Dock( TOP )
	self.titleLabel:SetFont( "MenuFontMedium" )
	
	self.descriptionLabel = vgui.Create( "RichText", self )
	self.descriptionLabel:DockMargin( 5, 0, 10, 5 )
	self.descriptionLabel:Dock( FILL )
	self.descriptionLabel:SetVerticalScrollbarEnabled( false )
	self.descriptionLabel:SetPaintBackgroundEnabled( false )
	--self.descriptionLabel:SetMultiline( true )
	self.descriptionLabel:SetFontInternal( "MenuFont" )
	--self.descriptionLabel:SetEditable( false )
	function self.descriptionLabel:Paint( )
		--self:DrawTextEntryText( self.m_colText, self.m_colHighlight, self.m_colCursor )
	end
	
	self.weightLabel = vgui.Create( "DLabel", self )
	self.weightLabel:DockMargin( 5, 5, 5, 0 )
	self.weightLabel:Dock( BOTTOM )
	self.weightLabel:SetColor( color_white )
	self.weightLabel:SetFont( "MenuFont" )
	
	derma.SkinHook( "Layout", "ItemDescriptionPanel", self )
end

function PANEL:Think( )
	self.descriptionLabel:SetToFullHeight( )
	self.descriptionLabel:SetTall( self.descriptionLabel:GetTall( ) + 30 )
	self:SetTall( 10 + self.descriptionLabel:GetTall( ) + self.weightLabel:GetTall( ) )
	self:SizeToContents( )
end

function PANEL:SetTargetPanel( pnl )
	self.targetPanel = pnl
end

function PANEL:SetItem( item )
	local desc = item.description or item.class.description
	self.titleLabel:SetText( item.printName or item.class.printName )
	self.titleLabel:SizeToContents( )
	local text = ""
	for i = 1, #desc do
		text = text .. "\n" .. desc[i]
	end
	self.descriptionLabel:SetText( text )
	self.descriptionLabel:SizeToContents( )
	
	self.weightLabel:SetText( Format( "Weight: %i", item:getWeight( ) ) )
end
	
-- only for indexed tables!
function table.reverse ( tab )
	local size = #tab
	local newTable = {}
 
	for i,v in ipairs ( tab ) do
		newTable[size-i] = v
	end
 
	return newTable
end

Derma_Hook( PANEL, "Paint", "Paint", "ItemDescriptionPanel" )
vgui.Register( "DItemDescriptionPanel", PANEL, "DPanel" )