local PANEL = {}

function PANEL:Init( )
	self.image = vgui.Create( "DPreRenderedModelPanel", self )
	self.image:Dock( FILL )
	--self.image:SetSize( 128, 128 )
	self.image:DockMargin( 5, 0, 5, 5 )
	self.image:SetMouseInputEnabled( false )
end

function PANEL:SetItemClass( itemClass )
	self.BaseClass.SetItemClass( self, itemClass )
	
	if itemClass.iconInfo.inv.useMaterialIcon then
		self.image:Remove()
		self.image = vgui.Create( "DImage", self )
		self.image:Dock( FILL )
		self.image:SetSize( 64, 64 )
		self.image:SetMouseInputEnabled( false )
		self.image:SetImage( itemClass.iconInfo.inv.iconMaterial )
	else
		local model = Pointshop2:GetPreviewModel()
		self.image:ApplyModelInfo( model )
		self.image:SetPacOutfit( itemClass.getOutfitForModel( model.model ) )
		self.image:SetViewInfo( itemClass.iconInfo.shop.iconViewInfo )
	end
end

function PANEL:SetItem( item )
	self:SetItemClass( item.class )
end

function PANEL:PerformLayout( )
	if not IsValid( self.image ) then return end
	--self:SetTall( self.image:GetTall( ) + self.Label:GetTall( ) + 10 )
end

function PANEL:OnSelected( )
	self.image.forceRender = true
	hook.Run( "PACItemSelected", self.itemClass )
end

function PANEL:OnDeselected( )
	self.image.forceRender = false
	hook.Run( "PACItemDeSelected", self.itemClass )
end

derma.DefineControl( "DPointshopHatIcon", "", PANEL, "DPointshopItemIcon" )

local PANEL = {}

function PANEL:OnSelected( )
	hook.Run( "PACItemSelected", self.itemClass )
end

function PANEL:OnDeselected( )
	hook.Run( "PACItemDeSelected", self.itemClass )
end

derma.DefineControl( "DPointshopSimpleHatIcon", "", PANEL, "DPointshopSimpleItemIcon" )