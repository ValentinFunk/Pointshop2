local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )

	self:DockPadding( 10, 0, 10, 10 )

	local label = vgui.Create( "DLabel", self )
	label:SetText( "User Selection" )
	label:SetColor( color_white )
	label:SetFont( self:GetSkin( ).TabFont )
	label:SizeToContents( )
	label:Dock( TOP )

	self.container = vgui.Create( "DCategoryList", self )
	self.container:Dock( FILL )

	function self.container:RequestToggle( category )
		if category:GetExpanded( ) then
			return false
		end

		for k, v in pairs( self.pnlCanvas:GetChildren( ) ) do
			if v != category then
				v:DoExpansion( false )
			end
		end
		return true
	end

	local original = self.container.Add
	function self.container:Add( name )
		local cat = original( self, name )
		cat:DoExpansion( false )
		function cat.Header.DoClick( )
			if self:RequestToggle( cat ) then
				cat:Toggle( )
			end
		end
		return cat
	end

	local onlinePlayersCategory = self.container:Add( "Online Players" )
	self.onlinePlayersTable = vgui.Create( "DListView" )
	self.onlinePlayersTable:SetTall( 500 )
	self.onlinePlayersTable:SetMultiSelect( false )
	self.onlinePlayersTable:AddColumn( "Player" )
	self.onlinePlayersTable:AddColumn( "Points" )
	self.onlinePlayersTable:AddColumn( "Premium Points" )

	function self.onlinePlayersTable.OnRowSelected( tbl, rowId, row )
		self:OnUserSelected( row.kPlayerId )
	end

	function self.onlinePlayersTable:GetPlayerLine( ply )
		for k, v in pairs( self:GetLines( ) ) do
			if v.player == ply then
				return v
			end
		end
	end

	function self.onlinePlayersTable:Think( )
		for k, v in pairs( player.GetAll( ) ) do
			if not self:GetPlayerLine( v ) then
				local wallet = v:PS2_GetWallet( ) or { points = "", premiumPoints = "" }
				local line = self:AddLine( v:Nick( ), wallet.points, wallet.premiumPoints )
				line.player = v
				line.kPlayerId = v:GetNWInt( "KPlayerId" )
				function line:WalletChanged( wallet, ply )
					if ply and self.player == ply then
						self:SetColumnText( 2, wallet.points )
						self:SetColumnText( 3, wallet.premiumPoints )
					end
				end
				function line:Think( )
					self:SetColumnText( 1, self.player:Nick( ) )
				end
				hook.Add( "PS2_WalletChanged", line, line.WalletChanged )
			end
		end

		for k, v in pairs( self:GetLines( ) ) do
			if not IsValid( v.player ) then
				self:RemoveLine( v:GetID( ) )
			end
		end
	end

	onlinePlayersCategory:SetContents( self.onlinePlayersTable )
	onlinePlayersCategory:DockMargin( 5, 5, 5, 5 )
	self.onlinePlayersTable:Dock( TOP )
	onlinePlayersCategory.Header:DoClick( )

	local searchPlayerCategory = self.container:Add( "Search Players" )
	searchPlayerCategory:DockMargin( 5, 5, 5, 5 )
	self.searchPanel = vgui.Create( "DPanel" )
	self.searchPanel:SetTall( 500 )
	self.searchPanel.Paint = function( ) end
	searchPlayerCategory:SetContents( self.searchPanel )
	self.searchPanel:Dock( TOP )

	self.searchPanel.resultsTable = vgui.Create( "DListView", self.searchPanel )
	self.searchPanel.resultsTable:SetTall( 400 )
	self.searchPanel.resultsTable:SetMultiSelect( false )
	self.searchPanel.resultsTable:AddColumn( "Player" )
	self.searchPanel.resultsTable:AddColumn( "Last Connected" )
	self.searchPanel.resultsTable:AddColumn( "Points" )
	self.searchPanel.resultsTable:AddColumn( "Premium Points" )
	self.searchPanel.resultsTable:Dock( TOP )
	function self.searchPanel.resultsTable:SetResultSet( results )
		self:Clear( )
		for k, result in pairs( results ) do
			local line = self:AddLine( result.name, os.date( "%Y-%m-%d %H:%M", result.lastConnected ) )
			line.kPlayerId = result.id
			if result.Wallet then
				line:SetColumnText( 3, result.Wallet.points )
				line:SetColumnText( 4, result.Wallet.premiumPoints )
			end
			function line:GetSortValue( colId )
				if colId == 3 or colId == 4 then
					return tonumber( self.Columns[colId].Value ) or -math.huge
				else
					return self.Columns[colId].Value
				end
			end
		end
	end
	function self.searchPanel.resultsTable.OnRowSelected( tbl, rowId, row )
		self:OnUserSelected( row.kPlayerId )
	end

	self.searchForm = vgui.Create( "DPanel", self.searchPanel )
	self.searchForm:SetTall( 100 )
	self.searchForm:Dock( TOP )
	self.searchForm.Paint = function( ) end

	local left = vgui.Create( "DPanel", self.searchForm )
	left:Dock( LEFT )
	left.Paint = function( ) end
	left:SetWide( 150 )
	left:DockPadding( 5, 5, 5, 5 )

	left.textEntry = vgui.Create( "DTextEntry", left )
	left.textEntry:Dock( TOP )

	left.radioBtns = vgui.Create( "DRadioChoice", left )
	left.radioBtns:AddOption( "Name" )
	left.radioBtns:AddOption( "Steam ID" )
	left.radioBtns:AddOption( "Profile ID" )
	function left.radioBtns:PerformLayout( )
		self:SizeToContents( false, true )
	end
	left.radioBtns:SetTall( 60 )
	left.radioBtns:Dock( TOP )
	left.radioBtns:DockMargin( 0, 5, 5, 0 )

	local right = vgui.Create( "DPanel", self.searchForm )
	right:Dock( LEFT )
	right.Paint = function( ) end
	right:DockPadding( 5, 5, 5, 5 )
	right:SetWide( 100 )

	self.searchBtn = vgui.Create( "DButton", right )
	self.searchBtn:SetText( "Search" )
	self.searchBtn:SetImage( "pointshop2/magnifier12.png" )
	self.searchBtn.m_Image:SetSize( 16, 16 )
	self.searchBtn:Dock( TOP )
	function self.searchBtn.DoClick( )
		Pointshop2View:getInstance( ):searchPlayers( left.textEntry:GetText( ), left.radioBtns:GetSelectedOption( ):GetText( ) )
		:Done( function( results )
			self.searchPanel.resultsTable:SetResultSet( results )
		end )
		:Fail( function( errId, err )
			Derma_Message( err, "Error" )
		end )
		:Always( function( )
			self.searchBtn:SetDisabled( false )
		end )
		self.searchBtn:SetDisabled( true )
	end

	self:InvalidateLayout( )
end

function PANEL:SetDisabled( bDisabled )
	DPanel.SetDisabled( self )
	self.searchPanel.resultsTable:SetDisabled( bDisabled )
	self.onlinePlayersTable:SetDisabled( bDisabled )
end


function PANEL:Paint( )
end

derma.DefineControl( "DPointshopManageUser_SelectUser", "", PANEL, "DPanel" )
