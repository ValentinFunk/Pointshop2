local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self:InitText( )
end

function PANEL:InitText( )
	self.lbl = vgui.Create( "DLabel", self )
	self.lbl:Dock( FILL )
	self.lbl:SetColor( color_white )
	self.lbl:SetTextColor( color_white )
	self.lbl:SetText( "" )
	self.lbl:SetFont( self:GetSkin( ).BigTitleFont )
	self.lbl:SetContentAlignment( 5 )
end

function PANEL:Paint( w, h )
	self.lbl:SetText( self.itemClass:GetPrintName( )[1] )
	local persistenceFactor = ( isnumber( self.itemClass._persistenceId ) and self.itemClass._persistenceId or 0  )
	self.value = util.CRC( self.itemClass:GetPrintName( ) )
	math.randomseed( self.value * persistenceFactor )
	for i = 0, 10 do math.random( ) end
	
	local comp1 = math.random( ) * 360
	local comp2 = math.random( ) / 2 + 0.3
	local color = HSVToColor( comp1, 1, comp2 )
	
	if self.Selected or self.Hovered or self:IsChildHovered( 2 ) then
		draw.RoundedBox( 6, 0, 0, w, h, self:GetSkin( ).Highlight )
		draw.RoundedBox( 6, 2, 2, w - 4, h - 4, color )
	else
		draw.RoundedBox( 6, 0, 0, w, h, color )
	end
end

derma.DefineControl( "DPointshopSimpleItemIcon", "", PANEL, "DPointshopItemIcon" )

local PANEL = {}
function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self.lbl = vgui.Create( "DLabel", self )
	self.lbl:Dock( FILL )
	self.lbl:SetColor( color_white )
	self.lbl:SetTextColor( color_white )
	self.lbl:SetText( "C" )
	self.lbl:SetFont( self:GetSkin( ).BigTitleFont )
	self.lbl:SetContentAlignment( 5 )
end


function PANEL:Paint( w, h )
	self.lbl:SetText( self.item:GetPrintName( )[1] )
	local persistenceFactor = ( isnumber( self.itemClass._persistenceId ) and self.itemClass._persistenceId or 0  )
	self.value = util.CRC( self.item:GetPrintName( ) )
	math.randomseed( self.value * persistenceFactor )
	for i = 0, 10 do math.random( ) end
	
	local comp1 = math.random( ) * 360
	local comp2 = math.random( ) / 2 + 0.3
	local color = HSVToColor( comp1, 1, comp2 )
	surface.SetDrawColor( color )
	surface.DrawRect( 0, 0, w, h ) 
	do return end
	if self.Selected or self.Hovered or self:IsChildHovered( 2 ) then
		draw.RoundedBox( 6, 0, 0, w, h, self:GetSkin( ).Highlight )
		draw.RoundedBox( 6, 2, 2, w - 4, h - 4, color )
	else
		draw.RoundedBox( 6, 0, 0, w, h, color )
	end
end

function PANEL:SetItem( item )
	self.BaseClass.SetItem( self, item )
	self.itemClass = item.class
end

derma.DefineControl( "DPointshopSimpleInventoryIcon", "", PANEL, "DPointshopInventoryItemIcon" )