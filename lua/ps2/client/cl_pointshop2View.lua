Pointshop2View = class( "Pointshop2View" )
InventoryView.static.controller = "Pointshop2Controller" 
Pointshop2View:include( BaseView )

function Pointshop2View:initialize( )
	--Dynamic Properties
	self.itemMappings = {}
	self.itemCategories = {}
	self.itemProperties = {}
end

function Pointshop2View:receiveDynamicProperties( itemMappings, itemCategories, itemProperties )
	self.itemMappings = itemMappings
	self.itemCategories = itemCategories
	self.itemProperties = itemProperties
end

function Pointshop2View:saveCategoryOrganization( categoryItemsTable )
	self:controllerAction( "saveCategoryOrganization", categoryItemsTable )
end