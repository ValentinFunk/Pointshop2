local SKIN = {}
SKIN.Name = "PS2FlatUI"

local function loadSkin( )

SKIN.Colours = table.Copy( derma.GetDefaultSkin( ).Colours )

SKIN.tex = table.Copy( derma.GetDefaultSkin( ).tex )

SKIN.tex.RadioButton_Checked = GWEN.CreateTextureNormal( 448, 64, 15, 15 )
SKIN.tex.RadioButton = GWEN.CreateTextureNormal( 464, 64, 15, 15 )

SKIN.tex.RadioButtonD_Checked = GWEN.CreateTextureNormal( 448, 80, 15, 15 )
SKIN.tex.RadioButtonD = GWEN.CreateTextureNormal( 464, 80, 15, 15 )

SKIN.HeaderBG   = Color( 23, 23, 23 )
SKIN.MainBG     = Color( 102, 102, 102 )
SKIN.InnerPanel = Color( 49, 49, 49 )
SKIN.Footer = Color( 59, 59, 59 )
SKIN.ButtonColor = Color( 65, 65, 65 )
SKIN.BrightPanel = Color( 102, 102, 102 )
SKIN.Highlight	= Color( 255, 198, 0 )
SKIN.NormalBtn  = color_white
SKIN.IconBackground = Color( 102, 102, 102 )

SKIN.Colours.Label = {}
SKIN.Colours.Label.Default = Color( 180, 180, 180 )
SKIN.Colours.Label.Dark = Color( 100, 100, 100 )
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

--SKIN.Colours.Category = {}
SKIN.Colours.Category.Header = SKIN.Highlight
SKIN.Colours.Category.Header_Closed = SKIN.Colours.Label.Default
--SKIN.Colours.Category.LineAlt = {}
SKIN.Colours.Category.LineAlt.Text_Selected = SKIN.Highlight
SKIN.Colours.Category.LineAlt.Text_Hover = SKIN.Highlight
--SKIN.Colours.Category.Line = {}
SKIN.Colours.Category.Line.Text = SKIN.Colours.Label.Default
SKIN.Colours.Category.Line.Text_Selected = SKIN.Highlight
SKIN.Colours.Category.Line.Text_Hover = SKIN.Highlight

SKIN.Colours.Tab.Active 	= {
	Normal		= color_white,
	Hover		= SKIN.Highlight,
	Down		= SKIN.Highlight,
	Disabled	= Color( 180, 180, 180 ),
}
SKIN.Colours.Tab.Inactive = SKIN.Colours.Tab


surface.CreateFont( "PS2_LargeHeading", {
	font = "Segoe UI 8",
	size = 46,
} )

surface.CreateFont( "PS2_MediumLarge", {
	font = "Segoe UI 8",
	size = 28,
} )

surface.CreateFont( "PS2_SmallHeading", {
	font = "Segoe UI 8",
	size = 24,
} )

surface.CreateFont( "PS2_Normal", {
	font = "Segoe UI Semilight 8",
	size = 20,
} )

surface.CreateFont( "PS2_Text", {
	font = "Segoe UI Semilight 8",
	size = 14,
} )

SKIN.fontName = "PS2_Normal"
SKIN.BigTitleFont = "PS2_LargeHeading"
SKIN.SmallTitleFont = "PS2_SmallHeading"
SKIN.TabFont = "PS2_MediumLarge"
SKIN.ButtonFont = "PS2_MediumLarge"
SKIN.TextFont = "PS2_Text"

local old = SKIN.PaintComboBox
function SKIN:PaintComboBox( panel, w, h )
	derma.GetDefaultSkin( ).PaintComboBox( self, panel, w, h )
	panel:SetColor( self.Colours.Label.Dark )
end

function SKIN:LayoutCategoryPanelLevel0( panel )
	panel.title:SetVisible( false )
	panel.layout:DockMargin( 8, 8, 8, 8 )
end

function SKIN:LayoutCategoryPanelLevel1( panel )
	panel.title:SetFont( self.BigTitleFont )
	panel.title:SizeToContents( )
	panel.title:SetColor( color_white )
	panel.title:DockMargin( 0, 8, 0, 16 )
end
function SKIN:PaintCategoryPanelLevel1( panel, w, h )
end

function SKIN:LayoutCategoryPanelLevel2( panel )
	panel.title:SetFont( self.fontName )
	panel.title:SetColor( color_white )
	panel.title:SizeToContents( )
	panel.title:DockMargin( 0, 5, 0, 8 )
	panel.layout:DockMargin( 2, 8, 0, 8 )
	panel:DockPadding( 0, 0, 0, 8 )
	panel:DockMargin( 0, 0, 0, 16 )
end
function SKIN:PaintCategoryPanelLevel2( panel, w, h )
	surface.SetDrawColor( self.ButtonColor )
	--surface.DrawRect( 0, 0, w, h )
	panel.title:SetText(string.upper(panel.title:GetText()))
end

