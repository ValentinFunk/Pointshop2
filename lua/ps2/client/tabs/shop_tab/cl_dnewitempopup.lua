local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self:SetTitle( "Item added" )
	self:SetSize( 410, 308 )
	
	self.lbl = vgui.Create( "DLabel", self )
	self.lbl:SetText( "An item was added to your inventory" )
	self.lbl:Dock( TOP )
end

function PANEL:SetItem( item )
	self.item = item
	
	self.infoPnl = vgui.Create( "DPanel", self )
	self.infoPnl:Dock( TOP )
	self.infoPnl.Paint = function( ) end
	function self.infoPnl:PerformLayout( )
		self.desc:DockMargin( self.icon:GetWide( ) + 10, 5, 0, 0 )
		self:SizeToChildren( false, true )
	end
	
	self.infoPnl.desc = vgui.Create( item.class.GetPointshopDescriptionControl( ), self.infoPnl )
	self.infoPnl.desc:SetItem( item, true )
	self.infoPnl.desc:Dock( FILL )
	
	self.infoPnl.icon = vgui.Create( item.class:GetConfiguredIconControl( ), self.infoPnl )
	self.infoPnl.icon:SetPos( 5, 5 )
	self.infoPnl.icon:SetItem( item )
	self.infoPnl.icon:SetMouseInputEnabled( false )
end

function PANEL:PerformLayout( )
	DFrame.PerformLayout( self )
	self:SizeToChildren( false, true )
end

vgui.Register( "DNewItemPopup", PANEL, "DFrame" )