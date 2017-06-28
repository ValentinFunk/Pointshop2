local SKIN = {}
SKIN.Name = "KInventoryBasic"

local function loadSkin( )


SKIN.HighlightColor = Color( 200, 0, 0 )
SKIN.BaseColor = Color( 50, 50, 50 )

surface.CreateFont( "KInventoryDefaultFont", {
 font = "Arial",
 size = 74,
 weight = 9,
 blursize = 0,
 scanlines = 0,
 antialias = true,
 underline = false,
 italic = false,
 strikeout = false,
 symbol = false,
 rotary = false,
 shadow = false,
 additive = false,
 outline = false
} )

SKIN.MainFont = "KInventoryDefaultFont"

SKIN.Colours = table.Copy( derma.GetDefaultSkin( ).Colours )
SKIN.Colours.Label = {}
SKIN.Colours.Label.Default = color_white
SKIN.Colours.Label.Bright = SKIN.ItemDescPanelBorder

local id = "PropertySheetTab" .. os.time( )
function SKIN:PaintInventoryTab( panel, w, h )
	local color_bright, color_darken = self.HighlightColor, self.BaseColor
	
	if panel.Hovered or panel.m_bSelected or panel:GetPropertySheet():GetActiveTab() == panel then
		draw.GradientBox( id .. "selected", 0, 0, w, 28, color_bright, Color( color_bright.r - 30, color_bright.g, color_bright.b ) ) 
	else
		panel:SetColor( color_white )
		draw.GradientBox( id, 0, 0, w, 28, color_darken, Color( color_darken.r - 30, color_darken.g - 30, color_darken.b - 30 ) ) 
	end
end

function SKIN:PaintOverItemIcon( panel, w, h )
	local color_bright, color_darken = self.HighlightColor, self.BaseColor

	if panel.Dragging then
		surface.SetDrawColor( color_bright.r / 2, color_bright.g, color_bright.b / 2, 100 )
		surface.DrawRect( 0, 0, w, h )
	end
end

local wpgradid = "GradWeight" .. os.time( )
function SKIN:PaintWeightPanel( panel, w, h )
	local color_bright, color_darken = self.HighlightColor, self.BaseColor

	surface.SetDrawColor( color_darken )
	surface.DrawRect( 0, 0, w, h )
	
	local inventory = panel:GetParent( ).inventory
	
	if inventory then
		local perc = inventory:getWeight( ) / inventory.maxWeight
		local boxW = perc * w - 2
		draw.GradientBox( wpgradid, 1, 1, boxW, h - 2, Color( 210, 0, 10 ), Color( 180, 0, 10 ) )
	end
end

function SKIN:LayoutInventoryFrame( panel )
end

function SKIN:LayoutItemDescriptionPanel( panel )
	local color_bright, color_darken = self.HighlightColor, self.BaseColor
	panel.titleLabel:SetColor( color_bright )
end

function SKIN:PaintItemDescriptionPanel( panel, w, h )
	local color_bright, color_darken = self.HighlightColor, self.BaseColor
	
	w, h = w - 1, h - 1
	--Fill
	surface.SetDrawColor( color_darken.r, color_darken.g, color_darken.b, 200 )
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

derma.DefineSkin( SKIN.Name, "KInventory default skin", SKIN )

end --function loadSkin

hook.Add( "Initialize", SKIN.Name .. "init", loadSkin, 100 )
hook.Add( "OnReloaded", SKIN.Name .. "reload", loadSkin, 100 )