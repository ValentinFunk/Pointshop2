local hoverPanel, lastHoveredPanel, hoverStart

hook.Add( "DrawOverlay", "KInvItemInfoPaintAdmin", function( )
	if ( dragndrop.m_Dragging != nil ) then return end
	
	local hoveredPanel = vgui.GetHoveredPanel( )

	if not IsValid( hoveredPanel ) then
		hoverStart = RealTime()
		return
	end

    if hoveredPanel != lastHoveredPanel then
        if IsValid( hoverPanel ) then
			hoverPanel:Remove( )
        end
	end
	lastHoveredPanel = hoveredPanel
	/*if RealTime() < hoverStart + 0.05 then
		return
	end*/

	if hoveredPanel.itemClass and hoveredPanel.isAdminPnl then
		if not IsValid( hoverPanel ) then
			hoverPanel = vgui.Create("DAdminHoverPanel")
			hoverPanel:SetSize(300, 300)
			hoverPanel:SetPaintedManually( true )
			hoverPanel:SetTargetPanel( hoveredPanel )
			hoverPanel:SetItemClass( hoveredPanel.itemClass )
		end

		DisableClipping( true )
		local itemBottomCenterX, itemBottomCenterY = hoveredPanel:LocalToScreen( hoveredPanel:GetWide( ) / 2, hoveredPanel:GetTall( ) )
		local paintPosX, paintPosY = itemBottomCenterX - hoverPanel:GetWide( ) / 2, itemBottomCenterY

		paintPosX = math.Clamp( paintPosX, 0, ScrW( ) )
		if paintPosX + hoverPanel:GetWide( ) > ScrW( ) then
			paintPosX = ScrW( ) - hoverPanel:GetWide( )
		end

		if paintPosY + hoverPanel:GetTall( ) > ScrH( ) then
			paintPosY = ScrH( ) - hoverPanel:GetTall( )
			hoverPanel:SetTargetPanel( nil )
		else
			hoverPanel:SetTargetPanel( hoveredPanel )
		end

		hoverPanel:SetPaintedManually( false )
		hoverPanel:PaintAt( paintPosX, paintPosY )
		hoverPanel:SetPaintedManually( true )
		DisableClipping( false )
	end
end )

local PANEL = {}

function PANEL:Init()
    self:SetSkin(Pointshop2.Config.DermaSkin)
    self:DockPadding( 8, 19, 8, 8 )

    self.currencyPanel = vgui.Create( "DSplitPanel", self )
    self.currencyPanel:Dock( TOP )
	function self.currencyPanel:Paint( w, h )
	end

	self.pointsMoneyPanel = vgui.Create( "DPanel", self.currencyPanel.left )
	self.pointsMoneyPanel:Dock( TOP )
	self.pointsMoneyPanel:SetTall( 24 )
	self.pointsMoneyPanel:SetTooltip( "Standard Points" )
	function self.pointsMoneyPanel:Paint( w, h)
	end

	self.pointsMoneyPanel.icon = vgui.Create( "DImage", self.pointsMoneyPanel )
	self.pointsMoneyPanel.icon:SetMaterial( Material( "pointshop2/dollar103_small.png", "noclamp smooth" ) )
	self.pointsMoneyPanel.icon:Dock( LEFT )
	self.pointsMoneyPanel.icon:DockMargin( 0, 2, 8, 2 )
	self.pointsMoneyPanel.icon:SetSize( 20, 20 )

	self.pointsMoneyPanel.label = vgui.Create( "DLabel", self.pointsMoneyPanel )
	self.pointsMoneyPanel.label:SetFont( self:GetSkin( ).fontName )
	self.pointsMoneyPanel.label:Dock( FILL )

	self.donationMoneyPanel = vgui.Create( "DPanel", self.currencyPanel.right )
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
	self.donationMoneyPanel.icon:DockMargin( 0, 2, 8, 2 )
	function self.donationMoneyPanel.icon:PerformLayout( )
		self:SetWide( self:GetTall( ) )
	end

	self.donationMoneyPanel.label = vgui.Create( "DLabel", self.donationMoneyPanel )
	self.donationMoneyPanel.label:SetFont( self:GetSkin( ).fontName )
    self.donationMoneyPanel.label:Dock( FILL )
end    

function PANEL:SetTargetPanel( pnl )
	self.targetPanel = pnl
