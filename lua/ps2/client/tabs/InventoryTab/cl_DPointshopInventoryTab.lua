local PANEL = {}

function PANEL:Init( )
	self.invPage = vgui.Create( "DPanel", self )
	self.invPage.Paint = function( ) end
	
	local container = vgui.Create( "DPanel", self.invPage )
	container:Dock( LEFT )
	local slotsPerRow = 5
	local containerWidth = 64 * slotsPerRow + ( slotsPerRow - 1 ) * 5 + 2 * 8
	container:SetWide( containerWidth  )
	container:DockPadding( 8, 8, 8, 8 )
	function container:PerformLayout( )
		if self.invScroll.VBar.Enabled then
			self:SetWide( containerWidth + 16 + 8 )
		else
			self:SetWide( containerWidth )
		end
	end
	
	local invScroll = vgui.Create( "DScrollPanel", container )
	invScroll:Dock( FILL )
	container.invScroll = invScroll
	
	self.invPanel = vgui.Create( "DItemsContainer", invScroll )
	self.invPanel:Dock( FILL )
	self.invPanel:setCategoryName( "Pointshop2_Global" )
	self.invPanel:setItems( LocalPlayer( ).PS2_Inventory:getItems( ) )
	self.invPanel:initSlots( LocalPlayer( ).PS2_Inventory:getNumSlots( ) )
	function self.invPanel:Paint( ) 
	end
	
	self.bottomPnl = vgui.Create( "DPanel", container )
	self.bottomPnl:Dock( BOTTOM )
	self.bottomPnl:SetTall( 50 )
	self.bottomPnl:DockMargin( 0, 8, 0, 0 )
	Derma_Hook( self.bottomPnl, "Paint", "Paint", "InnerPanel" )
	
	self:addMenuEntry( "Items", "pointshop2/briefcase3.png", self.invPage )
	
	local tradePanel = vgui.Create( "DPanel" )
	self:addMenuEntry( "Trade", "pointshop2/transfer.png", tradePanel )
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopInventoryTab" )
derma.DefineControl( "DPointshopInventoryTab", "", PANEL, "DPointshopMenuedTab" )

Pointshop2:AddTab( "Inventory", "DPointshopInventoryTab" )