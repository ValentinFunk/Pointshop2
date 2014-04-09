local SKIN = {}
SKIN.Name = "PS2FlatUI"

local function loadSkin( )

SKIN.Colours = table.Copy( derma.GetDefaultSkin( ).Colours )

SKIN.HeaderBG   = Color( 23, 23, 23 )
SKIN.MainBG     = Color( 102, 102, 102 )
SKIN.InnerPanel = Color( 49, 49, 49 )
SKIN.ButtonColor = Color( 65, 65, 65 )
SKIN.BrightPanel = Color( 102, 102, 102 )
SKIN.Highlight	= Color( 255, 198, 0 )
SKIN.NormalBtn  = color_white
SKIN.IconBackground = Color( 102, 102, 102 )

SKIN.Colours.Label = {}
SKIN.Colours.Label.Default = Color( 180, 180, 180 )
SKIN.Colours.Label.Bright = color_white
SKIN.Colours.Label.Highlight = SKIN.Highlight

SKIN.Colours.Button = {}
SKIN.Colours.Button.Normal		= color_white
SKIN.Colours.Button.Hover		= color_black
SKIN.Colours.Button.Down		= color_black
SKIN.Colours.Button.Disabled	= Color( 180, 180, 180 )


SKIN.Colours.Tree.Normal		= color_white
SKIN.Colours.Tree.Hover		= SKIN.Highlight
SKIN.Colours.Tree.Selected	= SKIN.Highlight

SKIN.Colours.Tab = {}
SKIN.Colours.Tab.Normal		= SKIN.Colours.Label.Default
SKIN.Colours.Tab.Hover		= SKIN.Highlight
SKIN.Colours.Tab.Down		= SKIN.Highlight
SKIN.Colours.Tab.Disabled	= Color( 180, 180, 180 )

SKIN.Colours.Tab.Active 	= {
	Normal		= color_white,
	Hover		= SKIN.Highlight,
	Down		= SKIN.Highlight,
	Disabled	= Color( 180, 180, 180 ),
}
SKIN.Colours.Tab.Inactive = SKIN.Colours.Tab


surface.CreateFont( "PS2_LargeHeading", {
	font = "Segoe UI 8",
	size = 48,
} )

surface.CreateFont( "PS2_MediumLarge", {
	font = "Segoe UI 8",
	size = 32,
} )

surface.CreateFont( "PS2_SmallHeading", {
	font = "Segoe UI 8",
	size = 26,
} )

surface.CreateFont( "PS2_Normal", {
	font = "Segoe UI Semilight 8",
	size = 22,
} )

surface.CreateFont( "PS2_Text", {
	font = "Segoe UI Semilight 8",
	size = 16,
} )

SKIN.fontName = "PS2_Normal"
SKIN.BigTitleFont = "PS2_LargeHeading"
SKIN.SmallTitleFont = "PS2_SmallHeading"
SKIN.TabFont = "PS2_MediumLarge"
SKIN.ButtonFont = "PS2_MediumLarge"
SKIN.TextFont = "PS2_Text"

function SKIN:LayoutCategoryPanelLevel0( panel )
	panel.title:SetVisible( false )
end

function SKIN:LayoutCategoryPanelLevel1( panel )
	panel.title:SetFont( self.TabFont )
	panel.title:SizeToContents( )
	panel.title:SetColor( color_white )
end
function SKIN:PaintCategoryPanelLevel1( panel, w, h )
end

function SKIN:LayoutCategoryPanelLevel2( panel )
	panel.title:SetFont( self.SmallTitleFont )
	panel.title:SizeToContents( )
	panel.title:DockMargin( 8, 5, 0, -5 )
end
function SKIN:PaintCategoryPanelLevel2( panel, w, h )
	surface.SetDrawColor( self.ButtonColor )
	surface.DrawRect( 0, 0, w, h )
end

function SKIN:LayoutCategoryPanelLevel3( panel )
	panel.title:SetFont( self.fontName )
	panel.title:SetColor( self.Highlight )
end
function SKIN:PaintCategoryPanelLevel3( panel, w, h )
end

function SKIN:LayoutPointshopFrame( panel )
	function panel.contentsPanel:PerformLayout( )
		local ActiveTab = self:GetActiveTab()
		local Padding = self:GetPadding()
		if not ActiveTab then 
			return 
		end
		
		ActiveTab:InvalidateLayout( true )
		local ActivePanel = ActiveTab:GetPanel()
		
		for k, v in pairs( self.Items ) do
			if v.Tab:GetPanel( ) == ActivePanel then
				v.Tab:GetPanel( ):SetVisible( true )
				v.Tab:SetZPos( 100 )
			else
				v.Tab:GetPanel( ):SetVisible( false )	
				v.Tab:SetZPos( 1 )
			end

			v.Tab:ApplySchemeSettings( )
		end

		ActivePanel:InvalidateLayout( )
		ActivePanel:SetTall( self:GetTall( ) )
		

		-- Give the animation a chance
		self.animFade:Run( )
	end
	function panel.contentsPanel:Paint( w, h )
	end
