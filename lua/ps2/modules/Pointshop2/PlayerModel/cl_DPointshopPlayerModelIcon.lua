local PANEL = {}

function PANEL:Init( )
	self.modelPanel = vgui.Create( "DModelPanel", self )
	self.modelPanel:Dock( FILL )
	self.modelPanel:SetFOV( 45 )
	self.modelPanel:SetCamPos( Vector( 0, 0, 0 ) )
	self.modelPanel:SetDirectionalLight( BOX_RIGHT, Color( 255, 160, 80, 255 ) )
	self.modelPanel:SetDirectionalLight( BOX_LEFT, Color( 80, 160, 255, 255 ) )
	self.modelPanel:SetAmbientLight( Vector( -64, -64, -64 ) )
	self.modelPanel:SetAnimated( false )
	self.modelPanel.Angles = Angle( 0, 0, 0 )
	self.modelPanel:SetLookAt( Vector( -100, 0, -22 ) )
end

function PANEL:SetItemClass( itemClass )
	local modelname = itemClass.model
	util.PrecacheModel( modelname )
	self.modelPanel:SetModel( modelname )
	self.modelPanel.Entity:SetPos( Vector( -100, 0, -61 ) )
	
	dp( itemClass.bodygroups )
	local groups = string.Explode( " ", itemClass.bodygroups ) 
	for k = 0, self.modelPanel.Entity:GetNumBodyGroups( ) - 1 do
		if ( self.modelPanel.Entity:GetBodygroupCount( k ) <= 1 ) then continue end
		self.modelPanel.Entity:SetBodygroup( k, groups[ k + 1 ] or 0 )
	end
	
	dp( "Skin:", itemClass.skin )
	if self.modelPanel.Entity:SkinCount( ) - 1 > 0 then
		self.modelPanel.Entity:SetSkin( itemClass.skin )
	end
end

function PANEL:SetItem( item )
	self:SetItemClass( item.class )
end

function PANEL:OnModified( )
end

derma.DefineControl( "DPointshopPlayerModelIcon", "", PANEL, "DPointshopItemIcon" )