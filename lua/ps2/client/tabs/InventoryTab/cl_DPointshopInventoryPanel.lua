local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self.leftPanel = vgui.Create( "DPanel", self )
	self.leftPanel:Dock( LEFT )
	Derma_Hook( self.leftPanel, "Paint", "Paint", "InventoryBackground" )
	
	local slotsPerRow = 5
	local containerWidth = 64 * slotsPerRow + ( slotsPerRow - 1 ) * 5 + 2 * 8
	self.leftPanel:SetWide( containerWidth  )
	self.leftPanel:DockPadding( 8, 8, 8, 8 )
	function self.leftPanel:PerformLayout( )
		if self.invScroll.VBar.Enabled then
			self:SetWide( containerWidth + 16 + 8 )
		else
			self:SetWide( containerWidth )
		end
	end
	
	local invScroll = vgui.Create( "DScrollPanel", self.leftPanel )
	invScroll:Dock( FILL )
	self.leftPanel.invScroll = invScroll
	
	self.invPanel = vgui.Create( "DItemsContainer", invScroll )
	self.invPanel:Dock( FILL )
	self.invPanel:setCategoryName( "Pointshop2_Global" )
	self.invPanel:setItems( LocalPlayer( ).PS2_Inventory:getItems( ) )
	self.invPanel:initSlots( LocalPlayer( ).PS2_Inventory:getNumSlots( ) )
	function self.invPanel:Paint( ) 
	end
	
	self.bottomPnl = vgui.Create( "DPanel", self.leftPanel )
	self.bottomPnl:Dock( BOTTOM )
	self.bottomPnl:SetTall( 50 )
	self.bottomPnl:DockMargin( 0, 8, 0, 0 )
	Derma_Hook( self.bottomPnl, "Paint", "Paint", "InnerPanel" )
	
	/*
		RIGHT BAR: Preview, Equip Slots, Item Description
	*/
	
	self.rightPanel = vgui.Create( "DPanel", self )
	self.rightPanel:Dock( FILL )
	self.rightPanel:DockMargin( 0, 8, 8, 8 )
	self.rightPanel:DockPadding( 8, 8, 8, 8 )
	Derma_Hook( self.rightPanel, "Paint", "Paint", "InnerPanel" )

	self.topContainer = vgui.Create( "DPanel", self.rightPanel )
	self.topContainer:Dock( TOP )
	self.topContainer:SetTall( 400 )
	
	self.slotsScroll = vgui.Create( "DScrollPanel", self.topContainer )
	self.slotsScroll.wantedWidth = 2 * 64 + 2 * 8
	self.slotsScroll:SetWide( self.slotsScroll.wantedWidth )
	self.slotsScroll:DockMargin( 8, 0, 8, 0 )
	self.slotsScroll:Dock( LEFT )
	self.rightPanel.slotsScroll = self.slotsScroll
	
	self.slotsLayout = vgui.Create( "DIconLayout", self.slotsScroll )
	self.slotsLayout:Dock( FILL )
	hook.Run( "PS2_PopulateSlots", self.slotsLayout )
	
	self.preview = vgui.Create( "DPointshopInventoryPreviewPanel", self.topContainer )
	self.preview:DockMargin( 0, 0, 8, 0 )
	self.preview:Dock( FILL )
	self.preview:SetModel( LocalPlayer( ):GetModel( ) )
	self.preview:SetFOV( 45 ) 
	self.preview:SetAnimated( true )
	Pointshop2.InventoryPreviewPanel = self.preview
	
	--	Bottom desc panel
	self.itemDescPanel = vgui.Create( "DPanel", self.rightPanel )
	self.itemDescPanel:Dock( FILL )
	self.itemDescPanel:DockMargin( 0, 8, 0, 0 )
	self.itemDescPanel.Paint = function( ) end
	
	self.descPanel = vgui.Create( "DPointshopItemDescription", self.rightPanel )
	self.descPanel:Dock( TOP )
	hook.Add( "PS2_ItemIconSelected", self, function( self, panel, itemClass )
		if not IsValid( panel ) or not itemClass then
			self.descPanel:SelectionReset( )
			return
		end
		if self.descPanel.ClassName != itemClass.GetPointshopDescriptionControl( ) then
			self.descPanel:Remove( )
			self.descPanel = vgui.Create( itemClass.GetPointshopDescriptionControl( ), self.rightPanel )
			self.descPanel:Dock( TOP )
		end
		self.descPanel:SetItemClass( itemClass, true )
	end )
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopInventoryPanel" )
derma.DefineControl( "DPointshopInventoryPanel", "", PANEL, "DPanel" )