end

function SKIN:LayoutPointshopMenuButton( panel )
	panel:SetContentAlignment( 4 )
end

function SKIN:PaintInventoryTab( panel, w, h )
	panel:SetContentAlignment( 2 )
	self:PaintTab( panel, w, h )
end

function SKIN:PaintItemsContainer( panel, w, h )
	self:PaintInnerPanel( panel, w, h )
end

function SKIN:PaintPointshopMenuButton( panel, w, h )
	surface.SetDrawColor( self.ButtonColor )
	surface.DrawRect( 0, 0, w, h )
end

function SKIN:PaintInnerPanel( panel, w, h )
	surface.SetDrawColor( self.InnerPanel )
	surface.DrawRect( 0, 0, w, h )
end

function SKIN:PaintInnerPanelBright( panel, w, h )
	surface.SetDrawColor( self.BrightPanel )
	surface.DrawRect( 0, 0, w, h )
end

function SKIN:PaintPointshopFrame( panel, w, h )
	surface.SetDrawColor( self.MainBG )
	surface.DrawRect( 0, 0, w, h )
end

function SKIN:PaintTopBar( panel, w, h )
	surface.SetDrawColor( self.HeaderBG )
	surface.DrawRect( 0, 0, w, h )
end

function SKIN:PaintPointshopItemIcon( panel, w, h )
	if panel.Selected or panel.Hovered or panel:IsChildHovered( 2 ) then
		draw.RoundedBox( 6, 0, 0, w, h, self.Highlight )
		draw.RoundedBox( 6, 2, 2, w - 4, h - 4, Color( 47, 47, 47 ) )
	else
		draw.RoundedBox( 6, 0, 0, w, h, Color( 47, 47, 47 ) )
	end
end

function SKIN:PaintButton( panel, w, h )
	if panel.Hovered then
		surface.SetDrawColor( self.Highlight )
	else
		surface.SetDrawColor( self.ButtonColor )
	end
	surface.DrawRect( 0, 0, w, h )
end

function SKIN:PaintCreateItemButton( panel, w, h )
	if panel.Hovered then
		surface.SetDrawColor( self.Highlight )
	else
		surface.SetDrawColor( self.ButtonColor )
	end
	surface.DrawRect( 0, 0, w, h )
end

local function compareColors( c1, c2 )
	return c1.r == c2.r and c2.g == c1.g and c1.b == c2.b and c1.a == c2.a 
end

function SKIN:PaintSelection( panel, w, h )
	surface.SetDrawColor( self.Highlight )
	--surface.DrawOutlinedRect( 0, 0, w, h )
end

function SKIN:PaintMenuOption( panel, w, h )
	surface.SetDrawColor( self.ButtonColor )
	surface.DrawRect( 0, 0, w, h )
	panel.m_Image:SetImageColor( color_white )
	panel:SetTextColor( self.Colours.Label.Default )
	if panel.Hovered or panel.Highlight then
		surface.SetDrawColor( self.Highlight )
		surface.DrawOutlinedRect( 0, 0, w, h )
		panel.m_Image:SetImageColor( self.Highlight )
		panel:SetTextColor( self.Highlight )
	end
end

function SKIN:LayoutPropertySheetSheet( panel, sheet )
	function sheet.Tab:ApplySchemeSettings( )
		local active = self:GetPropertySheet( ):GetActiveTab( ) == self
		local w, h = self:GetContentSize()
		self:SetTextInset( 10, -0 )
		self:SetSize( w + 10, self:GetParent( ):GetTall( ) )
		
		self:SetFont( SKIN.TabFont )
		self:SetContentAlignment( 5 )
		
		DLabel.ApplySchemeSettings( self )
	end
	sheet.Panel:Dock( FILL )
end

function SKIN:PaintTab( panel, w, h )
	if panel:IsActive( ) or panel.Hovered then
		surface.SetDrawColor( self.Highlight )
		surface.DrawRect( 0, 0, w, 5 )
	end
end

function SKIN:PaintTree( panel, w, h )
	surface.SetDrawColor( self.ButtonColor )
	surface.DrawRect( 0, 0, w, h )
end

function SKIN:PaintFrame( panel, w, h ) 
	if not panel.startTime then
		panel.startTime = SysTime( )
	
	
		panel.btnMaxim:SetVisible( false )
		panel.btnMinim:SetVisible( false )
		
		panel.lblTitle:SetFont( "PS2_Normal" )
	end
	
	Derma_DrawBackgroundBlur( panel, panel.startTime )
	draw.RoundedBox( 6, 0, 0, w, h, self.MainBG )
	draw.RoundedBoxEx( 6, 0, 0, w, 27, self.HeaderBG, true, true )
end

derma.DefineSkin( SKIN.Name, "Poinsthop2 Default", SKIN )

end --function loadSkin

hook.Add( "Initialize", SKIN.Name .. "init", loadSkin, 100 )
hook.Add( "OnReloaded", SKIN.Name .. "reload", loadSkin, 100 )
if GAMEMODE then
	loadSkin( )
end