local PANEL = {}

function PANEL:Init( )
	self.scroll = vgui.Create( "DScrollPanel", self )
	self.scroll:Dock( FILL )
	
	self.playersContainer = vgui.Create( "DPanel", self.scroll )
	self.playersContainer:Dock( TOP )
	self.playersContainer:DockPadding( 5, 5, 5, 5 )
	function self.playersContainer:PerformLayout( )
		self:SizeToChildren( false, true )
	end
	self.playersContainer.Paint = function( ) end
	
	self.playerLookup = { } -- ply -> PlayerPanel
	
	self.selectedPanel = nil
end

function PANEL:AddPlayer( ply )
	local panel = vgui.Create( "DButton", self.playersContainer )
	function panel:Think( )
		if IsValid( ply ) then
			panel:SetText( ply:Nick( ) )
		end
	end
	panel.avatarImage = vgui.Create( "AvatarImage", panel )
	panel.avatarImage:SetPlayer( ply, 32 )
	panel.avatarImage:SetSize( 32, 32 )
	panel:SetTall( 32 + 10 )
	panel:DockMargin( 0, 0, 0, 5 )
	panel:Dock( TOP )
	panel.player = ply
	
	function panel:PerformLayout( )
		DButton.PerformLayout( self )
		
		self.avatarImage:SetPos( 5, ( self:GetTall( ) - self.avatarImage:GetTall( ) ) / 2 )
	end
	
	function panel.DoClick( )
		self:SelectPlayer( ply )
	end
	
	self.playerLookup[ply] = panel
end

function PANEL:SetPlayers( tblPlayers ) 
	self.players = tblPlayers
	self:InvalidatePlayerTable()
end

function PANEL:SelectPlayer( ply )
	if IsValid( self.selectedPanel ) and ply == self.selectedPanel.player then
		return 
	end
	
	for k, v in pairs( self.playerLookup ) do
		local isSelected = v.player == ply
		v.Selected = isSelected
		if isSelected then
			self.selectedPanel = v
		end
	end
	self:OnChange( ply )
end

function PANEL:RemovePanelFor( ply )
	if self.playerLookup[ply].Selected then
		self.selectedPanel = nil
		self:OnChange( )
	end
	
	self.playerLookup[ply]:Remove( )
	self.playerLookup[ply] = nil
	self.playersContainer:InvalidateLayout( )
end

function PANEL:InvalidatePlayerTable( )
	--Clear invalid/removed
	for k, v in pairs( self.playersContainer:GetChildren( ) ) do
		if not IsValid( v.player ) or 
			not table.HasValue( self.players, v.player ) 
		then
			v:Remove( )
			self.playerLookup[v] = nil
		end
	end
	
	--Add added
	for k, v in pairs( self.players ) do
		if not IsValid( self.playerLookup[v] ) then
			self:AddPlayer( v )
		end
	end
end

function PANEL:ShowAllConncectedPlayers( exceptLocal )
	local function playersChanged( )
		local players = player.GetAll( )
		if exceptLocal then
			table.remove( players, table.KeyFromValue( players, LocalPlayer( ) ) )
		end
		table.sort( players, function( a, b )
			return a:Nick( ) < b:Nick( ) 
		end )
		self:SetPlayers( players )
	end
	
	hook.Add( "PlayerConnect", self, function( _, ply )
		playersChanged( )
	end )
	
	hook.Add( "PlayerDisconnected", self, function( _, ply )
		self:RemovePanelFor( ply )
	end )
	
	playersChanged( )
end

function PANEL:OnChange( ply )
	--For overwrite
end

Derma_Hook( PANEL, "Paint", "Paint", "InnerPanel" )

vgui.Register( "DPointshopPlayerSelect", PANEL, "DPanel" )