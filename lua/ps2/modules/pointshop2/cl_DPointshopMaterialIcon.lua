local PANEL = {}

function PANEL:Init( )
	self.container = vgui.Create( "DPanel", self )
	self.container:Dock( FILL )
	self.container:DockMargin( 5, 5, 5, 0 )
	function self.container:Paint( w, h )
	end
	self.container:SetMouseInputEnabled( false )
	
	self.image = vgui.Create( "DImage", self.container )
	self.image:SetMouseInputEnabled( false )
end

function PANEL:SetItemClass( itemClass )
	self.BaseClass.SetItemClass( self, itemClass )
	
	self.image:SetImage( itemClass.material )
	self.image:SizeToContents( )
end

function PANEL:SetItem( item )
	self:SetItemClass( item.class )
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

derma.DefineControl( "DPointshopMaterialIcon", "", PANEL, "DPointshopItemIcon" )