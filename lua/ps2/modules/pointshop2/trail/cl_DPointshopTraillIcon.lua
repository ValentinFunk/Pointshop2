local PANEL = {}

function PANEL:Init( )
	self.image = vgui.Create( "DImage", self )
	self.image:Dock( TOP )
	self.image:SetSize( 64, 64 )
	self.image:DockMargin( 5, 0, 5, 5 )
end

function PANEL:SetItemClass( itemClass )
	self.BaseClass.SetItemClass( self, itemClass )
	
	self.NormalTexture = Material( itemClass.material )
	self.ScrollingTexture = CreateMaterial( "PS2_MatScrollingTrailIcn" .. itemClass.material, "UnlitGeneric", {
		["$basetexture"] = Material( itemClass.material ):GetTexture( "$basetexture" ):GetName( ),
		["$translucent"] = 1,
		Proxies = {
			TextureScroll = {
				textureScrollVar = "$basetexturetransform",
				textureScrollRate = "0.8",
				textureScrollAngle = "90",
			}
		}
	} )
end

function PANEL:SetItem( item )
	self:SetItemClass( item.class )
end

function PANEL:Think( )
	if not self.NormalTexture then
		return
	end
	
	if self.Hovered or self:IsChildHovered( 1 ) or self.Selected then
		self.image:SetMaterial( self.ScrollingTexture )
	else
		self.image:SetMaterial( self.NormalTexture )
	end
end

function PANEL:PerformLayout( )
	self:SetTall( self.image:GetTall( ) + self.Label:GetTall( ) + 10 )
end

derma.DefineControl( "DPointshopTrailIcon", "", PANEL, "DPointshopItemIcon" )