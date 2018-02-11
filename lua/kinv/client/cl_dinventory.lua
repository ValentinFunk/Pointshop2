local PANEL = {}
function PANEL:Init( )
	self.categories = vgui.Create( "DInventoryPropertySheet", self )
	self.categories:Dock( FILL )
	self.categories:DockMargin( 0, 5, 0, 0 )
	self.categoryLookup = {}

	self.weightPanel = vgui.Create( "DPanel", self )
	self.weightPanel:DockMargin( 5, 5, 5, 5 )
	self.weightPanel:Dock( BOTTOM )

	Derma_Hook( self.weightPanel, "Paint", "Paint", "WeightPanel" )

	local weightText = vgui.Create( "DLabel", self.weightPanel )
	weightText:Dock( FILL )
	weightText:SetContentAlignment( 5 )
	function weightText.Think( )
		if self.inventory then
			weightText:SetText( Format( "Weight: %i / %i", self.inventory:getWeight( ), self.inventory.maxWeight ) )
			if self.inventory:getWeight( ) == self.inventory.maxWeight then
				weightText:SetColor( Color( 255, 150, 150, 255 ) )
			else
				weightText:SetColor( color_white )
			end
		end
	end

	derma.SkinHook( "Layout", "InventoryFrame", self )
end


function PANEL:setInventory( inventory )
	self.inventory = inventory

	self.categorizedItems = {}
	self.categorizedItems["All"] = inventory.Items

	local categories = {}
	for k, v in pairs( self.inventory.Items ) do
		if v.category then
			self.categorizedItems[v.category] = self.categorizedItems[v.category] or {}
			table.insert( self.categorizedItems[v.category], v )
		end
	end
	for category, items in pairs( self.categorizedItems ) do
		local panel = vgui.Create( "DItemsContainer" )
		panel:setCategoryName( category )
		self.categoryLookup[category] = panel
		self.categories:AddSheet( category, panel, "", false, false, category )
		panel:setItems( items )
		self.categories:SwitchToName( category )
	end
	self.categories:SwitchToName( "All" )
end

function PANEL:itemRemoved( itemId )
	for catName, itemsTable in pairs( self.categorizedItems ) do
		self.categoryLookup[catName]:itemRemoved( itemId )
	end
end

function PANEL:Paint( )
end


vgui.Register( "DInventory", PANEL, "DPanel" )

local isEnabled = false
hook.Add( "PS2_ClientSettingsUpdated", "UpdateHoverPanel", function( )
	isEnabled = Pointshop2.ClientSettings.GetSetting( "BasicSettings.HoverPanelEnabled" )
end )

local hoverPanel, lastHoveredPanel, hoverStart

hook.Add( "DrawOverlay", "KInvItemInfoPaint", function( )
	if ( dragndrop.m_Dragging != nil ) then return end
	
	local hoveredPanel = vgui.GetHoveredPanel( )
	local forceHover = IsValid(hoveredPanel) and hoveredPanel.alwaysShowHoverPanel
	if not isEnabled and not forceHover then
		return
	end

	if not IsValid( hoveredPanel ) then
		hoverStart = RealTime()
		if IsValid( hoverPanel ) then
			-- hoverPanel:Remove( )
		end
		return
	end

	if hoveredPanel != lastHoveredPanel then
		hoverStart = RealTime()
		if IsValid( hoverPanel ) and hoveredPanel and hoveredPanel.isInventoryIcon then
			hoverPanel:SetItem( hoveredPanel.item )
			-- hoverPanel:Remove( )
		end
	end
	lastHoveredPanel = hoveredPanel
	/*if RealTime() < hoverStart + 0.05 then
		return
	end*/

	if hoveredPanel.isInventoryIcon then
		if not IsValid( hoverPanel ) then
			hoverPanel = vgui.Create("DItemDescriptionPanel")
			hoverPanel:SetSize(300, 300)
			hoverPanel:SetPaintedManually( true )
			hoverPanel:SetTargetPanel( hoveredPanel )
			hoverPanel:SetItem( hoveredPanel.item )
		end

		DisableClipping( true )
		local itemBottomCenterX, itemBottomCenterY = hoveredPanel:LocalToScreen( hoveredPanel:GetWide( ) / 2, hoveredPanel:GetTall( ) )
		local paintPosX, paintPosY = itemBottomCenterX - hoverPanel:GetWide( ) / 2, itemBottomCenterY

		paintPosX = math.Clamp( paintPosX, 0, ScrW( ) )
		if paintPosX + hoverPanel:GetWide( ) > ScrW( ) then
			paintPosX = ScrW( ) - hoverPanel:GetWide( )
		end

		if paintPosY + hoverPanel:GetTall( ) > ScrH( ) then
			paintPosY = ScrH( ) - hoverPanel:GetTall( )
			hoverPanel:SetTargetPanel( nil )
		else
			hoverPanel:SetTargetPanel( hoveredPanel )
		end

		hoverPanel:SetPaintedManually( false )
		hoverPanel:PaintAt( paintPosX, paintPosY )
		hoverPanel:SetPaintedManually( true )
		DisableClipping( false )
	end
end )
