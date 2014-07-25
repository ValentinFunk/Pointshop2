local PANEL = {}

function PANEL:Init( )
	self.modelPanel = vgui.Create( "DModelPanel_PlayerModel", self )
	self.modelPanel:Dock( FILL )
	self.modelPanel:SetFOV( 25 )
	self.modelPanel:SetAnimated( true )
	self.modelPanel.Angles = Angle( 0, 0, 0 )
	self.modelPanel:SetMouseInputEnabled( false )
end

function PANEL:OnSelected( )
	self.modelPanel:PlayPreviewAnimation( )
	Pointshop2.previewPanel._oldModel = Pointshop2.previewPanel.Entity:GetModel( )
	Pointshop2.previewPanel._oldBodygroups = {}
	for i = 0, Pointshop2.previewPanel.Entity:GetNumBodyGroups( ) - 1 do
		if Pointshop2.previewPanel.Entity:GetBodygroupCount( i ) <= 1 then 
			continue 
		end
		Pointshop2.previewPanel._oldBodygroups[i] = Pointshop2.previewPanel.Entity:GetBodygroup( i )
	end
	if self.modelPanel.Entity:SkinCount( ) > 1 then
		Pointshop2.previewPanel._oldSkin = Pointshop2.previewPanel.Entity:GetSkin( )
	else
		Pointshop2.previewPanel._oldSkin = nil
	end
	
	Pointshop2.previewPanel:SetModel( self.modelPanel.Entity:GetModel( ) )
	
	for i = 0, self.modelPanel.Entity:GetNumBodyGroups( ) - 1 do
		if self.modelPanel.Entity:GetBodygroupCount( i ) <= 1 then 
			continue 
		end
		Pointshop2.previewPanel.Entity:SetBodygroup( i, self.modelPanel.Entity:GetBodygroup( i ) )
	end
	if self.modelPanel.Entity:SkinCount( ) - 1 > 0 then
		Pointshop2.previewPanel.Entity:SetSkin( self.modelPanel.Entity:GetSkin( ) )
	end
end

function PANEL:OnDeselected( )
	self.modelPanel:PlayIdleAnimation( )
	
	Pointshop2.previewPanel:ApplyModelInfo( Pointshop2:GetPreviewModel( ) )
end

function PANEL:SetItemClass( itemClass )
	self.BaseClass.SetItemClass( self, itemClass )
	
	local modelname = itemClass.playerModel
	util.PrecacheModel( modelname )
	self.modelPanel:SetModel( modelname )
	self.modelPanel.Entity:SetPos( Vector( -100, 0, -61 ) )
	
	local groups = string.Explode( " ", itemClass.bodygroups ) 
	for k = 0, self.modelPanel.Entity:GetNumBodyGroups( ) - 1 do
		if ( self.modelPanel.Entity:GetBodygroupCount( k ) <= 1 ) then continue end
		self.modelPanel.Entity:SetBodygroup( k, groups[ k + 1 ] or 0 )
	end
	
	if self.modelPanel.Entity:SkinCount( ) - 1 > 0 then
		self.modelPanel.Entity:SetSkin( itemClass.skin )
	end
end

function PANEL:SetItem( item )
	self:SetItemClass( item.class )
end

function PANEL:SetSelected( b )
	self.Selected = b
end

function PANEL:Think( )
	if self.Selected or self.IsHovered( ) or self:IsChildHovered( 2 ) then
		self.modelPanel.drawHover = true
	else
		self.modelPanel.drawHover = false
	end
end

derma.DefineControl( "DPointshopPlayerModelIcon", "", PANEL, "DPointshopItemIcon" )