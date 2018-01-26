local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self:SetSize( math.min( ScrW() - 10, 1255 ), math.min( ScrH( ) - 10, 768 ) )

	self.topBar = vgui.Create( "DPanel", self )
	self.topBar:Dock( TOP )
	self.topBar:SetTall( 114 )
	Derma_Hook( self.topBar, "Paint", "Paint", "TopBar" )

	self.closeButton = vgui.Create( "DButton", self.topBar )
	self.closeButton:SetText( "x" )
	self.closeButton:SizeToContents( )
	self.closeButton.Paint = function( ) end
	self.closeButton:SetPos( self:GetWide( ) - 15 - self.closeButton:GetWide( ), 10 )
	function self.closeButton:DoClick( )
		Pointshop2:CloseMenu( )
	end
	self.closeButton:SetZPos( 2 )

	self.infoPanel = vgui.Create( "DPanel", self.topBar )
	function self.infoPanel:Paint( w, h )
	end
	self.infoPanel:Dock( LEFT )
	self.infoPanel:DockPadding( 10, 4, 10, 10 )
	self.infoPanel:SetWide( 250 )

	self.titleLabel = vgui.Create( "DLabel", self.infoPanel )
	self.titleLabel:Dock( TOP )
	self.titleLabel:SetText( "Pointshop" )
	self.titleLabel:SetColor( color_white )
	self.titleLabel:SetFont( self:GetSkin( ).BigTitleFont )
	self.titleLabel:SetTall( 48 )

	self.titleLabel2 = vgui.Create( "DLabel", self.titleLabel )
	self.titleLabel2:Dock( LEFT )
	surface.SetFont( self:GetSkin( ).BigTitleFont )
	local left = surface.GetTextSize( self.titleLabel:GetText( ) ) + surface.GetTextSize( " " )
	self.titleLabel2:DockMargin( left, 0, 0, 0 )
	self.titleLabel2:SetText( "2" )
	self.titleLabel2:SetColor( Color( 255, 198, 0 ) )
	self.titleLabel2:SetFont( self:GetSkin( ).BigTitleFont )

	self.currencyPanel = vgui.Create( "DPanel", self.infoPanel )
	self.currencyPanel:Dock( FILL )
	function self.currencyPanel:Paint( w, h )
	end

	self.pointsMoneyPanel = vgui.Create( "DPanel", self.currencyPanel )
	self.pointsMoneyPanel:Dock( TOP )
	self.pointsMoneyPanel:SetTall( 24 )
	self.pointsMoneyPanel:SetTooltip( "Standard Points" )
	function self.pointsMoneyPanel:Paint( w, h)
	end

	self.pointsMoneyPanel.icon = vgui.Create( "DImage", self.pointsMoneyPanel )
	self.pointsMoneyPanel.icon:SetMaterial( Material( "pointshop2/dollar103_small.png", "noclamp smooth" ) )
	self.pointsMoneyPanel.icon:Dock( LEFT )
	self.pointsMoneyPanel.icon:DockMargin( 0, 2, 5, 2 )
	self.pointsMoneyPanel.icon:SetSize( 20, 20 )

	self.pointsMoneyPanel.label = vgui.Create( "DLabel", self.pointsMoneyPanel )
	self.pointsMoneyPanel.label:SetText( "12,000" )
	self.pointsMoneyPanel.label:SetFont( self:GetSkin( ).fontName )
	self.pointsMoneyPanel.label:Dock( FILL )
	function self.pointsMoneyPanel.label:Think( )
		self:SetText( LocalPlayer().PS2_Wallet.points )
	end

	self.donationMoneyPanel = vgui.Create( "DPanel", self.currencyPanel )
	self.donationMoneyPanel:Dock( TOP )
	self.donationMoneyPanel:DockMargin( 0, 0, 0, 5 )
	self.donationMoneyPanel:SetTall( 24 )
	self.donationMoneyPanel:SetTooltip( "Donator Points" )
	function self.donationMoneyPanel:Paint( w, h)
	end

	self.donationMoneyPanel.icon = vgui.Create( "DImage", self.donationMoneyPanel )
	self.donationMoneyPanel.icon:SetMaterial( Material( "pointshop2/donation_small.png", "noclamp smooth" ) )
	self.donationMoneyPanel.icon:SetSize( 22, 22 )
	self.donationMoneyPanel.icon:Dock( LEFT )
	self.donationMoneyPanel.icon:DockMargin( 0, 2, 5, 2 )
	function self.donationMoneyPanel.icon:PerformLayout( )
		self:SetWide( self:GetTall( ) )
	end

	self.donationMoneyPanel.label = vgui.Create( "DLabel", self.donationMoneyPanel )
	self.donationMoneyPanel.label:SetText( "370" )
	self.donationMoneyPanel.label:SetFont( self:GetSkin( ).fontName )
	self.donationMoneyPanel.label:Dock( FILL )
	function self.donationMoneyPanel.label:Think( )
		self:SetText( LocalPlayer().PS2_Wallet.premiumPoints )
	end

	self.contentsPanel = vgui.Create( "DPropertySheet", self )
	self.contentsPanel:DockMargin( 0, 0, 0, 0 )
	self.contentsPanel:Dock( FILL )

	self.contentsPanel.tabScroller:Dock( NODOCK )
	self.contentsPanel.tabScroller:SetParent( self.topBar )
	self.contentsPanel.tabScroller:Dock( FILL )
	self.contentsPanel.tabScroller:DockMargin( 10, 10, 10, 10 )
	self.contentsPanel.tabScroller:SetOverlap( -10 )
	self.contentsPanel.tabScroller:SetZPos( 1 )

	for _, tabTbl in pairs( Pointshop2.RegisteredTabs ) do
		if tabTbl.shouldShow and not tabTbl.shouldShow( ) then
			continue
		end

		local sheet = self.contentsPanel:AddSheet( tabTbl.title, vgui.Create( tabTbl.control ), false, false, false, "" )
		sheet.Panel:SetPos( self.contentsPanel:GetPadding( ), self.contentsPanel:GetPadding( ) )
		derma.SkinHook( "Layout", "PropertySheetSheet", self, sheet )
	end

	CloseDermaMenus( )

	self.footer = vgui.Create( "DPanel", self )
	self.footer:Dock( BOTTOM )
	self.footer:SetTall( 25 )

	local lbl = vgui.Create( "DLabel", self.footer )
	lbl:SetText( "Pointshop 2 Build " .. ( PS2_BUILD or "unknown" ) .. "    |    Icons designed by Freepik     |    " )
	lbl:Dock( LEFT )
	lbl:SizeToContents( )
	lbl:DockMargin( 5, 4, 5, 5 )

	local lbl = vgui.Create( "DButton", self.footer )
	lbl:Dock( LEFT )
	lbl:SizeToContents( )
	lbl:DockMargin( 5, 4, 5, 5 )
	lbl:SetWide( 70 )
	lbl:SetText( "Credits" )
	lbl:SetColor( Color( 255, 255, 0 ) )
	function lbl:DoClick( )
		local creditWindow = vgui.Create( "DCreditWindow" )
		creditWindow:MakePopup( )
	end

	Derma_Hook( self.footer, "Paint", "Paint", "Footer" )

	derma.SkinHook( "Layout", "PointshopFrame", self )
end

--[[---------------------------------------------------------
   Name: StartKeyFocus
-----------------------------------------------------------]]
function PANEL:StartKeyFocus( pPanel )
	self:SetKeyboardInputEnabled( true )
end

--[[---------------------------------------------------------
   Name: EndKeyFocus
-----------------------------------------------------------]]
function PANEL:EndKeyFocus( pPanel )
	self:SetKeyboardInputEnabled( false )
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopFrame" )
derma.DefineControl( "DPointshopFrame", "", PANEL, "EditablePanel" )
