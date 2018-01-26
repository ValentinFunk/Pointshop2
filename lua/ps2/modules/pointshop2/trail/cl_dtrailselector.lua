local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self:SetSize( 25 + 64*8+63*4, 400 )
	
	self:SetTitle( "Select a Material" )
	
	local scroll = vgui.Create( "DScrollPanel", self )
	scroll:Dock( FILL )
	
	self.layout = vgui.Create( "DIconLayout", scroll )
	self.layout:SetSpaceX( 5 )
	self.layout:SetSpaceY( 5 )
	self.layout:DockMargin( 0, 2, 0, 5 )
	self.layout:SetWide( 25 + 64*8+63*4 )
	
	Pointshop2View:getInstance( ):requestMaterials( "trails" )
	:Then( function( files )
		self:SetTrails( files )
	end )
end

function PANEL:SetTrails( files )
	local materials = {}
	for k, v in pairs( files ) do
		v = string.Replace( v, ".vmt", "" )
		v = string.Replace( v, ".vtf", "" )
		v = "trails/" .. v
		if not table.HasValue( materials, v ) then
			table.insert( materials, v )
		end
	end
	
	for k, v in pairs( materials ) do
		local mat = Material( v )
		if not mat then continue end

		local btn = self.layout:Add( "DImageButton" )
		btn:SetSize( 64, 64 )
		btn:SetImage( v )
		btn.NormalMat = mat
		if mat:GetTexture( "$basetexture" ) then
			btn.ScrollingTexture = CreateMaterial( "PS2_MatScrollingTrail" .. v, "UnlitGeneric", {
				["$basetexture"] = mat:GetTexture( "$basetexture" ):GetName( ),
				["$translucent"] = 1,
				Proxies = {
					TextureScroll = {
						textureScrollVar = "$basetexturetransform",
						textureScrollRate = "0.8",
						textureScrollAngle = "90",
					}
				}
			} )
		else
			btn.ScrollingTexture = mat
		end
		function btn:Think( )
			if self.Hovered then
				self.m_Image:SetMaterial( self.ScrollingTexture )
			else
				self.m_Image:SetMaterial( self.NormalMat )
			end
		end
		function btn.DoClick( )
			self.selectedMaterial = btn.ScrollingTexture
			self.matName = v
			self:OnChange( )
			self:Close( )
		end
	end
	self.layout:InvalidateLayout( true )
end

function PANEL:OnChange( )
	--for overwriting
end

vgui.Register( "DTrailSelector", PANEL, "DFrame" )