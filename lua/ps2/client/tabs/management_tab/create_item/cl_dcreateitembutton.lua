local PANEL = {}

function PANEL:Init( )
end

function PANEL:OnMousePressed( )
	local creator = vgui.Create( self.itemInfo.creator )
	creator:MakePopup( )
	creator:SetItemBase( self.itemInfo.base )
	creator:SetSkin( Pointshop2.Config.DermaSkin )
	creator:InvalidateLayout( true )
	creator:Center( )
	if not self.itemInfo.noModal then
		creator:DoModal()
	end
end

function PANEL:SetItemInfo( itemInfo )
	self.icon:SetMaterial( Material( itemInfo.icon, "noclamp smooth" ) )
	self.label:SetText( itemInfo.label )
	self.itemInfo = itemInfo
	if itemInfo.tooltip then
		self:SetTooltip( itemInfo.tooltip )
	end
end

derma.DefineControl( "DCreateItemButton", "", PANEL, "DBigButton" )
