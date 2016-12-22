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

/*

local hoverPanel, lastHoverItem
hook.Add( "DrawOverlay", "KInvItemInfoPaint", function( )
	if ( dragndrop.m_Dragging != nil ) then return end

	local hoverItem = vgui.GetHoveredPanel( )
	if not IsValid( hoverItem ) then
		if IsValid( hoverPanel ) then
			hoverPanel:Remove( )
		end
		return
	end

	if hoverItem != lastHoverItem then
		if IsValid( hoverPanel ) then
			hoverPanel:Remove( )
		end
	end
	lastHoverItem = hoverItem

	if hoverItem.stackPanel then
		local stackPanel = hoverItem.stackPanel
		if not IsValid( hoverPanel ) then
			hoverPanel = stackPanel.items[1]:getHoverPanel( )
			hoverPanel:SetPaintedManually( true )
			hoverPanel:SetTargetPanel( stackPanel )
			hoverPanel:SetItem( stackPanel.items[1] )
		end

		DisableClipping( true )
		local itemBottomCenterX, itemBottomCenterY = stackPanel:LocalToScreen( stackPanel:GetWide( ) / 2, stackPanel:GetTall( ) )
		local paintPosX, paintPosY = itemBottomCenterX - hoverPanel:GetWide( ) / 2, itemBottomCenterY

		paintPosX = math.Clamp( paintPosX, 0, ScrW( ) )
		if paintPosX + hoverPanel:GetWide( ) > ScrW( ) then
			paintPosX = ScrW( ) - hoverPanel:GetWide( )
		end

		if paintPosY + hoverPanel:GetTall( ) > ScrH( ) then
			paintPosY = ScrH( ) - hoverPanel:GetTall( )
			hoverPanel:SetTargetPanel( nil )
		else
			hoverPanel:SetTargetPanel( stackPanel )
		end

		hoverPanel:SetPaintedManually( false )
		hoverPanel:PaintAt( paintPosX, paintPosY )
		hoverPanel:SetPaintedManually( true )
		DisableClipping( false )
	end
end ) */