end

function PANEL:InitRestrictons( cls )
    if IsValid(self.restrictionsPanel) then
        self.restrictionsPanel:Remove()
    end
    if not cls.Ranks or #cls.Ranks == 0 then
        return
    elseif cls.Ranks and #cls.Ranks > 0 and not IsValid( self.restrictionsPanel ) then
        self.restrictionsPanel = vgui.Create( "DPanel", self )
        self.restrictionsPanel:Dock( TOP )
        self.restrictionsPanel:DockMargin( 0, 8, 0, 0 )
        self.restrictionsPanel.Paint = function() end

        local lbl = vgui.Create( "DLabel", self.restrictionsPanel )
        lbl:SetColor( color_white )
        lbl:SetText( "Can only be bought by:" )
        lbl:SetFont( self:GetSkin().fontName )
        lbl:SizeToContents()
        lbl:Dock(TOP)

        self.restrictionsPanel.ranks = vgui.Create("DIconLayout", self.restrictionsPanel)
        self.restrictionsPanel.ranks:Dock( TOP )
        self.restrictionsPanel.ranks:SetSpaceX( 5 )
    end

    
    for k, v in pairs(self.restrictionsPanel.ranks:GetChildren()) do
        v:Remove()
    end
    self.restrictionsPanel.ranks:InvalidateLayout( true )
    for k, v in pairs( cls.Ranks ) do
        local rankLbl = self.restrictionsPanel.ranks:Add("DLabel")
        rankLbl:SetText( v )
        rankLbl:SizeToContents( )
    end
    self.restrictionsPanel.ranks:InvalidateLayout( true )
end

function PANEL:InitServerRestrictons( cls )
    if IsValid(self.serverRestrictionsPanel) then
        self.serverRestrictionsPanel:Remove()
    end
    if not cls.Servers or #cls.Servers == 0 then
        return
    elseif cls.Servers and #cls.Servers > 0 and not IsValid( self.serverRestrictionsPanel ) then
        self.serverRestrictionsPanel = vgui.Create( "DPanel", self )
        self.serverRestrictionsPanel:Dock( TOP )
        self.serverRestrictionsPanel:DockMargin( 0, 8, 0, 0 )
        self.serverRestrictionsPanel.Paint = function() end
        function self.serverRestrictionsPanel:PerformLayout()
            self:SizeToChildren( false, true )
            self:SetTall( self:GetTall() + 8 )
        end

        local lbl = vgui.Create( "DLabel", self.serverRestrictionsPanel )
        lbl:SetColor( color_white )
        lbl:SetText( "Can only be used on:" )
        lbl:SetFont( self:GetSkin().fontName )
        lbl:SizeToContents()
        lbl:Dock(TOP)

        self.serverRestrictionsPanel.servers = vgui.Create("DPanel", self.serverRestrictionsPanel)
        self.serverRestrictionsPanel.servers:Dock( TOP )
        self.serverRestrictionsPanel.servers.Paint = function() end
    end

    
    for k, v in pairs(self.serverRestrictionsPanel.servers:GetChildren()) do
        v:Remove()
    end
    self.serverRestrictionsPanel.servers:InvalidateLayout( true )
    for k, v in pairs( cls.Servers ) do
        local serverLbl = self.serverRestrictionsPanel.servers:Add( "DLabel" )
        serverLbl:SetText( Pointshop2.GetServerById( v ).name )
        serverLbl:SizeToContents( )
        serverLbl:Dock( TOP )
        serverLbl:DockMargin( 0, 2, 0, 0 )
    end
    self:InvalidateLayout( true )
end

function PANEL:SetItemClass( cls )
    self.itemClass = cls
    self.pointsMoneyPanel.label:SetText( cls.Price.points or " - " )
    self.donationMoneyPanel.label:SetText( cls.Price.premiumPoints or " - " )
    self:InitRestrictons( cls )
    self:InitServerRestrictons( cls )
end

function PANEL:PerformLayout()
    self:SizeToChildren( true, true )
    if IsValid(self.restrictionsPanel) then
        self.restrictionsPanel:SizeToChildren( false, true )
    end
end

Derma_Hook( PANEL, "Paint", "Paint", "ItemDescriptionPanel" )
vgui.Register( "DAdminHoverPanel", PANEL, "DPanel" )