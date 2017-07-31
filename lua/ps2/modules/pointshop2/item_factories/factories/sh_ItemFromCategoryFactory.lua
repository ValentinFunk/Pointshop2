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

function ItemFromCategoryFactory:GetChanceTable( )
	local category = Pointshop2.GetCategoryByName( self.settings["ManualSettings.CategoryName"] )
	if not category then
		LibK.GLib.Error( "Invalid Category " .. self.settings["ManualSettings.CategoryName"] )
	end

	local weightedChances = {}
	local sum = 0
	for k, itemClass in ipairs( category.items ) do
		local weight = 1
		if self.settings["BasicSettings.WeightedRandom"] then
			if itemClass.Price.points then
				weight = math.max(itemClass.Price.points, 1)
			elseif itemClass.Price.premiumPoints then
				weight = math.max(itemClass.Price.premiumPoints * 10, 1)
			end
			weight = ( 1 / weight ) * 100
		end

		table.insert(weightedChances, {chance = weight, itemOrInfo = itemClass})
	end

	return weightedChances
end

/*
	Creates an item as needed
*/
function ItemFromCategoryFactory:CreateItem( temporaryInstance )
	local sumTbl = {}
	local sum = 0
	for _, info in pairs( self:GetChanceTable() ) do
		sum = sum + info.chance
		table.insert( sumTbl, { sum = sum, itemClass = info.itemOrInfo } )
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
		LibK.GLib.Error("Crate could not create item, invalid state" )
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
