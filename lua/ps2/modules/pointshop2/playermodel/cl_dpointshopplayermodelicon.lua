local PANEL = {}

function PANEL:OnSelected( )
	local itemClass = self.itemClass
	Pointshop2.previewPanel:SetModel( itemClass.playerModel )
	
	for k = 0, Pointshop2.previewPanel.Entity:GetNumBodyGroups( ) - 1 do
		if ( Pointshop2.previewPanel.Entity:GetBodygroupCount( k ) <= 1 ) then continue end
		Pointshop2.previewPanel.Entity:SetBodygroup( k, self.bodyGroups[ k + 1 ] or 0 )
	end
	
	if Pointshop2.previewPanel.Entity:SkinCount( ) - 1 > 0 then
		Pointshop2.previewPanel.Entity:SetSkin( itemClass.skin )
	end
end

function PANEL:OnDeselected( )
	Pointshop2.previewPanel:ApplyModelInfo( Pointshop2:GetPreviewModel( ) )
end

function PANEL:SetItemClass( itemClass )
	DPointshopItemIcon.SetItemClass( self, itemClass )
	util.PrecacheModel( itemClass.playerModel )
	self.bodyGroups = string.Explode( " ", itemClass.bodygroups ) 
end

function PANEL:SetItem( item )
	self:SetItemClass( item.class )
end

function PANEL:SetSelected( b )
	DPointshopItemIcon.SetSelected( self, b )
	self.Selected = b
end

derma.DefineControl( "DPointshopPlayerModelIcon_Impl", "", PANEL, "DPointshopItemIcon" )

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
	DPointshopPlayerModelIcon_Impl.OnSelected( self )
	self.modelPanel:PlayPreviewAnimation( )
end

function PANEL:OnDeselected( )
	DPointshopPlayerModelIcon_Impl.OnDeselected( self )
	self.modelPanel:PlayIdleAnimation( )
end

function PANEL:SetItemClass( itemClass )
	DPointshopPlayerModelIcon_Impl.SetItemClass( self, itemClass )
	
	self.modelPanel:SetModel( itemClass.playerModel )
	self.modelPanel.Entity:SetPos( Vector( -100, 0, -61 ) )
	
	for k = 0, self.modelPanel.Entity:GetNumBodyGroups( ) - 1 do
		if ( self.modelPanel.Entity:GetBodygroupCount( k ) <= 1 ) then continue end
		self.modelPanel.Entity:SetBodygroup( k, self.bodyGroups[ k + 1 ] or 0 )
	end
	
	if self.modelPanel.Entity:SkinCount( ) - 1 > 0 then
		self.modelPanel.Entity:SetSkin( itemClass.skin )
	end
end

function PANEL:Think( )
	if self.Selected or self.IsHovered( ) or self:IsChildHovered( 2 ) then
		self.modelPanel.drawHover = true
	else
		self.modelPanel.drawHover = false
	end
end

derma.DefineControl( "DPointshopPlayerModelIcon", "", PANEL, "DPointshopPlayerModelIcon_Impl" )

local PANEL = {}

function PANEL:Init( )
	DPointshopSimpleItemIcon.InitText( self )
end

function PANEL:Paint( w, h )
	DPointshopSimpleItemIcon.Paint( self, w, h )
end

function PANEL:SetItemClass( itemClass )
	DPointshopPlayerModelIcon_Impl.SetItemClass( self, itemClass )
end

derma.DefineControl( "DPointshopSimplePlayerModelIcon", "", PANEL, "DPointshopPlayerModelIcon_Impl" )