local PANEL = {}

function PANEL:Init( )
    self:SetSkin( Pointshop2.Config.DermaSkin )

    self:DockPadding( 8, 0, 8, 8 )

    self.titleLabel = vgui.Create( "DLabel", self )
    self.titleLabel:Dock( TOP )
    self.titleLabel:SetFont( self:GetSkin( ).TabFont )
    self.titleLabel:SetText( "No Item selected" )

    self.description = vgui.Create( "DMultilineLabel", self )
    self.description:Dock( TOP )
    self.description:SetMaxHeight( 200 )
    self.description:SetVerticalScrollbarEnabled( true )
    timer.Simple( 1, function( )
        if not IsValid( self.description ) then return end
        self.description:SetFontInternal( self:GetSkin( ).TextFont )
    end )
    self.description:SetText( "Please Select an Item" )
    self.description:SetFontInternal( self:GetSkin( ).TextFont )

    self.buttonsPanel = vgui.Create( "DPanel", self )
    self.buttonsPanel:Dock( TOP )
    self.buttonsPanel:DockMargin( 0, 0, 0, 0 )
    Derma_Hook( self.buttonsPanel, "Paint", "Paint", "InnerPanelBright" )
    self.buttonsPanel:SetTall( 0 )
    self.buttonsPanel:DockPadding( 0, 0, 0, 0 )
    function self.buttonsPanel:PerformLayout( )
        self:SizeToChildren( false, true )
    end
    local itemDesc = self
    function self.buttonsPanel:Think( )
        if IsValid( itemDesc.stack ) and #itemDesc.stack.items > 1 and not itemDesc.noButtons then
            if not IsValid( self.sellStackBtn ) then
                self:AddSellStackButton( itemDesc.stack )
            end
        elseif IsValid( self.sellStackBtn ) then
            self.sellStackBtn:Remove( )
        end
    end

    function self.buttonsPanel:AddBuyOption( icon, price, type )
        local pnl = vgui.Create( "DPanel", itemDesc.buttonsPanel )
        pnl:DockMargin( 0, 0, 0, 5 )
        function pnl:Paint( ) end
        pnl:Dock( TOP )
        function pnl:PerformLayout( )
            self.buyBtn:SetSize( 100, 25 )
            local h = math.max( self.label:GetTall( ), self.buyBtn:GetTall( ) )
            self:SetTall( h )

            self.icon:SetPos( 0, ( h - self.icon:GetTall( ) ) / 2 )
            self.label:SetPos( 0 + self.icon:GetTall( ) + 5, ( h - self.label:GetTall( ) ) / 2 )
            self.buyBtn:SetPos( self:GetWide( ) - self.buyBtn:GetWide( ), ( h - self.buyBtn:GetTall( ) ) / 2 )
        end

        pnl.icon = vgui.Create( "DImage", pnl )
        pnl.icon:SetImage( icon )
        pnl.icon:SetSize( 16, 16 )

        pnl.label = vgui.Create( "DLabel", pnl )
        pnl.label:SetFont( itemDesc:GetSkin( ).fontName )
        pnl.label:SetText( price )
        pnl.label:SetColor( color_white )
        pnl.label:SizeToContents( )

        pnl.buyBtn = vgui.Create( "DButton", pnl )
        pnl.buyBtn:SetText( "Buy Now" )
        function pnl.buyBtn:DoClick( )
            pnl.buyBtn._purchasing = true
            pnl.buyBtn:SetDisabled( true )
            pnl.buyBtn:SetText( "Buying..." )
            Pointshop2View:getInstance( ):startBuyItem( itemDesc.itemClass, type ):Always( function()
                if not IsValid(pnl.buyBtn) then return end
                pnl.buyBtn:SetDisabled( false )
                pnl.buyBtn:SetText( "Buy Now" )
                pnl.buyBtn._purchasing = false
            end )
        end

        function pnl.buyBtn:Think( )
            if pnl.buyBtn._purchasing then return end

            pnl.buyBtn:SetDisabled( false )
            pnl.buyBtn:SetText( "Buy Now" )

            local canBuy, long, short = LocalPlayer( ):PS2_CanBuyItem( itemDesc.itemClass )
            if not canBuy then
                self:SetDisabled( true )
                self:SetText( short )
            end
        end

        return pnl
    end

    function self.buttonsPanel:Reset( )
        for k, v in pairs( self:GetChildren( ) ) do
            v:Remove( )
        end
        self:InvalidateLayout( )
        self:SetTall(0)
    end

    function self.buttonsPanel:AddBuyButtons( priceInfo )
        if priceInfo.points then
            self:AddBuyOption( "pointshop2/dollar103_small.png", priceInfo.points, "points" )
        end

        if priceInfo.premiumPoints then
            self:AddBuyOption( "pointshop2/donation_small.png", priceInfo.premiumPoints, "premiumPoints" )
        end
    end

    function self.buttonsPanel:AddSellButton( item )
        self.sellBtn = vgui.Create( "DButton", self )
        function self.sellBtn:Think( )
            if self:GetDisabled() then
                return
            end

            local price, currencyType = item:GetSellPrice( )
            if currencyType == "points" then
                self:SetText( "Sell Item (" .. price .. " points)" )
            elseif currencyType == "premiumPoints" then
                self:SetText( "Sell Item (" .. price .. " premium points)")
            end
        end
        self.sellBtn:Dock( TOP )
        function self.sellBtn:DoClick( )
            self:SetDisabled( true )
            if IsValid( itemDesc.buttonsPanel.sellStackBtn ) then
                itemDesc.buttonsPanel.sellStackBtn:SetDisabled( true )
            end

            self:SetText( "Selling..." )
            Pointshop2View:getInstance( ):startSellItem( itemDesc.item ):Always(function()
                if IsValid(self) then
                    self:SetDisabled(false)
                end
                if IsValid( itemDesc.buttonsPanel.sellStackBtn ) then
                    itemDesc.buttonsPanel.sellStackBtn:SetDisabled( false )
                end
            end)
        end
    end

    function self.buttonsPanel:AddSellStackButton( stack )
        self.sellStackBtn = vgui.Create( "DButton", self )
        self.sellStackBtn:DockMargin( 0, 5, 0, 0 )
        function self.sellStackBtn:Think( )
            if self:GetDisabled() then
                return
            end

            local sellPrice, currencyType = 0, nil
            for k, v in pairs( stack.items ) do
                local _price, _currencyType = v:GetSellPrice( )
                currencyType = _currencyType
                sellPrice = sellPrice + _price
            end

            if currencyType == "points" then
                self:SetText( "Sell Stack (" .. table.Count( stack.items ) .. " items: " .. sellPrice .. " points)" )
            elseif currencyType == "premiumPoints" then
                self:SetText( "Sell Stack (" .. table.Count( stack.items ) .. " items: " .. sellPrice .. " premium points)" )
            end
        end
        self.sellStackBtn:Dock( TOP )
        function self.sellStackBtn:DoClick( )
            self:SetDisabled( true )
            if IsValid( itemDesc.buttonsPanel.sellBtn ) then
                itemDesc.buttonsPanel.sellBtn:SetDisabled( true )
            end

            local itemIds = {}
            for k, v in pairs( stack.items ) do
                table.insert( itemIds, v.id )
            end

            self:SetText( "Selling..." )
            Pointshop2View:getInstance( ):startSellItems( itemIds ):Always(function()
                if IsValid(self) then
                    self:SetDisabled(false)
                end
                if IsValid( itemDesc.buttonsPanel.sellBtn ) then
                    itemDesc.buttonsPanel.sellBtn:SetDisabled( false )
                end
            end)
        end
    end

    hook.Run( "PS2_ItemDescription_Init", self )
