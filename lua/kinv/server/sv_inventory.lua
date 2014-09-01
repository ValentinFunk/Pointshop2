local Inventory = KInventory.Inventory
local Item = KInventory.Item

function Inventory:loadItems( )
	local def = Deferred( )
	if not self.id then
		def:Reject( 1, "Inventory without ID given to loadItems()" )
		return
	end
	
	self.Items = {}
	Item.findAllByInventory_id( self.id )
	:Then( function( items )
		for k, item in pairs( items ) do
			item.owner = self:getOwner()
			table.insert( self.Items, item )
		end
	end )
	:Done( function( )
		def:Resolve( self )
	end )
	:Fail( function( errid, error )
		def:Reject( 0, "Error loading items: child returned " .. error .. "(" .. errid .. ")" )
	end )
	
	return def:Promise( )
end

function Inventory:addItem( item )
	local def = Deferred( )
	
	DATABASES[Inventory.DB].DoQuery( "SELECT COUNT(*) as numItems FROM " .. Inventory.model.tableName .. " WHERE ownerId =" .. self.ownerId )
	:Then( function( data )
		if data[1].numItems + 1 > self.numSlots then
			local def = Deferred( )
			def:Reject( 1, "No space in inventory" )
		end

		--Save in DB
		item.inventory_id = self.id
		return item:save( )
	end )
	:Then( function( item )
		--reflect changes in cached inventory
		if self.Items then
			table.insert( self.Items, item )
		end
		
		item.owner = self:getOwner()
		
		--Network change
		InventoryController:getInstance( ):itemAdded( self, item )
		
		def:Resolve( self, item )
	end, function( errid, err )
		def:Reject( errid, err )
	end )
	
	return def:Promise( )
end

/*
	Unlink from this inventory, does NOT remove the item from the db
*/
function Inventory:removeItem( item )
	local def = Deferred( )
	print( "Inventory:removeItem( " .. tostring( item ) .. ")" )
	
	local itemKey = false
	for k, v in pairs( self.Items ) do
		if v.id == item.id then
			itemKey = k
		end
	end
	if not itemKey then
		def:Reject( -1, "Item " .. item.id .. " is not part of the Inventory" )
		return def:Promise( )
	end
	
	--Save in DB
	item.inventory_id = nil
	item:save( )
	:Then( function( item )
		table.remove( self.Items, itemKey )
		
		--Network change
		InventoryController:getInstance( ):itemRemoved( self, item )
		
		def:Resolve( self, item )
	end, 
	function( errid, err )
		def:Reject( 0, "Error saving item: " .. err .. "(" .. errid .. ")" )
	end )
	return def:Promise( )
end