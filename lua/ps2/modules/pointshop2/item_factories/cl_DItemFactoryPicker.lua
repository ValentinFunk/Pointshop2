local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self.scroll = vgui.Create( "DScrollPanel", self )
	self.scroll:Dock( FILL )
	
	for k, factory in pairs( Pointshop2.ItemFactory.GetItemFactories( ) ) do
		local pnl = vgui.Create( "DButton", self.scroll )
		pnl:SetTall( 75 )
		pnl:Dock( TOP )
		pnl:DockPadding( 5, 5, 5, 5 )
		pnl:SetText( "" )
		pnl:DockMargin( 0, 5, 5, 5 )
		
		pnl.icon = vgui.Create( "DImage", pnl )
		pnl.icon:SetSize( 64, 64 )
		pnl.icon:Dock( LEFT )
		pnl.icon:SetTooltip( "Click to Select" )
		pnl.icon:SetImage( factory.Icon )
		pnl.icon:SetMouseInputEnabled( false )
		
		pnl.title = vgui.Create( "DLabel", pnl )
		pnl.title:Dock( TOP )
		pnl.title:DockMargin( 5, 0, 5, 0 )
		pnl.title:SetFont( self:GetSkin().SmallTitleFont )
		pnl.title:SetColor( self:GetSkin().Colours.Label.Bright )
		pnl.title:SetText( factory.Name )
		pnl.title:SizeToContents( )
		
		pnl.desc = vgui.Create( "DMultilineLabel", pnl )
		pnl.desc:Dock( TOP )
		pnl.desc:DockMargin( 5, 0, 5, 0 )
		pnl.desc:SetText( factory.Description )
		pnl.desc:SetMouseInputEnabled( false )
		
		function pnl.DoClick( )
			self.selectedFactory = factory 
			self:OnChange()
		end
		
		Derma_Hook( pnl, "Paint", "Paint", "Button" )
	end
end

function PANEL:OnChange( )
	--for overwriting
end

Derma_Hook( PANEL, "Paint", "Paint", "InnerPanel" )

vgui.Register( "DItemFactoryPicker", PANEL, "DPanel" )