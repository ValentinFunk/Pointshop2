local PANEL = {}

function PANEL:Init( )
	self:DockPadding( 8, 0, 8, 8 )

	self.titleLabel = vgui.Create( "DLabel", self )
	self.titleLabel:Dock( TOP )
	self.titleLabel:SetFont( self:GetSkin( ).TabFont )
	self.titleLabel:SetText( "No Item selected" )
	
	self.description = vgui.Create( "DMultilineLabel", self )
	self.description:Dock( TOP )
	self.description:SetVerticalScrollbarEnabled( false )
	timer.Simple( 1, function( )
		if not IsValid( self.description ) then return end
		self.description:SetFontInternal( self:GetSkin( ).TextFont )
		self.description:SetText( "Please Select an Item" )
		self.description:SetFontInternal( self:GetSkin( ).TextFont )
	end )
	self.description:SetText( "Please Select an Item" )
	self.description:SetFontInternal( self:GetSkin( ).TextFont )
	
	self.buyPanel = vgui.Create( "DPanel", self )
	self.buyPanel:Dock( TOP )
	self.buyPanel:DockMargin( 0, 8, 0, 0 )
	Derma_Hook( self.buyPanel, "Paint", "Paint", "InnerPanelBright" )
	self.buyPanel:SetTall( 100 )
	self.buyPanel:DockPadding( 5, 5, 5, 5 )
	function self.buyPanel:PerformLayout( )
		self:SizeToChildren( false, true )
	end
	
	local itemDesc = self
	local function AddBuyOption( icon, price, type )
		local pnl = vgui.Create( "DPanel", self.buyPanel )
		pnl:DockMargin( 0, 0, 0, 5 )
		function pnl:Paint( ) end
		pnl:Dock( TOP )
		function pnl:PerformLayout( )
			self.buyBtn:SetSize( 100, 25 )
			local h = math.max( self.label:GetTall( ), self.buyBtn:GetTall( ) )
			self:SetTall( h )
			
			self.icon:SetPos( 0, ( h - self.icon:GetTall( ) ) / 2 )
			self.label:SetColor( color_white )
			self.label:SetPos( 0 + self.icon:GetTall( ) + 5, ( h - self.label:GetTall( ) ) / 2 )
			self.buyBtn:SetPos( self:GetWide( ) - self.buyBtn:GetWide( ), ( h - self.buyBtn:GetTall( ) ) / 2 )
		end
		
		pnl.icon = vgui.Create( "DImage", pnl )
		pnl.icon:SetImage( icon )
		pnl.icon:SetSize( 16, 16 )
		
		pnl.label = vgui.Create( "DLabel", pnl )
		pnl.label:SetFont( self:GetSkin( ).fontName )
		pnl.label:SetText( price )
		pnl.label:SizeToContents( )
		
		pnl.buyBtn = vgui.Create( "DButton", pnl )
		pnl.buyBtn:SetText( "Buy Now" )
		function pnl.buyBtn:DoClick( )
			Pointshop2View:getInstance( ):startBuyItem( itemDesc.itemClass, type )
		end
	end
	
	function self.buyPanel:SetPriceInfo( priceInfo )
		for k, v in pairs( self:GetChildren( ) ) do
			v:Remove( ) 
		end
		if priceInfo.Points then
			AddBuyOption( "pointshop2/dollar103.png", priceInfo.Points, "Points" )
		end
		
		if priceInfo.DonorPoints then
			AddBuyOption( "pointshop2/donation.png", priceInfo.DonorPoints, "DonorPoints" )
		end
	end
end

function PANEL:SelectionReset( )
	self.titleLabel:SetText( "No Item selected" )
	self.titleLabel:SizeToContents( )
	self.description:SetText( "Please Select an Item" )
end

function PANEL:SetItemClass( itemClass )
	self.itemClass = itemClass

	self.titleLabel:SetText( itemClass.PrintName )
	self.titleLabel:SizeToContents( )
	
	self.description:SetText( itemClass.Description )
	
	self.buyPanel:SetPriceInfo( itemClass.Price )
end

function PANEL:PerformLayout( )
	self:SizeToChildren( false, true )
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopItemDescription" )

derma.DefineControl( "DPointshopItemDescription", "", PANEL, "DPanel" )