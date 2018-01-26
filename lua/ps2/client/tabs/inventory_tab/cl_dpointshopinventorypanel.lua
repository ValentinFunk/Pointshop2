local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )

	self.leftPanel = vgui.Create( "DPanel", self )
	self.leftPanel:Dock( LEFT )
	Derma_Hook( self.leftPanel, "Paint", "Paint", "InventoryBackground" )

	local slotsPerRow = 4
	if ScrW() > 870 then
		slotsPerRow = 5
	end
	if ScrW() > 1000 then
		slotsPerRow = 6
	end
	if ScrW() > 1265 then
		slotsPerRow = 8
	end
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
	hook.Add( "PS2_InvUpdate", self, function( self )
		self.invPanel:setItems( LocalPlayer( ).PS2_Inventory:getItems( ) )
		self.invPanel:initSlots( LocalPlayer( ).PS2_Inventory:getNumSlots( ) )
	end )
	hook.Add( "PS2_ItemRemoved", self, function( self, item )
		self.invPanel:itemRemoved( item.id )
		hook.Run("PS2_InvUpdate")
	end )
	hook.Add( "KInv_ItemAdded", self, function( self, inventory, item )
		if item.inventory_id == LocalPlayer( ).PS2_Inventory.id then
			self.invPanel:itemAdded( item )

			timer.Simple( 0, function( )
				if item.icon and IsValid( item.icon ) then
					item.icon:Select( )
				end
			end )
		end
		timer.Simple(0.1, function()
		--	hook.Run("PS2_InvUpdate")
		end)
	end )
	hook.Add( "KInv_ItemRemoved", self, function( self, inventory, itemId )
		if inventory.id != LocalPlayer( ).PS2_Inventory.id then
			return
		end
		if self.descPanel.item and self.descPanel.item.id == itemId then
			self.descPanel:SelectionReset( )
		end
		self.invPanel:itemRemoved( itemId )
	end )


	self.bottomPnl = vgui.Create( "DPanel", self.leftPanel )
	self.bottomPnl:Dock( BOTTOM )
	self.bottomPnl:SetTall( 50 )
	self.bottomPnl:DockMargin( 0, 8, 0, 0 )
	self.bottomPnl:DockPadding( 5, 5, 5, 5 )
	Derma_Hook( self.bottomPnl, "Paint", "Paint", "InnerPanel" )

	self.sendPointsBtn = vgui.Create( "DButton", self.bottomPnl )
	self.sendPointsBtn:Dock( FILL )
	self.sendPointsBtn:SetText( "Send Points" )
	self.sendPointsBtn:SetImage( "pointshop2/transfer.png")
	self.sendPointsBtn.m_Image:SetSize( 22, 22 )
	function self.sendPointsBtn:DoClick( )
		local giveFrame = vgui.Create( "DPointshopGivePointsFrame" )
		giveFrame:MakePopup( )
		giveFrame:DoModal( )
		giveFrame:SetSkin( Pointshop2.Config.DermaSkin )
		giveFrame:Center( )
	end

	local function sendButtonCheck( )
		if Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.SendPointsEnabled" ) == false then
			self.sendPointsBtn:SetDisabled( true )
			self.sendPointsBtn:SetTooltip( "The administrator of this server has diabled this functionality" )
		end
	end
	hook.Add( "PS2_OnSettingsUpdate", self, function( self )
		sendButtonCheck( )
	end )
	sendButtonCheck( )

	/*
		RIGHT BAR: Preview, Equip Slots, Item Description
	*/

	self.rightPanel = vgui.Create( "DPanel", self )
	self.rightPanel:Dock( FILL )
	self.rightPanel:DockMargin( 0, 8, 8, 8 )
	self.rightPanel:DockPadding( 0, 8, 8, 8 )
	Derma_Hook( self.rightPanel, "Paint", "Paint", "InnerPanel" )

	self.topContainer = vgui.Create( "DPanel", self.rightPanel )
	self.topContainer:Dock( TOP )
	self.topContainer:SetTall( 360 )
	self.topContainer.Paint = function( ) end

	self.slotsScroll = vgui.Create( "DScrollPanel", self.topContainer )

	local widthGeneral = 3 * 64 + 3 * 8
	self.slotsScroll.wantedWidth = widthGeneral
	self.slotsScroll:SetWide( self.slotsScroll.wantedWidth )
	self.slotsScroll:DockMargin( 8, 0, 8, 0 )
	self.slotsScroll:Dock( LEFT )
	Derma_Hook( self.slotsScroll, "Paint", "Paint", "InnerPanelBright" )
	self.rightPanel.slotsScroll = self.slotsScroll

	self.slotsLayout = vgui.Create( "DIconLayout", self.slotsScroll )
	self.slotsLayout:Dock( FILL )
	self.slotsLayout:DockMargin( 7, 7, 7, 5 )
	self.slotsLayout:SetSpaceX( 5 )
	self.slotsLayout:SetSpaceY( 5 )
	hook.Run( "PS2_PopulateSlots", self.slotsLayout )
	hook.Add( "PS2_OnSettingsUpdate", self, function()
		for k, v in pairs(self.slotsLayout:GetChildren()) do
			v:Remove()
		end
		hook.Run( "PS2_PopulateSlots", self.slotsLayout )
	end )

	self.preview = vgui.Create( "DPointshopInventoryPreviewPanel", self.topContainer )
	self.preview:DockMargin( 0, 0, 8, 0 )
	self.preview:Dock( FILL )
	self.preview:SetFOV( 45 )
	self.preview:SetAnimated( true )
	Pointshop2.InventoryPreviewPanel = self.preview

	--	Bottom desc panel
	self.itemDescPanel = vgui.Create( "DScrollPanel", self.rightPanel )
	self.itemDescPanel:Dock( FILL )
	self.itemDescPanel:DockMargin( 0, 8, 0, 0 )
	self.itemDescPanel.Paint = function( ) end

	self.descPanel = vgui.Create( "DPointshopItemDescription", self.itemDescPanel )
	self.descPanel:Dock( TOP )
	hook.Add( "PS2_InvItemIconSelected", self, function( self, panel, item )
		if not IsValid( panel ) or not item then
			self.descPanel:SelectionReset( )
			return
		end
		if self.descPanel.ClassName != item.class:GetPointshopDescriptionControl( ) then
			self.descPanel:Remove( )
			self.descPanel = vgui.Create( item.class:GetPointshopDescriptionControl( ), self.itemDescPanel )
			self.descPanel:Dock( TOP )
		end
		self.descPanel:SetItem( item, false )
	end )
	hook.Add( "PS2_SlotChanged", self, function( self, slot )
		if not slot.Item then
			self.descPanel:SelectionReset( )
		end
	end )
end

function PANEL:PerformLayout( )
	if self.slotsScroll.VBar.Enabled then
		self.slotsScroll:SetWide( self.slotsScroll.wantedWidth + self.slotsScroll.VBar:GetWide( ) )
	end
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopInventoryPanel" )
derma.DefineControl( "DPointshopInventoryPanel", "", PANEL, "DPanel" )

Pointshop2:AddInventoryPanel( "Items", "pointshop2/briefcase3.png", "DPointshopInventoryPanel" )
