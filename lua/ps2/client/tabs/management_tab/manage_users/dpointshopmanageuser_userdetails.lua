local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )

	self:DockPadding( 10, 0, 10, 10 )

	local label = vgui.Create( "DLabel", self )
	label:SetText( "User Details" )
	label:SetColor( color_white )
	label:SetFont( self:GetSkin( ).TabFont )
	label:SizeToContents( )
	label:Dock( TOP )

	self.loadingNotifier = vgui.Create( "DLoadingNotifier", self )
	self.loadingNotifier:Dock( TOP )

	self.detailsPanel = vgui.Create( "DPanel", self )
	self.detailsPanel:Dock( FILL )
	self.detailsPanel:DockPadding( 5, 5, 5, 5 )
	Derma_Hook( self.detailsPanel, "Paint", "Paint", "InnerPanel" )

	/* Player Info */
	self.generalInfo = self:AddCategory( "Player Info" )
	self.generalInfo:SetTall( 64 + 10 )
	
	local splitPanel = vgui.Create( "DSplitPanel", self.generalInfo )
	splitPanel:Dock( FILL )
	
	self.generalInfo.avatar = vgui.Create( "AvatarImage", splitPanel.left )
	self.generalInfo.avatar:SetPos( 5, 5 )
	self.generalInfo.avatar:SetSteamID( "BOT", 64 )
	self.generalInfo.avatar:SetSize( 64, 64 )
	self.generalInfo.avatar:Dock( LEFT )
	self.generalInfo.avatar:DockMargin( 0, 0, 10, 0 )

	self.generalInfo.infoPanel = vgui.Create( "DPanel", splitPanel.left )
	self.generalInfo.infoPanel:Dock( FILL )
	self.generalInfo.infoPanel.Paint = function( ) end
	function self.generalInfo.infoPanel:AddLabel( name )
		local pnl = vgui.Create( "DLabel", self )
		pnl:DockMargin( 0, 0, 0, 5 )
		pnl:Dock( TOP )
		pnl:SetText( name )
		pnl:SetFont( self:GetSkin( ).TextFont )
		pnl:SizeToContents( )

		return pnl
	end

	self.generalInfo.infoPanel.name = self.generalInfo.infoPanel:AddLabel( "Name" )
	self.generalInfo.infoPanel.steamId = self.generalInfo.infoPanel:AddLabel( "Steam-ID" )
	self.generalInfo.infoPanel.lastConnected = self.generalInfo.infoPanel:AddLabel( "Last Connected" )

	/* Wallet */
	self.walletInfo = splitPanel.right

	local frame = self
	function self.walletInfo:AddCurrencyPanel( name, label, value, icon )
		local pnl = vgui.Create( "DPanel", self )
		self[name .. "Panel"] = pnl
		pnl:Dock( TOP )
		pnl:DockPadding( 5, 0, 5, 5 )
		pnl.Paint = function( ) end

		pnl.displayPnl = vgui.Create( "DPanel", pnl )
		pnl.displayPnl:Dock( TOP )
		pnl.displayPnl.Paint = function( ) end

		pnl.icon = vgui.Create( "DImage", pnl.displayPnl )
		pnl.icon:SetMaterial( Material( icon, "noclamp smooth" ) )
		pnl.icon:Dock( LEFT )
		pnl.icon:DockMargin( 0, 2, 5, 2 )
		pnl.icon:SetSize( 20, 20 )

		pnl.label = vgui.Create( "DLabel", pnl.displayPnl )
		pnl.label:SetText( value )
		pnl.label:SetFont( self:GetSkin( ).fontName )
		pnl.label:Dock( FILL )

		pnl.changeButton = vgui.Create( "DButton", pnl.displayPnl )
		pnl.changeButton:SetText( "" )
		pnl.changeButton:SetImage( "pointshop2/pencil54.png" )
		pnl.changeButton.m_Image:SetSize( 16, 16 )
		pnl.changeButton:DockMargin( 2, 2, 2, 2 )
		pnl.changeButton:Dock( RIGHT )
		pnl.changeButton:SetWide( 20 )
		pnl.changeButton:SetTall( 20 )
		function pnl.changeButton:DoClick( )
			Derma_StringRequest( "Input",
				"Please enter the new amount of " .. label,
				tostring( pnl.label:GetText( ) ),
				function( newValue )
					if not tonumber( newValue ) or tonumber( newValue ) > 2000000000 then
						Derma_Message( "Please enter a number <= 2,000,000,000", "Error" )
						return
					end
					frame:ChangePlayerWallet( name, tonumber( newValue ) )
				end
			)
		end

		function pnl:SetValue( val )
			self.label:SetText( val )
		end

		pnl:InvalidateLayout( true )
		pnl:SizeToChildren( false, true )

		return pnl
	end
	self.pointsPanel = self.walletInfo:AddCurrencyPanel( "points", "Points", 0, "pointshop2/dollar103_small.png" )
	self.premiumPointsPanel = self.walletInfo:AddCurrencyPanel( "premiumPoints", "Premium Points", 0, "pointshop2/donation_small.png" )
	hook.Add( "PS2_WalletChanged", self, self.PlayerWalletChanged )

	self.slotsCategory, self.slotsCategoryPnl = self:AddCategory( "Player Slots" )
	local slotsScroll = vgui.Create( "DScrollPanel", self.slotsCategory )
	slotsScroll:DockMargin( 8, 0, 8, 0 )
	slotsScroll:Dock( TOP )
	slotsScroll:SetTall( 64 + 32 )
	slotsScroll:GetCanvas():DockPadding( 0, 0, 0, 5 )
	Derma_Hook( slotsScroll, "Paint", "Paint", "InnerPanelBright" )
	
	self.slotsLayout = vgui.Create( "DIconLayout", slotsScroll )
	self.slotsLayout:Dock( TOP )
	self.slotsLayout:DockMargin( 0, 0, 0, 0 )
	self.slotsLayout:SetSpaceX( 5 )
	self.slotsLayout:SetSpaceY( 5 )
	self.slotsLayout:SetBorder( 5, 5, 5, 5 )
	self.slotsLayout.Paint = function() end
	hook.Add( "PS2_OnSettingsUpdate", self, function()
		if self.playerData then
			self:RefreshInventory( )
		end
	end )

	self.invCategory, self.invCategoryPnl = self:AddCategory( "Player Inventory" )
	local scroll = vgui.Create( "DScrollPanel", self.invCategory )
	scroll:Dock( FILL )
	self.inventoryPanel = vgui.Create( "DIconLayout", scroll )
	self.inventoryPanel:Dock( TOP )
	self.inventoryPanel:SetSpaceY( 10 )
	self.inventoryPanel:SetSpaceX( 10 )

	self.invCategory:Dock( FILL )
	self.invCategoryPnl:Dock( FILL )
	function self.inventoryPanel:Paint( w, h )
	end

	self.invButtonPanel = vgui.Create( "DPanel", self.invCategoryPnl )
	self.invButtonPanel:Dock( BOTTOM )
	self.invButtonPanel:DockMargin( 5, 5, 5, 5 )
	self.invButtonPanel.Paint = function( ) end
	function self.invButtonPanel:PerformLayout( )
		local w = self:GetWide( ) / #self:GetChildren( )
		w = w - 5 * ( #self:GetChildren( ) - 1 )
		for k, v in pairs( self:GetChildren( ) ) do
			v:SetWide( w )
		end
	end

	self.invButtonPanel.giveItemButton = vgui.Create( "DButton", self.invButtonPanel )
	self.invButtonPanel.giveItemButton:SetImage( "pointshop2/plus24.png" )
	self.invButtonPanel.giveItemButton.m_Image:SetSize( 16, 16 )
	self.invButtonPanel.giveItemButton:SetText( "Give Item" )
	self.invButtonPanel.giveItemButton:Dock( LEFT )
	function self.invButtonPanel.giveItemButton.DoClick( )
		self:OpenGiveItemDialog( )
	end

	self.invButtonPanel.refreshButton = vgui.Create( "DButton", self.invButtonPanel )
	self.invButtonPanel.refreshButton:SetImage( "pointshop2/actualize.png" )
	self.invButtonPanel.refreshButton.m_Image:SetSize( 16, 16 )
	self.invButtonPanel.refreshButton:Dock( RIGHT )
	self.invButtonPanel.refreshButton:SetText( "Refresh Data" )
	self.invButtonPanel:DockMargin( 5, 0, 0, 0 )
	function self.invButtonPanel.refreshButton.DoClick( )
		self:RefreshInventory( )
	end

	self.detailsPanel:SetDisabled( true )
end

function PANEL:ChangePlayerWallet( name, value )
	self:NotifyLoading( true )
	Pointshop2View:getInstance( ):adminChangeWallet( self.playerData.id, name, value )
	:Done( function( wallet )
		self.pointsPanel:SetValue( wallet.points )
		self.premiumPointsPanel:SetValue(  wallet.premiumPoints )
		self:NotifyLoading( false, true )
	end )
	:Fail( function( errid, err )
		Derma_Message( err, "Error loading" )
		self:NotifyLoading( false, false )
	end )
end

function PANEL:NotifyLoading( bIsLoading, success )
	if bIsLoading then
		self.loadingNotifier:Expand( )
	else
		self.loadingNotifier:Collapse( )
		if success then
			self.detailsPanel:SetDisabled( false )
		else
			self.detailsPanel:SetDisabled( true )
		end
	end
end

function PANEL:AddCategory( name )
	local categoryPanel = vgui.Create( "DPanel", self.detailsPanel )
	categoryPanel:Dock( TOP )
	categoryPanel.Paint = function( ) end
	function categoryPanel:PerformLayout( )
		self:SizeToChildren( false, true )
	end

	categoryPanel.header = vgui.Create( "DLabel", categoryPanel )
	categoryPanel.header:SetText( name )
	categoryPanel.header:SetFont( self:GetSkin( ).SmallTitleFont )
	categoryPanel.header:Dock( TOP )
	categoryPanel.header:DockMargin( 5, 5, 5, 5 )
	categoryPanel.header:SetTextStyleColor( self:GetSkin( ).Colours.Label.Bright )

	categoryPanel.contents = vgui.Create( "DPanel", categoryPanel )
	categoryPanel.contents:Dock( TOP )
	categoryPanel.contents:SetTall( 128 )
	categoryPanel.contents:DockPadding( 5, 5, 5, 5 )
	categoryPanel.contents.Paint = function( ) end

	return categoryPanel.contents, categoryPanel
end

function PANEL:SetPlayerData( playerData )
	self.playerData = playerData

	self.generalInfo.avatar:SetSteamID( playerData.steam64 or "BOT", 64 )
	self.generalInfo.infoPanel.name:SetText( playerData.name or "ERROR" )
	self.generalInfo.infoPanel.steamId:SetText( playerData.player or "ERROR" )
	self.generalInfo.infoPanel.lastConnected:SetText( "Last Connected: " .. os.date( "%Y-%m-%d %H:%M", playerData.updated_at or 0 ) )

	if not playerData.wallet or not playerData.steam64 then
		local str = "Error: Couldn't get the info! Take a screen of this:"
		str = str .. LibK.luadata.Encode( playerData or {} )
		Derma_Message( str, "Warning" )
	else
		self.pointsPanel:SetValue( playerData.wallet.points )
		self.premiumPointsPanel:SetValue( playerData.wallet.premiumPoints )
	end

	-- Clear slot panel
	for k,v in pairs(self.slotsLayout:GetChildren()) do v:Remove() end

	-- Create slots
	for k, v in pairs(Pointshop2.EquipmentSlots) do
		local slotName = v.name
		local slotsPanel = self.slotsLayout:Add("DPanel")
		slotsPanel:DockPadding( 5, 5, 5, 5 )
		slotsPanel:SetWide( 80 )
		Derma_Hook( slotsPanel, "Paint", "Paint", "InnerPanel" )
		slotsPanel.itemHolder = vgui.Create("DPanel", slotsPanel)
		slotsPanel.itemHolder:SetSize(64, 64)
		slotsPanel.itemHolder:Dock(TOP)
		slotsPanel.itemHolder.Paint = function() end

		slotsPanel.label = vgui.Create("DLabel", slotsPanel)
		slotsPanel.label:Dock( TOP )
		slotsPanel.label:SetText( slotName )
		slotsPanel.label:SizeToContents()
		slotsPanel.label:SetContentAlignment( 5 )

		function slotsPanel:SetSlot(slotInstance)
			if IsValid(self.itemHolder.itemIcon) then
				self.itemHolder.itemIcon:Remove()
			end

			if slotInstance.Item then
				self.itemHolder.itemIcon = slotInstance.Item:getNewInventoryIcon()
				self.itemHolder.itemIcon.alwaysShowHoverPanel = true
				self.itemHolder.itemIcon:SetParent(self.itemHolder)
				self.itemHolder.itemIcon:Dock( FILL )
			end
		end

		self.slotsLayout[slotName] = slotsPanel
		function slotsPanel:PerformLayout()
			slotsPanel:SizeToChildren( false, true )
		end
		slotsPanel:InvalidateLayout( true )
	end

	-- Add equipped items
	for k,v in pairs(self.playerData.slots) do
		if not IsValid(self.slotsLayout[v.slotName]) then
			PrintTable(self.playerData.slots)
			PrintTable(Pointshop2.EquipmentSlots)
			KLogf( 2, "A slot with name %s was found in the database, however that slot is unknown ingame.", v.slotName )
			Pointshop2View:getInstance():showRepairDatabase( 
Format([[ERROR: You have references to a slot %s in the database that does not exist in game.
This can be fixed by repairing the database, however this will permanently delete the slot and items that are equipped in it for all players.
If you believe the slot should be there please make sure that all of your DLC and Addons are uploaded correctly.
Please contact support if you need more information.
]], v.slotName))
			continue
		end

		self.slotsLayout[v.slotName]:SetSlot( v )
		if v.Item then
			local pnl = self.slotsLayout[v.slotName]
			function pnl.OnMousePressed(icon, mcode)
				if mcode != MOUSE_RIGHT then
					return
				end
				local menu = DermaMenu()
				menu:SetSkin( Pointshop2.Config.DermaSkin )
				menu:AddOption( "Remove", function()
					self:NotifyLoading( true )
					self.inventoryPanel:SetDisabled(true)
					icon.itemHolder:Remove()
					Pointshop2View:getInstance():adminRemoveItem(ply, v.Item.id)
					:Fail( function( err )
						Pointshop2View:getInstance():displayError("Error removing item: " .. err)
					end )
					:Always( function( )
						self:RefreshInventory( )
						self.inventoryPanel:SetDisabled(false)
					end )
				end )
				menu:Open()
			end
			pnl.itemHolder.OnMousePressed = function(_self, mcode)
				pnl:OnMousePressed(mcode)
			end
			pnl.itemHolder.itemIcon.OnMousePressed = function(_self, mcode)
				pnl:OnMousePressed(mcode)
			end
		end
	end

	-- Clear Inv panel
	for k,v in pairs(self.inventoryPanel:GetChildren()) do v:Remove() end

	-- add items
	if playerData.inventory then
		for _, v in pairs(playerData.inventory:getItems()) do
			local icon = v:getNewInventoryIcon()
			function icon.OnMousePressed(icon, mcode)
				if mcode != MOUSE_RIGHT then
					return
				end
				local menu = DermaMenu()
				menu:SetSkin( Pointshop2.Config.DermaSkin )
				menu:AddOption( "Remove", function()
					self:NotifyLoading( true )
					self.inventoryPanel:SetDisabled(true)
					icon:Remove()
					Pointshop2View:getInstance():adminRemoveItem(ply, v.id)
					:Fail( function( err )
						Pointshop2View:getInstance():displayError("Error removing item: " .. err)
					end )
					:Always( function( )
						self:RefreshInventory( )
						self.inventoryPanel:SetDisabled(false)
					end )
				end )
				menu:Open()
			end
			icon:SetParent(self.inventoryPanel)
			icon.alwaysShowHoverPanel = true
		end
		self.inventoryPanel:Layout()
	end
end

function PANEL:PlayerWalletChanged( wallet, ply )
	if not self.playerData then return end

	if wallet.ownerId == self.playerData.id then
		self.pointsPanel:SetValue( wallet.points )
		self.premiumPointsPanel:SetValue( wallet.premiumPoints )
	end
end

function PANEL:OpenGiveItemDialog( )
	local frame = vgui.Create( "DPointshopManageUser_GiveItemDialog" )
	frame:MakePopup( )
	frame:SetKPlayer( self.playerData )
	frame:Center( )
	frame.parent = self
end

function PANEL:RefreshInventory( )
	if not self.playerData then
		ErrorNoHalt( "Couldn't refresh user: no previous user selected!" )
	end

	self:NotifyLoading( true )
	Pointshop2View:getInstance( ):getUserDetails( self.playerData.id )
	:Done( function( result )
		self:SetPlayerData( result )
	end )
	:Fail( function( errid, err )
		Derma_Message( err, "Error loading" )
	end )
	:Always( function( )
		self:NotifyLoading( false, true )
	end )
end

function PANEL:Paint( )
end

derma.DefineControl( "DPointshopManageUser_UserDetails", "", PANEL, "DPanel" )