end

function PANEL:UpdateRankRestrictions( itemClass )
    if IsValid( self.ranksPanel ) then
        self.ranksPanel:Remove( )
    end

    local ranks = itemClass.Ranks
    if #ranks == 0 then
        return
    end

    self.ranksPanel = vgui.Create( "DPanel", self )
    self.ranksPanel:Dock( TOP )
    self.ranksPanel:DockMargin( 0, 8, 0, 0 )
    Derma_Hook( self.ranksPanel, "Paint", "Paint", "InnerPanelBright" )
    self.ranksPanel:SetTall( 100 )
    self.ranksPanel:DockPadding( 5, 5, 5, 5 )
    function self.ranksPanel:PerformLayout( )
        self:SizeToChildren( false, true )
    end

    local label = vgui.Create( "DLabel", self.ranksPanel )
    label:SetText( "This item is restricted to these ranks:" )
    label:Dock( TOP )
    label:SizeToContents( )

    for k, v in pairs( ranks ) do
        local title = PermissionInterface.getRankTitle( v )
        if not title then
            continue
        end

        local label = vgui.Create( "DLabel", self.ranksPanel )
        label:SetText( "- " .. title )
        label:Dock( TOP )
        label:SizeToContents( )
        label:DockMargin( 5, 0, 0, 0 )
    end

    local label = vgui.Create( "DLabel", self.ranksPanel )
    label:Dock( TOP )
    label:SizeToContents( )

    if not itemClass:PassesRankCheck( LocalPlayer( ) ) then
        label:SetText( "You can not purchase this item." )
        label:SetColor( Color( 255, 0, 0 ) )
    else
        label:SetText( "You can purchase this item." )
        label:SetColor( Color( 0, 255, 0 ) )
    end
