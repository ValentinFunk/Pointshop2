local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self:SetTitle( "Item added" )
	self:SetSize( 410, 308 )
	
	self.lbl = vgui.Create( "DLabel", self )
	self.lbl:SetText( "An item was added to your inventory" )
	self.lbl:Dock( TOP )
	
	
end

function PANEL:SetItemBase( itembase )
	self.itembase = itembase
end

function PANEL:SaveItem( saveTable )
	saveTable.name = self.itemNameTextbox:GetText( )
	saveTable.description = self.descriptionBox:GetText( )
	saveTable.price = self.normalPrice:GetPrice( )
	saveTable.pricePremium = self.pricePremium:GetPrice( )
	saveTable.baseClass = self.itembase
end

function PANEL:addFormButton( btn )
	btn:SetParent( self.buttonBar )
	return btn
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

function PANEL:PerformLayout( )
	DFrame.PerformLayout( self )
	
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
		local endPos = y + v:GetTall( )
		if endPos > maxY and v != self.buttonBar then
			maxY = endPos
		end
	end
	maxY = maxY + 5 --margin
	
	self.buttonBar:SetPos( 5, maxY )
	self.buttonBar:SetTall( 25 )
	self.buttonBar:SetWide( self:GetWide( ) - 10 )
	
	self:SetTall( maxY + self.buttonBar:GetTall( ) + 15 )
end

vgui.Register( "DItemCreator", PANEL, "DFrame" )