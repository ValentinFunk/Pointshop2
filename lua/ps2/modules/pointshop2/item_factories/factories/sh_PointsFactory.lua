Pointshop2.PointsFactory = class( "Pointshop2.PointsFactory", Pointshop2.ItemFactory )
local PointsFactory = Pointshop2.PointsFactory

PointsFactory.Name = "Points"
PointsFactory.Icon = "pointshop2/hand129.png"
PointsFactory.Description = "Creates an item that can be redeemed for a certain amount of points or premium points."

PointsFactory.Settings = {
	BasicSettings = {
		info = {
			label = "Points Settings",
		},
		CurrencyType = {
			value = "points",
			possibleValues = {
				"points",
				"premiumPoints",
			},
			type = "option",
			label = "Currency Type",
			tooltip = "Currency of the points given to the user"
		},
		Amount = {
			label = "Amount Given",
			tooltip = "Amount of the currency that the item given holds",
			value = 100
		}
	}
}

/*
	Creates an item as needed
*/
function PointsFactory:CreateItem( )
	local item = Pointshop2.GetItemClassByName( "base_points" ):new( )
	item.amount = self.settings["BasicSettings.Amount"]
	item.currencyType = self.settings["BasicSettings.CurrencyType"]
	return item:save( )
	:Then( function( item )
		return item
	end )
end

/*
	Name of the control used to configurate this factory
*/
function PointsFactory:GetConfiguratorControl( )
	return "DPointsFactoryConfigurator"
end

function PointsFactory:GetShortDesc( )
	local currencyStr
	if self.settings["BasicSettings.CurrencyType"] == "points" then
		currencyStr = "Points"
		self.material = "pointshop2/dollar103.png"
	else
		currencyStr = "Premium Points"
		self.material = "pointshop2/donation.png"
	end
	return currencyStr .. ": " .. self.settings["BasicSettings.Amount"] 
end

Pointshop2.ItemFactory.RegisterFactory( PointsFactory )