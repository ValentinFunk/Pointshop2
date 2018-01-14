local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )

	self.lbl = vgui.Create( "DLabel", self )
	self.lbl:SetText( "You received an item" )
  self.lbl:SetFont( self:GetSkin( ).SmallTitleFont )
  self.lbl:SizeToContents( )
	self.lbl:Dock( TOP )
  self.lbl:DockMargin( 10, 10, 10, -5 )
  self.lbl:SetColor( self:GetSkin().Highlight )

  self.duration = 5
  self.targetHeight = 100
end

function PANEL:SetItem( item )
	self.item = item

	self.infoPnl = vgui.Create( "DPanel", self )
	self.infoPnl:Dock( TOP )
	self.infoPnl.Paint = function( ) end
	function self.infoPnl:PerformLayout( )
		if IsValid(self.desc) then 
			self.desc:DockMargin( self.icon:GetWide() + 10, 5, 0, 5 )
		end
		
		self:SizeToChildren( false, true )
	end

	self.infoPnl.desc = vgui.Create( item.class.GetPointshopDescriptionControl( ), self.infoPnl )
	self.infoPnl.desc:SetItem( item, true )
	self.infoPnl.desc:Dock( TOP )

  self.infoPnl.icon = item:getNewInventoryIcon( )
  self.infoPnl.icon:SetParent( self.infoPnl )
  self.infoPnl.icon:SetPos( 5, 5 )
  self.infoPnl.icon:SetSize( 64, 64 )
end

function PANEL:Think( )
	self.done = self.done or 1
	if self.done < 10 then
    local x = self:GetTall( )
    self:SetTall( 1000 )
    self.infoPnl:InvalidateLayout( true )
    local _, y = self.infoPnl:GetPos( )
		self.targetHeight = y + self.infoPnl:GetTall( ) + 10
    self:SetTall( x )
    self.done = self.done + 1
	end
end

function PANEL:Paint( )

end

vgui.Register( "DItemReceivedNotification", PANEL, "DPanel" )
