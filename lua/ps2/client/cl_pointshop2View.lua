Pointshop2View = class( "Pointshop2View" )
Pointshop2View.static.controller = "Pointshop2Controller" 
Pointshop2View:include( BaseView )

function Pointshop2View:initialize( )
	--Dynamic Properties
	self.itemMappings = {}
	self.itemCategories = {}
	self.itemProperties = {}
end

function Pointshop2View:receiveDynamicProperties( itemMappings, itemCategories, itemProperties )
	KLogf( 5, "[PS2] Received Dynamic Properties, %i items in %i categories (%i props)", #itemMappings, #itemCategories, #itemProperties )
	self.itemMappings = itemMappings
	self.itemCategories = itemCategories
	self.itemProperties = itemProperties
	
	--Create Tree from the information
	local categoryItemsTable = {}
	for k, dbCategory in pairs( self.itemCategories ) do
		local newCategory = { 
			self = {
				id = dbCategory.id,
				label = dbCategory.label,
				icon = dbCategory.icon
			},
			subcategories = { },
			items = {}
		}
		
		--Fill With items
		for k, dbItemMapping in pairs( self.itemMappings ) do
			if dbItemMapping.categoryId == newCategory.self.id then
				table.insert( newCategory.items, dbItemMapping.itemClass )
				self.itemMappings[k] = nil
			end
		end
		
		--Put it in the right place into the tree
		if not dbCategory.parent then
			--Create Category in root
			categoryItemsTable[newCategory.self.id] = newCategory
		else
			local function findAndAddToParent( tree, parentId, subcategory )
				if tree.self.id ==  parentId then
					tree.subcategories[newCategory.self.id] = subcategory
					return true
				end

				for id, category in pairs( tree.subcategories ) do
					if findAndAddToParent( category, parentId, subcategory ) then
						return true
					end
				end
			end
			for id, rootCategory in pairs( categoryItemsTable ) do
				if findAndAddToParent( rootCategory, dbCategory.parent, newCategory ) then
					break
				end
			end
		end
	end
	self.categoryItemsTable = categoryItemsTable
end

function Pointshop2View:saveCategoryOrganization( categoryItemsTable )
	self:controllerAction( "saveCategoryOrganization", categoryItemsTable )
end

function Pointshop2View:getCategoryOrganization( )
	if not self.categoryItemsTable then
		return KLogf( 2, "[PS2] Couldn't create items table: nothing received from server yet!" )
	end
	
	return self.categoryItemsTable
end

function Pointshop2View:getUncategorizedItems( )
	local uncategorized = {}
	for _, itemClass in pairs( Pointshop2:GetRegisteredItems( ) ) do
		local found = false
		for _, itemMapping in pairs( self.itemMappings ) do
			if itemMapping.itemClass == itemClass then
				found = true
			end
		end
		if not found then 
			print( KInventory.Items[itemClass]  )
			table.insert( uncategorized, KInventory.Items[itemClass] )
		end
	end
	return uncategorized
end