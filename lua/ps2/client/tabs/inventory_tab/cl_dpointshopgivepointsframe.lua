local PANEL = {}

function PANEL:Init( )
	self:SetTitle( "Send Points" )
	self:SetSize( 400, 550 )
	
	self.points = 0
	self.selectedPly = nil
	
	self.selectPlyLabel = vgui.Create( "DLabel", self )
	self.selectPlyLabel:Dock( TOP )
	self.selectPlyLabel:SetText( "Select a Player" ) 
	self.selectPlyLabel:SizeToContents( )
	self.selectPlyLabel:DockMargin( 5, 5, 5, 10 )
	
	self.playerSelector = vgui.Create( "DPointshopPlayerSelect", self )
	self.playerSelector:Dock( TOP )
	self.playerSelector:SetTall( 10+5*7+8*42 )
	self.playerSelector:ShowAllConncectedPlayers( true )
	function self.playerSelector.OnChange( pnl, ply )
		self:SetPlayer( ply )
	end
	
	local bottomPnl = vgui.Create( "DPanel", self )
	bottomPnl:DockMargin( 0, 10, 0, 0 )
	bottomPnl:Dock( FILL )
	function bottomPnl:PerformLayout( )
		self.left:SetWide( ( self:GetWide( ) - 15 ) / 2 )
		self.right:SetWide( ( self:GetWide( ) - 15 ) / 2 )
	end
	bottomPnl:DockPadding( 5, 5, 5, 5 )
	Derma_Hook( bottomPnl, "Paint", "Paint", "InnerPanel" )
	
	local left = vgui.Create( "DPanel", bottomPnl )
	left:Dock( LEFT )
	left.Paint = function( ) end
	bottomPnl.left = left
	
	self.selectPointsLabel = vgui.Create( "DLabel", left )
	self.selectPointsLabel:Dock( TOP )
	self.selectPointsLabel:SetText( "Enter the amount" ) 
	self.selectPointsLabel:SizeToContents( )
	self.selectPointsLabel:DockMargin( 5, 5, 5, 10 )
	
	self.wang = vgui.Create( "DNumberWang", left )
	self.wang:Dock( TOP )
	self.wang:DockMargin( 5, 7, 5, 0 )
	self.wang:SetDisabled( true )
	function self.wang.OnValueChanged( )
		local clamped = math.Clamp( self.wang:GetValue( ), 0, tonumber(LocalPlayer().PS2_Wallet.points) )
		print(clamped,self.wang:GetValue( ), 0, tonumber(LocalPlayer().PS2_Wallet.points) )
		self:SetPoints( clamped )
	end	
	function self.wang.OnKeyCodeTyped( pnl, code )
		if code == KEY_ENTER then
			if not self.sendBtn:GetDisabled( ) then
				self.sendBtn:DoClick( )
			end
		end
	end
	
	local right = vgui.Create( "DPanel", bottomPnl )
	right:Dock( RIGHT )
	right.Paint = function( ) end
	bottomPnl.right = right
	
	self.confirmTop = vgui.Create( "DPanel", right )
	self.confirmTop:Dock( TOP )
	self.confirmTop.color = color_white
	self.confirmTop.font = "Default"
	function self.confirmTop:ApplySchemeSettings( )
		self.color = self:GetSkin().Highlight
		self.font = self:GetSkin().fontName
		if self.name then
			self:Update( self.points, self.name )
		end
	end
	function self.confirmTop:SetPlayer( ply )
		self:Update( self.points, IsValid( ply ) and ply:Nick( ) or "" )
	end
	function self.confirmTop:SetPoints( pts )
		self:Update( pts, self.name )
	end
	function self.confirmTop:Update( points, name )	
		self.points, self.name = points, name
		local text = Format( "<font=%s>Give <colour=%i,%i,%i,255>%i</colour> Points \nto <colour=%i,%i,%i,255>%s</colour></font>", 
			self.font,
			self.color.r, self.color.g, self.color.b, 
			points, 
			self.color.r, self.color.g, self.color.b, 
			name
		)
		self.parsed = markup.Parse( text )
		self:InvalidateLayout( )
	end
	function self.confirmTop:Paint( w, h )
		-- surface.SetDrawColor( color_black )
		-- surface.DrawRect( 0, 0, w, h )
		if self.parsed then
			self.parsed:Draw( 0, 0 )
		end
	end
	function self.confirmTop:PerformLayout( )
		if self.parsed then
			self:SetSize( self.parsed.totalWidth, self.parsed.totalHeight )
		end
	end
	self.confirmTop:Update( 0, "" )
	
	self.sendBtn = vgui.Create( "DButton", right )
	self.sendBtn:Dock( TOP )
	self.sendBtn:SetText( "Send" )
	self.sendBtn:SetImage( "pointshop2/check34.png" )
	self.sendBtn.m_Image:SetSize( 16, 16 )
	self.sendBtn:SetDisabled( true )
	self.sendBtn:DockMargin( 0, 5, 0, 5 )
	function self.sendBtn.DoClick( )
		self.sendBtn:SetDisabled( true )
		self.sending = true
		self.sendBtn:SetText( "Sending..." )
		Pointshop2View:getInstance( ):sendPoints( self.selectedPly, self.points ):Always(function()
			self:Remove( )
		end)
	end
end

function PANEL:ApplySchemeSettings( )
	self.selectPlyLabel:SetFont( self:GetSkin().SmallTitleFont )
	self.selectPlyLabel:SetColor( self:GetSkin().Colours.Label.Bright )
	self.selectPlyLabel:SizeToContents( )
	
	self.selectPointsLabel:SetFont( self:GetSkin().SmallTitleFont )
	self.selectPointsLabel:SetColor( self:GetSkin().Colours.Label.Bright )
	self.selectPointsLabel:SizeToContents( )
end

function PANEL:SetPlayer( ply )
	self.selectedPly = ply
	self.confirmTop:SetPlayer( ply )
	self:OnChange( )
	
	self:SetPoints( 0 )
	self.wang:SetText( "" )
	self.wang:RequestFocus( )
end

function PANEL:SetPoints( points )
	self.points = points
	self.confirmTop:SetPoints( points )
	self:OnChange( )
end

function PANEL:OnChange( )
	if self.sending then return end
	
	self.wang:SetDisabled( not IsValid( self.selectedPly ) )
	
	if self.points > 0 and IsValid( self.selectedPly ) then
		self.sendBtn:SetDisabled( false )
	else
		self.sendBtn:SetDisabled( true )
	end
end	

vgui.Register( "DPointshopGivePointsFrame", PANEL, "DFrame" )