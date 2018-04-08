local Inventory = KInventory.Inventory

function Inventory:addItem( item )
	table.insert( self.Items, item )
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

	return removed
end
