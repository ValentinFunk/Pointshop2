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

	self.targetHeight = 100
	self.duration = 10
end

function PANEL:setText( str )
	self.descriptionLabel:SetText( str )
	for i = 0.1, 0.5, 0.01 do
		timer.Simple(i, function()
			if IsValid(self) then
				self:RecalculateTargetSize()
			end
		end)
	end
end

function PANEL:RecalculateTargetSize() 
	local _oldSize = self:GetTall()
	self:SetTall( 10000 )
	self.descriptionLabel:PerformLayout( )
	self.descriptionLabel:InvalidateLayout( true )
	self.descriptionLabel:SetToFullHeight( )
	print( self:GetTall(), self.descriptionLabel:GetTall() )

	self:SizeToChildren( false, true )
	print( self:GetTall(), self.descriptionLabel:GetTall() )
	self.targetHeight = self:GetTall() + 5

	self:SetTall( _oldSize )
end

function PANEL:setIcon( icon )
	self.icon:SetImage( icon )
	self.icon:SizeToContents( )
end

Derma_Hook( PANEL, "Paint", "Paint", "InnerPanelBright" )

derma.DefineControl( "KNotificationPanel", "Simple Notification panel", PANEL, "DPanel" )