function SKIN:LayoutCategoryPanelLevel3( panel )
	panel.title:SetFont( self.fontName )
	panel.title:SizeToContents( )
	panel.title:SetColor( color_white )
	panel.title:DockMargin( 5, 5, 0, 10 )
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

function SKIN:PaintFooter( panel, w, h )
	surface.SetDrawColor( self.Footer )
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
	local isChildHovered = panel.IsHoveredRecursive and panel:IsHoveredRecursive() or panel:IsChildHovered( 2 )
	if not panel.noSelect and ( panel.Selected or panel.Hovered or isChildHovered ) then
		draw.RoundedBox( 6, 0, 0, w, h, self.Highlight )
		draw.RoundedBox( 6, 2, 2, w - 4, h - 4, Color( 47, 47, 47 ) )
	else
		draw.RoundedBox( 6, 0, 0, w, h, Color( 47, 47, 47 ) )
	end
end

function SKIN:PaintButton( panel, w, h )
	surface.SetDrawColor( self.ButtonColor )
	surface.DrawRect( 0, 0, w, h )
	panel:SetTextColor( self.Colours.Label.Default )
	if IsValid( panel.m_Image ) then
		panel.m_Image:SetImageColor( color_white )
	end


	if panel.Hovered or panel.Highlight or panel.Selected then
		surface.SetDrawColor( self.Highlight )
		surface.DrawRect( 0, 0, w, h )
		if IsValid( panel.m_Image ) then
			panel.m_Image:SetImageColor( self.Colours.Label.Dark )
		end
		panel:SetTextStyleColor( Color( 0, 0, 0 ) )
		panel:SetColor( Color( 0, 0, 0 ) )
	end

	if panel:GetDisabled( ) then
		surface.SetDrawColor( Color( self.ButtonColor.r - 20, self.ButtonColor.g - 20, self.ButtonColor.b - 20 ) )
		surface.DrawRect( 0, 0, w, h )
		surface.SetDrawColor( Color( 200, 200, 200 ) )
		--surface.DrawOutlinedRect( 0, 0, w, h )
		if IsValid( panel.m_Image ) then
			panel.m_Image:SetImageColor( Color( 100, 100, 100 ) )
		end
		panel:SetTextColor( self.Colours.Label.Dark )
	end
	panel:ApplySchemeSettings( )
end

function SKIN:PaintBigButton( panel, w, h )
	if panel.Hovered then
		surface.SetDrawColor( self.Highlight )
	else
		surface.SetDrawColor( self.ButtonColor )
	end
	surface.DrawRect( 0, 0, w, h )
end

function SKIN:PaintBigButtonLabel( panel, w, h )
	surface.SetDrawColor( panel:GetSkin( ).ButtonColor )
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
	if panel.m_Image then panel.m_Image:SetImageColor( color_white ) end
	panel:SetTextColor( self.Colours.Label.Default )
	if panel.Hovered or panel.Highlight then
		surface.SetDrawColor( self.Highlight )
		surface.DrawOutlinedRect( 0, 0, w, h )
		if panel.m_Image then
			panel.m_Image:SetImageColor( self.Highlight )
		end
		panel:SetTextColor( self.Highlight )
	end
end

function SKIN:LayoutPropertySheetSheet( panel, sheet )
	function sheet.Tab:ApplySchemeSettings( )
		local active = self:GetPropertySheet( ):GetActiveTab( ) == self
		local w, h = self:GetContentSize()
		self:SetTextInset( 10, -0 )
		self:SetSize( w + 10, self:GetParent( ):GetTall( ) )


		self:SetContentAlignment( 5 )

		DLabel.ApplySchemeSettings( self )
	end
	sheet.Tab:SetFont( SKIN.TabFont )
	sheet.Tab:SetTooltip( false )
	sheet.Panel:Dock( FILL )
end

function SKIN:LayoutInlineSheetSheet( panel, sheet )
	function sheet.Tab:ApplySchemeSettings( )
		local active = self:GetPropertySheet( ):GetActiveTab( ) == self
		local w, h = self:GetContentSize()
		self:SetTextInset( 10, -0 )
		self:SetSize( w + 10, self:GetParent( ):GetTall( ) )


		self:SetContentAlignment( 5 )

		DLabel.ApplySchemeSettings( self )
	end
	sheet.Tab:SetFont( SKIN.fontName )
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

	local c
	for k, v in pairs( panel:GetChildren( ) ) do
		if v:HasFocus( ) then
			c = true
		end
	end
	if panel:HasHierarchicalFocus() then Derma_DrawBackgroundBlur( panel, panel.startTime ) end
	draw.RoundedBox( 0, 0, 0, w, h, self.MainBG )
	draw.RoundedBoxEx( 0, 0, 0, w, 27, self.HeaderBG, true, true )
end

