local PANEL = {}

function PANEL:Init( )
	self.image = vgui.Create( "DPreRenderedModelPanel", self )
	self.image:Dock( FILL )
	self.image:SetSize( 64, 64 )
	self.image:SetMouseInputEnabled( false )
end

function PANEL:SetItem( item )
	self.BaseClass.SetItem( self, item )

	if item.class.iconInfo.inv.useMaterialIcon then
		self.image:Remove()
		self.image = vgui.Create( "DImage", self )
		self.image:Dock( FILL )
		self.image:SetSize( 64, 64 )
		self.image:SetMouseInputEnabled( false )
		if Material(item.class.iconInfo.inv.iconMaterial) then
			self.image:SetImage( item.class.iconInfo.inv.iconMaterial )
		else
			LibK.GLib.Error("Invalid Material :" .. tostring(item.class.iconInfo.inv.iconMaterial) .. " for item " .. self:GetPrintName())
		end
	else
		local model = Pointshop2:GetPreviewModel()
		self.image:ApplyModelInfo( model )
		self.item = item
		self.image:SetPacOutfit( item:getOutfitForModel( model.model ) )
		self.image:SetViewInfo( item.class.iconInfo.inv.iconViewInfo )
	end
end

function PANEL:OnSelected( )
	self.image.forceRender = true
end

function PANEL:OnDeselected( )
	self.image.forceRender = false
end

function PANEL:Paint( w, h )
	--surface.SetDrawColor( Color( 255, 0, 0 ) )
	--surface.DrawRect( 0, 0, w, h )
end

vgui.Register( "DPointshopHatInvIcon", PANEL, "DPointshopInventoryItemIcon" )
