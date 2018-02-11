local PANEL = {}

PANEL.addFormItem = DItemCreator_Stage.addFormItem
PANEL.addSectionTitle = DItemCreator_Stage.addSectionTitle

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	DItemCreator_Stage.Init( self ) --poor man's multiple inheritance
	
	self:SetTitle( "Create a Pointshop Item" )
	self:SetSize( 410, 308 )
	
	self.loadingNotifier = vgui.Create( "DLoadingNotifier", self )
	self.loadingNotifier:Dock( TOP )
	
	self:addSectionTitle( "Basic Settings" )
	
	self.buttonBar = vgui.Create( "DIconLayout", self )
	self.buttonBar:SetBorder( 5 )
	self.buttonBar:SetSpaceX( 5 )
	self.buttonBar:DockMargin( 0, 0, 0, 5 )
	
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
		panel.checkBox:SetValue( false )
		
		function panel:GetPrice( )
			if self.wang:GetDisabled( ) then
				return nil
			end
			return self.wang:GetValue( )
		end
		
		function panel:SetPrice( price )
			self.checkBox:SetValue( price != nil )
			if price then
				self.wang:SetMax( price )
				self.wang:SetValue( price )
			end
		end
		
		function panel:IsEnabled( )
			return self.checkBox:GetValue( )
		end

		panel:SetMouseInputEnabled(true)
		local checkboxRealDoClick = panel.checkBox.DoClick
		function panel.OnMousePressed( _panel, mcode )
			if mcode == MOUSE_LEFT then
				checkboxRealDoClick(panel.checkBox)
				panel.wang:RequestFocus()
				if panel.wang:GetValue() == 0 then
					panel.wang:SetText("")
				end
			end
		end
		panel.checkBox.DoClick = function()
			checkboxRealDoClick(panel.checkBox)
			panel.wang:RequestFocus()
			if panel.wang:GetValue() == 0 then
				panel.wang:SetText("")
			end
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
		local succ, err = frame:Validate( saveTable )
		if not succ then
			return Derma_Message( err, "Error" )
		end
		Pointshop2View:getInstance( ):createPointshopItem( saveTable )
		frame:Close( )
		
		if not frame.persistenceId and not frame.targetCategoryId then
			Derma_Message( "The item has been created. To put it up for sale go to Manage Items and move it from uncategorized items into a category", "Information" )
		end
	end
end

function PANEL:SetItemBase( itembase )
	self.itembase = itembase
end

function PANEL:addFormButton( btn )
	btn:SetParent( self.buttonBar )
	return btn
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
		v:InvalidateLayout( true )
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

function PANEL:NotifyLoading( bIsLoading )
	if bIsLoading then
		self.loadingNotifier:Expand( )
		self:SetDisabled( true )
	else
		self.loadingNotifier:Collapse( )
		self:SetDisabled( false )
	end
end

/*
	Called after save table generation to validate the created
	table against errors
*/
function PANEL:Validate( saveTable )
	if #saveTable.name == 0 then
		return false, "Please specify a name"
	end
	
	if not saveTable.price and not saveTable.pricePremium then
		return false, "Please add at least one price"
	end
	
	return true
end

/*
	Generate a table that is sent to the server, then passed to 
	the persistence model for saving
*/
function PANEL:SaveItem( saveTable )
	saveTable.name = self.itemNameTextbox:GetText( )
	saveTable.description = self.descriptionBox:GetText( )
	saveTable.price = self.normalPrice:GetPrice( )
	saveTable.pricePremium = self.pricePremium:GetPrice( )
	saveTable.baseClass = self.itembase
	
	saveTable.persistenceId = self.persistenceId
	saveTable.targetCategoryId = self.targetCategoryId
end

/*
	Load a persistence model for editing. Can also access the
	item class for convenience
*/
function PANEL:EditItem( persistence, itemClass )
	self.itembase = persistence.baseClass
	self.persistenceId = persistence.id
	
	self.itemNameTextbox:SetText( persistence.name )
	self.descriptionBox:SetText( persistence.description )
	self.normalPrice:SetPrice( persistence.price )
	self.pricePremium:SetPrice( persistence.pricePremium )
end

function PANEL:SetTargetCategoryId( categoryId )
	self.targetCategoryId = categoryId
end

vgui.Register( "DItemCreator", PANEL, "DFrame" )