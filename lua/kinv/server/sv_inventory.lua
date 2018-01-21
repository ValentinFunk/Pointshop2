local Inventory = KInventory.Inventory
local Item = KInventory.Item

function Inventory:loadItems( )
	if not self.id then
		GLib.Error( "Inventory without ID given to loadItems()" )
	end
	
	self.Items = {}
	return Item.findAllByInventory_id( self.id )
	:Then( function( items )
		for k, item in pairs( items ) do
			item.owner = self:getOwner()
			table.insert( self.Items, item )
		end
	end )
end

function Inventory:notifyItemAdded( item )
	if not item then
		error('Notified NULL item added')
	end

	if not KInventory.ITEMS[item.id] then
		KInventory.ITEMS[item.id] = item
		Pointshop2.LogCacheEvent('ADD', 'Inventory:addItem', item.id)
	else
		Pointshop2.LogCacheEvent('IGNORE', 'Inventory:addItem', item.id, KInventory.ITEMS[item.id].id)
	end

	--reflect changes in cached inventory
	if self.Items then
		table.insert( self.Items, item )
	end
	
	item.owner = self:getOwner()
	
	--Network change
	InventoryController:getInstance( ):itemAdded( self, item )
end

function Inventory:addItem( item )
	return DATABASES[Inventory.DB].DoQuery( "SELECT COUNT(*) as numItems FROM " .. Inventory.model.tableName .. " WHERE ownerId =" .. self.ownerId )
	:Then( function( data )
		if data[1].numItems + 1 > self.numSlots then
			return Promise.Reject( "No space in inventory" )
		end

		--Save in DB
		item.inventory_id = self.id
		return item:save( )
	end )
	:Then( function( item )
		self:notifyItemAdded( item )
	end )
end

/*
	Notify the inv that an item was removed externally
*/
function Inventory:notifyItemRemoved(itemId)
	local itemKey = false
	for k, v in pairs( self.Items ) do
		if v.id == itemId then
			itemKey = k
		end
	end
	if not itemKey then
		LibK.GLib.Error("Inventory:notifyItemRemoved - Item not in inventory")
	end

	table.remove( self.Items, itemKey )

	--Network change
	InventoryController:getInstance( ):itemRemoved( self, itemId )
end

/*
	Unlink from this inventory, does NOT remove the item from the db
*/
function Inventory:removeItem( item )
	KLogf( 4, "Inventory:removeItem( " .. tostring( item ) .. ")" )
	
	--Save in DB
	item.inventory_id = nil
	return item:save( )
	:Then( function( item )
		self:notifyItemRemoved(item.id)
		return item
	end, function( err )
		return Promise.Reject("Error saving item: " .. err )
	end )
end