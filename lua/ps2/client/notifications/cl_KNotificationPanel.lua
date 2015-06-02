local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self.iconContainer = vgui.Create( "DPanel", self )
	self.iconContainer:DockMargin( 5, 5, 5, 5 )
	self.iconContainer:Dock( LEFT )
	self.iconContainer:SetWide( 16 )
	function self.iconContainer:Paint( ) end
	
	self.icon = vgui.Create( "DImage", self.iconContainer )
	self.icon:Dock( TOP )
	
	self.descriptionLabel = vgui.Create( "RichText", self )
	self.descriptionLabel:SetFontInternal( self:GetSkin( ).TextFont )
	self.descriptionLabel:DockMargin( 5, 5, 5, 5 )
	self.descriptionLabel:Dock( FILL )
	self.descriptionLabel:SetVerticalScrollbarEnabled( false )
	self.descriptionLabel:SetPaintBackgroundEnabled( false )
	
	function self.descriptionLabel:Paint( )
	end

	self.targetHeight = 100
	self.duration = 10
end

function PANEL:setText( str )
	self.descriptionLabel:SetFontInternal( self:GetSkin( ).TextFont )
	self.descriptionLabel:SetText( str )
end

function PANEL:Think( )
	self.descriptionLabel:SetFontInternal( self:GetSkin( ).TextFont )
	self.done = self.done or 1
	if self.done < 10 then
		self.descriptionLabel:SetToFullHeight( )
		self.descriptionLabel:SetFontInternal( self:GetSkin( ).TextFont )
		self.descriptionLabel:SetTall( self.descriptionLabel:GetTall( ) + 30 )
		local x, y = self.descriptionLabel:GetPos( )
		self:SetTall( self.descriptionLabel:GetTall( ) + y )
		self.targetHeight = self.descriptionLabel:GetTall( ) + y
		self.descriptionLabel:SetFontInternal( self:GetSkin( ).TextFont )
		self.done = self.done + 1
	end
	self.descriptionLabel:SetFontInternal( self:GetSkin( ).TextFont )
end

function PANEL:setIcon( icon )
	self.icon:SetImage( icon )
	self.icon:SizeToContents( )
end

Derma_Hook( PANEL, "Paint", "Paint", "InnerPanelBright" )

derma.DefineControl( "KNotificationPanel", "Simple Notification panel", PANEL, "DPanel" )