local PANEL = {}

function PANEL:Init( )
	self.image = vgui.Create( "DCenteredImage", self )
	self.image:Dock( FILL )
	self.image:SetMouseInputEnabled( false )
end

function PANEL:SetItemClass( itemClass )
	self.BaseClass.SetItemClass( self, itemClass )
	
	self.NormalTexture = Material( itemClass.material )
	if not self.NormalTexture then
		KLogf(2, "Item " .. itemClass.PrintName .. " there is an error with the texture " .. itemClass.material .. ": it could not be loaded")
		self.ScrollingTexture = self.NormalTexture
		return
	end
	if not self.NormalTexture:GetTexture( "$basetexture" ) then
		KLogf(2, "Item " .. itemClass.PrintName .. " there is an error with the texture " .. itemClass.material .. ": $basetexture could not be found")
		self.ScrollingTexture = self.NormalTexture
		return
	end

	self.ScrollingTexture = CreateMaterial( "PS2_MatScrollingTrailIcn" .. itemClass.material, "UnlitGeneric", {
		["$basetexture"] = self.NormalTexture:GetTexture( "$basetexture" ):GetName( ),
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

	if not self.noSelect and ( self.Hovered or self:IsChildHovered( 1 ) or self.Selected ) then
		self.image:SetMaterial( self.ScrollingTexture )
	else
		self.image:SetMaterial( self.NormalTexture )
	end
end

derma.DefineControl( "DPointshopTrailIcon", "", PANEL, "DPointshopItemIcon" )

local PANEL = {}

function PANEL:Init( )
	self.image = vgui.Create( "DCenteredImage", self )
	self.image:Dock( FILL )
	self.image:SetMouseInputEnabled( false )
end

function PANEL:SetItemClass( itemClass )
	self.BaseClass.SetItemClass( self, itemClass )
	
	self.image:SetImage( itemClass.material )
end

function PANEL:SetItem( item )
	self:SetItemClass( item.class )
end

derma.DefineControl( "DPointshopSimpleTrailIcon", "", PANEL, "DPointshopItemIcon" )