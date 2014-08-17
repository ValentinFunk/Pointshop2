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
	self.buttonsPanel:DockMargin( 0, 8, 0, 0 )
	Derma_Hook( self.buttonsPanel, "Paint", "Paint", "InnerPanelBright" )
	self.buttonsPanel:SetTall( 100 )
	self.buttonsPanel:DockPadding( 5, 5, 5, 5 )
	function self.buttonsPanel:PerformLayout( )
		self:SizeToChildren( false, true )
	end
	
	local itemDesc = self
	local function AddBuyOption( icon, price, type )
		local pnl = vgui.Create( "DPanel", self.buttonsPanel )
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
		pnl.label:SetFont( self:GetSkin( ).fontName )
		pnl.label:SetText( price )
		pnl.label:SetColor( color_white )
		pnl.label:SizeToContents( )
		
		pnl.buyBtn = vgui.Create( "DButton", pnl )
		pnl.buyBtn:SetText( "Buy Now" )
		function pnl.buyBtn:DoClick( )
			Pointshop2View:getInstance( ):startBuyItem( itemDesc.itemClass, type )
		end
		
		local function updatePrices( )
			--Check 
			local pts = tonumber( LocalPlayer( ).PS2_Wallet[type] )
			if pts < price then
				--pnl.label:SetColor( Color( 255, 0, 0 ) )
				pnl.buyBtn:SetDisabled( true )
				pnl.buyBtn:SetText( "Can't afford" )
			else
				pnl.buyBtn:SetDisabled( false )
				pnl.label:SetColor( color_white )
				pnl.buyBtn:SetText( "Buy Now" )
			end
		end
		updatePrices( )
		hook.Add( "PS2_WalletChanged", pnl, updatePrices )
	end
	
	function self.buttonsPanel:Reset( )
		for k, v in pairs( self:GetChildren( ) ) do
			v:Remove( ) 
		end
		self:InvalidateLayout( )
	end
	
	function self.buttonsPanel:AddBuyButtons( priceInfo )
		if priceInfo.points then
			AddBuyOption( "pointshop2/dollar103.png", priceInfo.points, "points" )
		end
		
		if priceInfo.premiumPoints then
			AddBuyOption( "pointshop2/donation.png", priceInfo.premiumPoints, "premiumPoints" )
		end
	end
	
	function self.buttonsPanel:AddSellButton( price )
		self.sellBtn = vgui.Create( "DButton", self )
		self.sellBtn:SetText( "Sell Item (" .. price .. "pts)" )
		self.sellBtn:Dock( TOP )
		function self.sellBtn:DoClick( )
			Pointshop2View:getInstance( ):startSellItem( itemDesc.item )
		end
	end
end

function PANEL:SelectionReset( )
	self.titleLabel:SetText( "No Item selected" )
	self.titleLabel:SizeToContents( )
	self.description:SetText( "Please Select an Item" )
	self.buttonsPanel:Reset( )
end

function PANEL:SetItemClass( itemClass, noBuyPanel )
	self.itemClass = itemClass

	self.titleLabel:SetText( itemClass.PrintName )
	self.titleLabel:SizeToContents( )
	
	self.description:SetText( itemClass.Description )
	
	self.buttonsPanel:Reset( )
	if not noBuyPanel then
		self.buttonsPanel:AddBuyButtons( itemClass:GetBuyPrice( LocalPlayer( ) ) )
	end
end

function PANEL:SetItem( item, noButtons )
	self.item = item
	self:SetItemClass( item.class, true )
	
	self.buttonsPanel:Reset( )
	if item:CanBeSold( ) and not noButtons then --todo
		self.buttonsPanel:AddSellButton( item:GetSellPrice( ) )
	end
end

function PANEL:PerformLayout( )
	self:SizeToChildren( false, true )
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopItemDescription" )

derma.DefineControl( "DPointshopItemDescription", "", PANEL, "DPanel" )