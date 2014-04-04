local SKIN = {}
SKIN.Name = "PS2FlatUI"

local function loadSkin( )

SKIN.Colours = table.Copy( derma.GetDefaultSkin( ).Colours )

SKIN.HeaderBG   = Color( 23, 23, 23 )
SKIN.MainBG     = Color( 102, 102, 102 )
SKIN.InnerPanel = Color( 49, 49, 49 )
SKIN.ButtonColor = Color( 65, 65, 65 )
SKIN.Highlight	= Color( 255, 198, 0 )
SKIN.NormalBtn  = color_white
SKIN.IconBackground = Color( 102, 102, 102 )

SKIN.Colours.Label = {}
SKIN.Colours.Label.Default = Color( 180, 180, 180 )
SKIN.Colours.Label.Bright = color_white
SKIN.Colours.Label.Highlight = SKIN.Highlight

SKIN.Colours.Button = {}
SKIN.Colours.Button.Normal		= color_white
SKIN.Colours.Button.Hover		= SKIN.Highlight
SKIN.Colours.Button.Down		= SKIN.Highlight
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

surface.CreateFont( "PS2_Normal", {
	font = "Segoe UI Semilight 8",
	size = 22,
} )

SKIN.fontName = "PS2_Normal"
SKIN.BigTitleFont = "PS2_LargeHeading"
SKIN.MapPanelLabelFont = "LibKHeading"
SKIN.TabFont = "PS2_MediumLarge"
SKIN.ButtonFont = "PS2_MediumLarge"
SKIN.NumRatingsFont = "DermaDefault"

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

function SKIN:PaintPointshopMenuButton( panel, w, h )
	surface.SetDrawColor( self.ButtonColor )
	surface.DrawRect( 0, 0, w, h )
end

function SKIN:PaintInnerPanel( panel, w, h )
	surface.SetDrawColor( self.InnerPanel )
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

function SKIN:PaintPointshopContentIcon( panel, w, h )
	surface.SetDrawColor( self.IconBackground ) 
	surface.DrawRect( 0, 0, w, h )
end

derma.DefineSkin( SKIN.Name, "Fullscreen customized KMapVote Skin", SKIN )

end --function loadSkin

hook.Add( "Initialize", SKIN.Name .. "init", loadSkin, 100 )
hook.Add( "OnReloaded", SKIN.Name .. "reload", loadSkin, 100 )
if GAMEMODE then
	loadSkin( )
end