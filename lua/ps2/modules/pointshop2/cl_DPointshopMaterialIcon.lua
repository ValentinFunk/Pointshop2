local PANEL = {}

function PANEL:Init( )
	self.image = vgui.Create( "DCenteredImage", self )
	self.image:Dock( FILL )
	self.image:SetMouseInputEnabled( false )
	self.image:DockMargin( 5, 5, 5, 5 )
end

function PANEL:SetItemClass( itemClass )
	self.BaseClass.SetItemClass( self, itemClass )
	if itemClass.material then
		self.image:SetImage( itemClass.material )
	else
		ErrorNoHalt( "Invalid material on item class " .. tostring( itemClass.name ) )
	end
end

function PANEL:SetItem( item )
	self:SetItemClass( item.class )
end

derma.DefineControl( "DPointshopMaterialIcon", "", PANEL, "DPointshopItemIcon" )
