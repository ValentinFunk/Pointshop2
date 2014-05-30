local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self:SetTitle( "Create a Pointshop Item" )
	self:SetSize( 410, 308 )
	
	self:addSectionTitle( "Basic Settings" )
	
	self.buttonBar = vgui.Create( "DIconLayout", self )
	self.buttonBar:SetBorder( 5 )
	self.buttonBar:SetSpaceX( 5 )
	self.buttonBar:DockMargin( 0, 0, 0, 5 )
	
	self.items = {}
	
	self.itemNameTextbox = vgui.Create( "DTextEntry", self )
	self.itemNameTextbox:SetWide( 400 )
	self:addFormItem( "Item Name", self.itemNameTextbox )
	
	self.descriptionBox = vgui.Create( "DTextEntry", self )
	self.descriptionBox:SetMultiline( true )
	self.descriptionBox:SetWide( 400 )
	local item = self:addFormItem( "Description", self.descriptionBox )
	item:SetTall( 100 )
	item.label:SetContentAlignment( 7 )
	item.label:DockMargin( 0, 0, 5, 0 )
	
	local priceBox = vgui.Create( "DPanel", self )
	priceBox:Dock( TOP )
	priceBox:SetTall( 65 )
	function priceBox:Paint( ) end
	local function createCheckboxedPriceInput( label )
		local panel = vgui.Create( "DPanel", priceBox )
		panel:DockMargin( 5, 5, 5, 5 )
		panel:Dock( TOP )
		function panel:Paint( w, h ) end
		function panel:PerformLayout( )
			self.checkBox:SetPos( 0, 0 )
			self.label:SetPos( self.checkBox:GetWide( ) + 5 )
			self.wang:SetPos( 100, 0 )
			
			self:SizeToChildren( false, true )
		end
		
		panel.checkBox = vgui.Create( "DCheckBox", panel )
		function panel.checkBox:OnChange( )
			panel.label:SetDisabled( not self:GetChecked( ) )
			panel.wang:SetDisabled( not self:GetChecked( ) )
		end
		
		panel.label = vgui.Create( "DLabel", panel )
		panel.label:SetText( label )
		panel.label:SizeToContents( )
		
		panel.wang = vgui.Create( "DNumberWang", panel )
		panel.checkBox:SetValue( true )
		
		function panel:GetPrice( )
			if self.wang:GetDisabled( ) then
				return nil
			end
			return self.wang:GetValue( )
		end
		
		function panel:IsEnabled( )
			return self.checkbox:GetValue( )
		end
		
		return panel
	end
	
	self.normalPrice = createCheckboxedPriceInput( "Points" )
	self.pricePremium = createCheckboxedPriceInput( "Donator Points" )
	
	self.saveButton = self:addFormButton( vgui.Create( "DButton", self ) )
	self.saveButton:SetText( "Save Item" )
	self.saveButton:SetSize( 80, 25 )
	self.saveButton:PerformLayout( )
	self.saveButton:Paint( 10, 10 )
	
	local frame = self
	function self.saveButton:DoClick( )
		local saveTable = { }
		frame:SaveItem( saveTable )
		Pointshop2View:getInstance( ):createPointshopItem( saveTable )
		frame:Close( )
	end
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