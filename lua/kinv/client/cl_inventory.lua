local Inventory = KInventory.Inventory

function Inventory:addItem( item )
	--if it exists, remove before readding
	self:removeItem( item )
	table.insert( self.Items, item )
	hook.Run( "KInv_ItemAdded", self, item )
end

function Inventory:removeItem( item )
	return self:removeItemById( item.id )
end

function Inventory:removeItemById( itemId )
	local removed = false
	for k, v in pairs( self.Items ) do
		if v.id == itemId then
			table.remove( self.Items, k )
			removed = true
		end
	end
	
	if removed then
		hook.Run( "KInv_ItemRemoved", self, itemId )
		--do callback stuff
	end
	
	return removed
end