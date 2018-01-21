local PANEL = {}

function PANEL:Init( )
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
end

/*
	Load a persistence model for editing. Can also access the
	item class for convenience
*/
function PANEL:EditItem( persistence, itemClass )
	local persistence = persistence.ItemPersistence
	
	self.itembase = persistence.baseClass
	self.persistenceId = persistence.id
	
	self.itemNameTextbox:SetText( persistence.name )
	self.descriptionBox:SetText( persistence.description )
	self.normalPrice:SetPrice( persistence.price )
	self.pricePremium:SetPrice( persistence.pricePremium )
end

function PANEL:SetItemBase( itembase )
	self.itembase = itembase
end

function PANEL:Paint( )

end

vgui.Register( "DItemCreator_BasicSettings", PANEL, "DItemCreator_Stage" )