end

function PANEL:UpdateServerRestrictions( servers )
    if IsValid( self.restrictionsPanel ) then
        self.restrictionsPanel:Remove( )
    end

    if #servers == 0 then
        return
    end

    self.restrictionsPanel = vgui.Create( "DPanel", self )
    self.restrictionsPanel:Dock( TOP )
    self.restrictionsPanel:DockMargin( 0, 8, 0, 0 )
    Derma_Hook( self.restrictionsPanel, "Paint", "Paint", "InnerPanelBright" )
    self.restrictionsPanel:SetTall( 100 )
    self.restrictionsPanel:DockPadding( 5, 5, 5, 5 )
    function self.restrictionsPanel:PerformLayout( )
        if #self:GetChildren() == 0 then
            self:SetTall(0)
            self:DockMargin( 0, 0, 0, 0 )
            self:DockPadding( 0, 0, 0, 0 )
        else
            self:DockPadding( 5, 5, 5, 5 )
            self:DockMargin( 0, 8, 0, 0 )
        end
        self:SizeToChildren( false, true )
    end

    local label = vgui.Create( "DLabel", self.restrictionsPanel )
    label:SetText( "This item is restricted to these servers:" )
    label:Dock( TOP )
    label:SizeToContents( )

    for k, v in pairs( servers ) do
        local label = vgui.Create( "DLabel", self.restrictionsPanel )
        label:SetText( "- " .. Pointshop2.GetServerById( v ).name )
        label:Dock( TOP )
        label:SizeToContents( )
        label:DockMargin( 5, 0, 0, 0 )
    end

    local label = vgui.Create( "DLabel", self.restrictionsPanel )
    label:Dock( TOP )
    label:SizeToContents( )
    if not table.HasValue( servers, Pointshop2.GetCurrentServerId( ) ) then
        label:SetText( "The item cannot be used on this server!" )
        label:SetColor( Color( 255, 0, 0 ) )
    else
        label:SetText( "The item can be used on this server!" )
        label:SetColor( Color( 0, 255, 0 ) )
    end
end

function PANEL:SelectionReset( )
    self.titleLabel:SetText( "No Item selected" )
    self.titleLabel:SizeToContents( )
    self.description:SetText( "Please Select an Item" )
    self.buttonsPanel:Reset( )
    self.stack = nil

    if self.restrictionsPanel then
        self.restrictionsPanel:Remove( )
    end

    hook.Run( "PS2_ItemDescription_SelectionReset", self )
end

function PANEL:SetItemClass( itemClass, noBuyPanel )
    self.item = nil
    self.stack = nil
    self.itemClass = itemClass

    self.titleLabel:SetText( itemClass.PrintName )
    self.titleLabel:SizeToContents( )

    self.description:SetText( itemClass.Description )

    self.buttonsPanel:Reset( )
    if not noBuyPanel then
        self.buttonsPanel:AddBuyButtons( itemClass:GetBuyPrice( LocalPlayer( ) ) )
    end

    self:UpdateServerRestrictions( itemClass.Servers )
    self:UpdateRankRestrictions( itemClass )

    hook.Run( "PS2_ItemDescription_SetItemClass", self, itemClass )
end

function PANEL:SetItem( item, noButtons )
    self:SetItemClass( item.class, true )
    self.stack = nil
    self.item = item
    self.noButtons = noButtons

    self.titleLabel:SetText( item:GetPrintName( ) )
    self.titleLabel:SizeToContents( )

    self.description:SetText( item:GetDescription( ) )

    self.buttonsPanel:Reset( )
    if item:CanBeSold( ) and not noButtons then
        self.buttonsPanel:AddSellButton( item )
    end

    hook.Run( "PS2_ItemDescription_SetItem", self, item )
end

function PANEL:SetStack( stack )
    self.stack = stack
end

function PANEL:PerformLayout( )
    if #self.buttonsPanel:GetChildren() > 0 then
        self.buttonsPanel:DockMargin( 0, 0, 0, 0 )
        self.buttonsPanel:DockPadding( 5, 5, 5, 5 )
    else
        self.buttonsPanel:DockMargin( 0, 0, 0, 0 )
        self.buttonsPanel:DockPadding( 0, 0, 0, 0 )
        self.buttonsPanel:SetTall(0)
    end
    self:SizeToChildren( false, true )
end

Derma_Hook( PANEL, "Paint", "Paint", "InnerPanel" )

derma.DefineControl( "DPointshopItemDescription", "", PANEL, "DPanel" )
