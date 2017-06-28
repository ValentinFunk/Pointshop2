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
	
	self.descriptionLabel = vgui.Create( "DMultilineLabel", self )
	self.descriptionLabel.font = self:GetSkin( ).TextFont
	self.descriptionLabel:DockMargin( 5, 5, 5, 5 )
	self.descriptionLabel:Dock( TOP )
	self.descriptionLabel._lastNumLines = 0


	self.targetHeight = 100
	self.duration = 10
end

function PANEL:setText( str )
	self.descriptionLabel:SetText( str )
end

function PANEL:PerformLayout()
	self:RecalculateTargetSize()
end

function PANEL:RecalculateTargetSize() 
	self:SizeToChildren( false, true )
	self.targetHeight = self:GetTall() + 5
end

function PANEL:setIcon( icon )
	self.icon:SetImage( icon )
	self.icon:SizeToContents( )
end

Derma_Hook( PANEL, "Paint", "Paint", "InnerPanelBright" )

derma.DefineControl( "KNotificationPanel", "Simple Notification panel", PANEL, "DPanel" )