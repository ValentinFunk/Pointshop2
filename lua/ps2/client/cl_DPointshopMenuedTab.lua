--Basically a DPropertySheet but a bit changed
local PANEL = { }

function PANEL:Init( )
	self:SetContentAlignment( 4 )
	self:SetFont( self:GetSkin( ).ButtonFont or "DermaDefault" )
	
	derma.SkinHook( "Layout", "PointshopMenuButton", self )
end

function PANEL:PerformLayout( )
	self:ApplySchemeSettings( )
	self:SetWide( self:GetParent( ):GetWide( ) )
	
	if not self.Image then return end
	
	if self:IsActive( ) or self.Hovered then
		self.Image:SetImageColor( self:GetSkin( ).Highlight )
		self:SetColor( self:GetSkin( ).Highlight )
	else
		self.Image:SetImageColor( self:GetSkin( ).NormalBtn )
		self:SetColor( self:GetSkin( ).NormalBtn )
	end
	
	self.Image:SetSize( 32, 32 )
	self.Image:SetPos( 10, self:GetTall( ) / 2 - self.Image:GetTall( ) / 2 )
end

function PANEL:ApplySchemeSettings( )
	local active = self:GetPropertySheet( ):GetActiveTab( ) == self
	self:SetContentAlignment( 4 )
	
	local ExtraInset = 20

	if ( self.Image ) then
		ExtraInset = ExtraInset + self.Image:GetWide()
	end

	local Active = self:GetPropertySheet():GetActiveTab() == self

	self:SetTextInset( ExtraInset, 0 )
	
	local w, h = self:GetContentSize()
	self:SetTall( h + 30 )
	
	DLabel.ApplySchemeSettings( self )
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopMenuButton" )

derma.DefineControl( "DPointshopMenuButton", "", PANEL, "DTab" )

local PANEL = { }

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self.tabScroller:Remove( ) --dont need it
	self.tabScroller = nil

	self.leftBar = vgui.Create( "DPanel", self )
	self.leftBar:Dock( LEFT )
	self.leftBar:SetWide( 245 )
	Derma_Hook( self.leftBar, "Paint", "Paint", "InnerPanel" )
	
	self.buttons = vgui.Create( "DIconLayout", self.leftBar )
	self.buttons:Dock( FILL )
	
	self.buttons:DockMargin( 10, 10, 10, 10 )
	self.buttons:SetSpaceY( 10 )
end

function PANEL:PerformLayout( )
	local ActiveTab = self:GetActiveTab()
	local Padding = self:GetPadding()
	if not ActiveTab then 
		return 
	end
	
	self.buttons:PerformLayout( )
	
	ActiveTab:InvalidateLayout( true )
	local ActivePanel = ActiveTab:GetPanel()
	
	for k, v in pairs( self.Items ) do
		if v.Tab:GetPanel( ) == ActivePanel then
			v.Tab:GetPanel( ):SetVisible( true )
			--v.Tab:SetZPos( 100 )
		else
			v.Tab:GetPanel( ):SetVisible( false )	
			--v.Tab:SetZPos( 1 )
		end

		v.Tab:ApplySchemeSettings( )
	end

	ActivePanel:InvalidateLayout( )
	ActivePanel:SetTall( self:GetTall( ) )

	-- Give the animation a chance
	self.animFade:Run( )
end

function PANEL:AddSheet( )
	error( "pls dont" )
end

function PANEL:addMenuEntry( label, material, panel )
	if not IsValid( panel ) then 
		return
	end

	local Sheet = {}

	Sheet.Name = label;

	Sheet.Tab = self.buttons:Add( "DPointshopMenuButton" )
	Sheet.Tab:Setup( label, self, panel, material )
	Sheet.Tab:SetWide( self.buttons:GetWide( ) )

	Sheet.Panel = panel
	Sheet.Panel.NoStretchX = NoStretchX
	Sheet.Panel.NoStretchY = NoStretchY
	Sheet.Panel:SetVisible( false )

	panel:SetParent( self )
	panel:Dock( FILL )
	
	table.insert( self.Items, Sheet )

	if ( !self:GetActiveTab() ) then
		self:SetActiveTab( Sheet.Tab )
		Sheet.Panel:SetVisible( true )
	end

	return Sheet;
end

function PANEL:CloseTab( )
end

function PANEL:SetupCloseButton( )
end

function PANEL:Paint( w, h )
end

derma.DefineControl( "DPointshopMenuedTab", "", PANEL, "DPropertySheet" )