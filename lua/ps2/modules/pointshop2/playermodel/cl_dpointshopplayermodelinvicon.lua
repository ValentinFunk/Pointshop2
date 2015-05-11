local PANEL = {}

function PANEL:Init( )
	self.modelPanel = vgui.Create( "DModelPanel_PlayerModel", self )
	self.modelPanel:Dock( FILL )
	self.modelPanel:SetDragParent( self )
	self.modelPanel:SetMouseInputEnabled( false )
end

function PANEL:SetItem( item )
	self.BaseClass.SetItem( self, item )
	
	self.modelPanel:SetModel( item.playerModel )
	self.modelPanel.Entity:SetPos( Vector( -100, 0, -61 ) )
	
	local groups = string.Explode( " ", item.bodygroups ) 
	for k = 0, self.modelPanel.Entity:GetNumBodyGroups( ) - 1 do
		if ( self.modelPanel.Entity:GetBodygroupCount( k ) <= 1 ) then continue end
		self.modelPanel.Entity:SetBodygroup( k, groups[ k + 1 ] or 0 )
	end
	
	if self.modelPanel.Entity:SkinCount( ) - 1 > 0 then
		self.modelPanel.Entity:SetSkin( item.skin )
	end
end

function PANEL:Think( )
	if self.Selected or self:IsHovered( ) or self:IsChildHovered( 2 ) then
		self.modelPanel.drawHover = true
	else
		self.modelPanel.drawHover = false
	end
end

vgui.Register( "DPointshopPlayerModelInvIcon", PANEL, "DPointshopInventoryItemIcon" )