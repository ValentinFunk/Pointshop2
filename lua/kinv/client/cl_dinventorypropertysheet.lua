surface.CreateFont('PS_Tab', { font = 'Roboto', size = 27, weight = 1000 })
local PANEL = {}
--[[---------------------------------------------------------
   Name: Init
-----------------------------------------------------------]]
function PANEL:Setup( label, pPropertySheet, pPanel, strMaterial )
	self:SetText( label )
	self:SetFont( "PS_Tab" )
	self:SetColor( color_white )
	self:SetPropertySheet( pPropertySheet )
	self:SetPanel( pPanel )
	self:SetContentAlignment( 5 )
	self:SetTextInset( 0, 0 )
end

Derma_Hook( PANEL, "Paint", "Paint", "InventoryTab" )

function PANEL:ApplySchemeSettings()
	local w, h = self:GetContentSize( )
	w = math.Clamp( w, 100, w )
	self:SetSize( w + 10, h + 5 )
		
	DLabel.ApplySchemeSettings( self )
end

derma.DefineControl( "DInventoryTab", "A Tab for use on the PropertySheet in Inv", PANEL, "DTab" )


local PANEL = {}

function PANEL:Init()
	self:SetPadding( 0 )
	self:DockPadding( 5, 0, 0, 0 )
	self:DockMargin( 0, 0, 0, 0 )
	self:SetShowIcons( true )
	
	if IsValid( self.tabScroller ) then
		self.tabScroller:Remove( )
	end
	
	self.tabScroller = vgui.Create( "DIconLayout", self )
	self.tabScroller:DockMargin( 0, 0, 0, 5 )
	self.tabScroller:Dock( TOP )
	self.tabScroller:SetSpaceX( 10 )
	self.tabScroller:SetTall( 50 )
	
	self.panels = vgui.Create( "DPanel", self )
	self.panels:DockMargin( 0, 0, 0, 0 )
	self.panels:Dock( FILL )
	function self.panels:Paint( )
	end

	self:SetFadeTime( 0.1 )
		
	self.animFade = Derma_Anim( "Fade", self, self.CrossFade )
	
	self.Items = {}
	
end



function PANEL:SetActiveTab( active ) 
	self.BaseClass.SetActiveTab( self, active )
end

--[[---------------------------------------------------------
   Name: AddSheet
-----------------------------------------------------------]]
function PANEL:AddSheet( label, panel, material, NoStretchX, NoStretchY, Tooltip )

	if ( !IsValid( panel ) ) then return end

	local Sheet = {}
	
	Sheet.Name = label;

	Sheet.Tab = self.tabScroller:Add( "DInventoryTab", self )
	Sheet.Tab:SetTooltip( Tooltip )
	Sheet.Tab:Setup( label, self, panel, material )
	Sheet.Tab:SizeToContentsX( )
	
	Sheet.Panel = panel
	Sheet.Panel.NoStretchX = NoStretchX
	Sheet.Panel.NoStretchY = NoStretchY
	Sheet.Panel:SetVisible( false )
	
	panel:SetParent( self.panels )
	
	table.insert( self.Items, Sheet )
	
	if ( !self:GetActiveTab() ) then
		self:SetActiveTab( Sheet.Tab )
		Sheet.Panel:SetVisible( true )
	end
	
	return Sheet;

end

function PANEL:Paint( w, h )
end

--[[---------------------------------------------------------
   Name: PerformLayout
-----------------------------------------------------------]]
function PANEL:PerformLayout()

	--self.tabScroller:SizeToContents( )
	self:SetPadding( self.tabScroller:GetTall( ) )

	local ActiveTab = self:GetActiveTab()
	local Padding = self:GetPadding()
	
	if ( !ActiveTab ) then return end
	
	-- Update size now, so the height is definitiely right.
	ActiveTab:InvalidateLayout( true )
		
	--self.tabScroller:StretchToParent( Padding, 0, Padding, nil )
	--self.tabScroller:SetTall( ActiveTab:GetTall() )
	--self.tabScroller:SizeToContents( )
	
	
	
	local ActivePanel = ActiveTab:GetPanel()
	for k, v in pairs( self.Items ) do
		if ( v.Tab:GetPanel() == ActivePanel ) then
			v.Tab:GetPanel():SetVisible( true )
			v.Tab:SetZPos( 100 )
		else
			v.Tab:GetPanel():SetVisible( false )	
			v.Tab:SetZPos( 1 )
		end
		v.Tab:ApplySchemeSettings()
	end
	
	if ( !ActivePanel.NoStretchX ) then 
		ActivePanel:SetWide( self:GetWide() - Padding * 2 ) 
	else
		ActivePanel:CenterHorizontal()
	end
	
	if ( !ActivePanel.NoStretchY ) then 
		ActivePanel:Dock( FILL )
	else
		ActivePanel:CenterVertical()
	end
	
	ActivePanel:InvalidateLayout()

	-- Give the animation a chance
	self.animFade:Run()
end
derma.DefineControl( "DInventoryPropertySheet", "", PANEL, "DPropertySheet" )