function SKIN:PaintCollapsibleCategory( panel, w, h )
	panel.Header:SetFont( "PS2_Normal" )
	panel.Header:SetTall( 25 )

	surface.SetDrawColor( self.ButtonColor )
	surface.DrawRect( 0, 0, panel.Header:GetWide( ), panel.Header:GetTall( ) )

	surface.SetDrawColor( self.InnerPanel )
	surface.DrawRect( 0, panel.Header:GetTall( ), w, h - panel.Header:GetTall( ) )
end

function SKIN:PaintCategoryList( panel, w, h )
	surface.SetDrawColor( self.InnerPanel )
	surface.DrawRect( 0, 0, w, h )
end

function SKIN:PaintRadioButton( panel, w, h )
	if panel:GetChecked( ) then
		if panel:GetDisabled( ) then
			self.tex.RadioButtonD_Checked( 0, 0, w, h )
		else
			self.tex.RadioButton_Checked( 0, 0, w, h )
		end
	else
		if panel:GetDisabled( ) then
			self.tex.RadioButtonD( 0, 0, w, h )
		else
			self.tex.RadioButton( 0, 0, w, h )
		end
	end
end

function SKIN:PaintScrollBarGrip( panel, w, h )
	if panel.Depressed then
		surface.SetDrawColor( self.Highlight )
	else
		surface.SetDrawColor( self.ButtonColor )
	end
	surface.DrawRect( 0, 0, w, h )
end

function SKIN:PaintVScrollBar( panel, w, h )
	surface.SetDrawColor( self.InnerPanel )
	surface.DrawRect( 0, 0, w, h )
end

function SKIN:PaintButtonDown( panel, w, h )
	self:PaintButton( panel, w, h )
	if not panel.m_Image then
		panel:SetImage( "pointshop2/little9.png" )
		panel.m_Image:SetSize( 8, 8 )
	end
end

function SKIN:PaintButtonUp( panel, w, h )
	self:PaintButton( panel, w, h )
	if not panel.m_Image then
		panel:SetImage( "pointshop2/little16.png" )
		panel.m_Image:SetSize( 8, 8 )
	end
end

function SKIN:PaintItemDescriptionPanel( panel, w, h )
	local color_bright, color_darken = self.ButtonColor, self.InnerPanel
	local function l2s(tbl) 
		local x, y = tbl.x, tbl.y
		return { x = x, y = y }
	end

	--Fill
	surface.SetDrawColor( color_darken.r, color_darken.g, color_darken.b, 250 )
	if panel.targetPanel then
		local targetXScreen, targetYScreen = panel.targetPanel:LocalToScreen( 0, 0 )
		local targetX, targetY = panel:ScreenToLocal( targetXScreen, targetYScreen )
		
		local targetW, targetH = panel.targetPanel:GetSize( )
		local targetCenterX = targetX + targetW / 2
		local fillVertices = {}
		table.insert( fillVertices, { x = targetCenterX + 10, y = 10 } )
		table.insert( fillVertices, { x = targetCenterX, y = 0 } ) --top
		table.insert( fillVertices, { x = targetCenterX - 10, y = 10 } )
		table.insert( fillVertices, { x = targetCenterX + 10, y = 10 } )
		fillVertices = table.reverse( fillVertices )
		
		draw.NoTexture( )
		surface.DrawPoly( fillVertices )
	end
	
	surface.DrawRect( 0, 10, w, h - 10 )
	
	--Outline
	local vertices = {}
	table.insert( vertices, { x = 0, y = 10 } )
	table.insert( vertices, { x = 0, y = h } )
	table.insert( vertices, { x = w, y = h } )
	table.insert( vertices, { x = w, y = 10 } )
	
	if panel.targetPanel then
		local targetXScreen, targetYScreen = panel.targetPanel:LocalToScreen( 0, 0 )
		local targetX, targetY = panel:ScreenToLocal( targetXScreen, targetYScreen )
		local targetW, targetH = panel.targetPanel:GetSize( )
		local targetCenterX = targetX + targetW / 2
		table.insert( vertices, { x = targetCenterX + 10, y = 10 } )
		table.insert( vertices, { x = targetCenterX, y = 0 } ) --top
		table.insert( vertices, { x = targetCenterX - 10, y = 10 } )
	end
	
	
	surface.SetDrawColor( color_bright )
	table.insert( vertices, { x = 0, y = 10 } )
	local lastVert
	for k, vert in pairs( vertices ) do
		if k > 1 then 
			surface.DrawLine( lastVert.x, lastVert.y, vert.x, vert.y ) 
		end
		lastVert = vert
	end
end

function SKIN:LayoutItemDescriptionPanel( panel )

end


derma.DefineSkin( SKIN.Name, "Poinsthop2 Default", SKIN )

KLogf( 4, "Loaded " .. SKIN.Name )

end --function loadSkin

hook.Add( "Initialize", SKIN.Name .. "init", loadSkin, 100 )
hook.Add( "OnReloaded", SKIN.Name .. "reload", loadSkin, 100 )
if GAMEMODE then
	loadSkin( )
end
