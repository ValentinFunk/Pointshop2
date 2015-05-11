local PANEL = {}

function PANEL:Init( )
	self.container = vgui.Create( "DPanel", self )
	self.container:Dock( FILL )
	self.container:DockMargin( 5, 5, 5, 5 )
	function self.container:Paint( w, h )
	end
	
	self.image = vgui.Create( "DImage", self.container )
	self.image:Dock( FILL )
end

function PANEL:SetItem( item )
	self.BaseClass.SetItem( self, item )
	self.image:SetMaterial( item.material or item.class.material )
end

function PANEL:PerformLayout( )
	local mulW = self.container:GetWide( ) / self.image:GetWide( )
	local mulH = self.container:GetTall( ) / self.image:GetTall( )
	
	local min = math.min( mulW, mulH )
	if min < 1 then
		self.image:SetSize( self.image:GetWide( ) * min, self.image:GetTall( ) * min )
		self.image:Center( )
	end
end

vgui.Register( "DPointshopMaterialInvIcon", PANEL, "DPointshopInventoryItemIcon" )