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
end

function PANEL:SetItemInfo( itemInfo )
	self.icon:SetMaterial( Material( itemInfo.icon, "noclamp smooth" ) )
	self.label:SetText( itemInfo.label )
	self.itemInfo = itemInfo
end

derma.DefineControl( "DCreateItemButton", "", PANEL, "DBigButton" )