local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self.items = {}
end

function PANEL:addFormItem( desc, panel )
	local container = vgui.Create( "DPanel", self )
	container:Dock( TOP )
	container:DockMargin( 5, 5, 5, 5 )
	function container:PerformLayout( )
		self:SizeToChildren( false, true )
	end
	function container:Paint( ) end
	
	local label = vgui.Create( "DLabel", container )
	label:SetText( desc .. ":" )
	label:Dock( LEFT )
	label:SizeToContents( )
	label:DockMargin( 0, 0, 5, 0 )
	container.label = label
	
	function container:GetLabelWidth( )
		return label:GetWide( )
	end
	
	function container:SetLabelWidth( w )
		label:SetWide( w )
	end
	
	panel:SetParent( container )
	panel:Dock( LEFT )
	container.panel = panel
	
	table.insert( self.items, container )
	
	return container
end

function PANEL:addSectionTitle( text )
	local title = vgui.Create( "DLabel", self )
	title:Dock( TOP )
	title:SetFont( self:GetSkin().SmallTitleFont )
	title:SetColor( self:GetSkin().Colours.Label.Bright )
	title:SetText( text ) 
	title:SizeToContents( )
	title:DockMargin( 5, 5, 5, 10 )
end

function PANEL:PerformLayout( )
	local maxW = 0
	for k, v in pairs( self.items ) do
		if v:GetLabelWidth( ) > maxW then
			maxW = v:GetLabelWidth( )
		end
	end
	
	for k, v in pairs( self.items ) do
		v:SetLabelWidth( maxW )
	end
	
	local maxY = 0
	for k, v in pairs( self:GetChildren( ) ) do
		local x, y = v:GetPos( )
		v:InvalidateLayout( true )
		local endPos = y + v:GetTall( )
		if endPos > maxY and v != self.buttonBar then
			maxY = endPos
		end
	end
	maxY = maxY + 5 --margin

	self:SetTall( maxY + 0 )
end

function PANEL:NotifyLoading( bIsLoading )
	self:GetParent( ):NotifyLoading( bIsLoading )
end

derma.DefineControl( "DItemCreator_Stage", "Base for a item creator stage (step)", PANEL, "DPanel" )