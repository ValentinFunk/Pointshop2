Pointshop2.ItemFromCategoryFactory = class( "Pointshop2.ItemFromCategoryFactory", Pointshop2.ItemFactory )
local ItemFromCategoryFactory = Pointshop2.ItemFromCategoryFactory

ItemFromCategoryFactory.Name = "Random Item from Category"
ItemFromCategoryFactory.Icon = "pointshop2/favourite2.png"
ItemFromCategoryFactory.Description = "Picks a random item from a shop category."

ItemFromCategoryFactory.Settings = {
	ManualSettings = {
		info = {
			isManualSetting = true,
		},
		CategoryName = { --Can't use ID because it changes
			value = nil,
			type = "string"
		}
	},
	BasicSettings = {
		info = {
			label = "Settings",
		},
		WeightedRandom = {
			label = "Weight item pick chance by price",
			tooltip = "Make more expensive items be picked less frequently than less expensive",
			value = true
		}
	}
}

function ItemFromCategoryFactory:IsValid( )
	local category = Pointshop2.GetCategoryByName( self.settings["ManualSettings.CategoryName"] )
	if not category then
		return false
	end

	if #category.items == 0 then
		return false
	end

	return true
end

/*
	Creates an item as needed
*/
function ItemFromCategoryFactory:CreateItem( temporaryInstance )
	local category = Pointshop2.GetCategoryByName( self.settings["ManualSettings.CategoryName"] )
	if not category then
		return Promise.Reject( "Invalid Category " .. self.settings["ManualSettings.CategoryName"] )
	end

	local sumTbl = {}
	local sum = 0
	for k, v in pairs( category.items ) do
		local weight = 1
		if self.settings["BasicSettings.WeightedRandom"] then
			if v.Price.points then
				weight = v.Price.points
			elseif v.Price.premiumPoints then
				weight = v.Price.premiumPoints * 10
			end
			weight = ( 1 / weight ) * 100
		end

		sum = sum + weight
		table.insert( sumTbl, { sum = sum, itemClass = v } )
	end

	--Pick element
	local r = math.random() * sum
	local itemClass
	for _, info in ipairs( sumTbl ) do
		if info.sum >= r then
			itemClass = info.itemClass
			break
		end
	end

	if not itemClass then

	end

	local item = itemClass:new( )
	return temporaryInstance and item or item:save( )
end

/*
	Name of the control used to configurate this factory
*/
function ItemFromCategoryFactory:GetConfiguratorControl( )
	return "DItemFromCategoryFactoryConfigurator"
end

function ItemFromCategoryFactory:IsValid( )
	local category = Pointshop2.GetCategoryByName( self.settings["ManualSettings.CategoryName"] )
	return category
end

function ItemFromCategoryFactory:GetShortDesc( )
	local category = Pointshop2.GetCategoryByName( self.settings["ManualSettings.CategoryName"] )
	if category then
		return "Random Item: " .. category.label
	else
		return "<Invalid Category " .. self.settings["ManualSettings.CategoryName"] .. ">"
	end
end

Pointshop2.ItemFactory.RegisterFactory( ItemFromCategoryFactory )
