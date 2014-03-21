Pointshop2 = {}

function Pointshop2:LoadCategorySettings( )

end

--Find all registered items that use the pointshop base
function Pointshop2:GetRegisteredItems( )
	local pointshopItems = {}
	for className, itemClass in pairs( KInventory.Items ) do
		if subclassOf( KInventory.Items.base_pointshop_item, itemClass ) then
			if itemClass.isBase then 
				continue
			end
			
			table.insert( pointshopItems, itemClass )
		end
	end
	return pointshopItems
end

function Pointshop2:GetUncategorizedItems( )
	return Pointshop2:GetRegisteredItems( )
end