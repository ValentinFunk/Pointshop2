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

	self.generalInfo.avatar = vgui.Create( "AvatarImage", self.generalInfo )
	self.generalInfo.avatar:SetPos( 5, 5 )
	self.generalInfo.avatar:SetSteamID( "BOT", 64 )
	self.generalInfo.avatar:SetSize( 64, 64 )
	self.generalInfo.avatar:Dock( LEFT )
	self.generalInfo.avatar:DockMargin( 0, 0, 10, 0 )

	self.generalInfo.infoPanel = vgui.Create( "DPanel", self.generalInfo )
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
	self.walletInfo = self:AddCategory( "Player Wallet" )
	function self.walletInfo:PerformLayout( )
		local w = self:GetWide( ) / #self:GetChildren( )
		w = w - 5 * ( #self:GetChildren( ) - 1 )
		for k, v in pairs( self:GetChildren( ) ) do
			v:SetWide( w )
		end
	end
	self.walletInfo:SetTall( 70 )

	local frame = self
	function self.walletInfo:AddCurrencyPanel( name, label, value, icon )
		local pnl = vgui.Create( "DPanel", self )
		self[name .. "Panel"] = pnl
		pnl:Dock( LEFT )
		pnl:DockPadding( 5, 5, 5, 5 )
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

		pnl.changeButton = vgui.Create( "DButton", pnl )
		pnl.changeButton:SetText( "Edit" )
		pnl.changeButton:SetImage( "pointshop2/pencil54.png" )
		pnl.changeButton.m_Image:SetSize( 16, 16 )
		pnl.changeButton:DockMargin( 0, 5, 0, 0 )
		pnl.changeButton:Dock( TOP )
		function pnl.changeButton:DoClick( )
			Derma_StringRequest( "Input",
				"Please enter the new amount of " .. label,
				tostring( pnl.label:GetText( ) ),
				function( newValue )
					if not tonumber( newValue ) then
						Derma_Message( "Please enter a number", "Error" )
						return
					end
					frame:ChangePlayerWallet( name, newValue )
				end
			)
		end

		function pnl:SetValue( val )
			self.label:SetText( val )
		end

		return pnl
	end
	self.pointsPanel = self.walletInfo:AddCurrencyPanel( "points", "Points", 0, "pointshop2/dollar103_small.png" )
	self.premiumPointsPanel = self.walletInfo:AddCurrencyPanel( "premiumPoints", "Premium Points", 0, "pointshop2/donation_small.png" )
	hook.Add( "PS2_WalletChanged", self, self.PlayerWalletChanged )

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
	self.invButtonPanel.refreshButton:SetText( "Refresh Inventory" )
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
