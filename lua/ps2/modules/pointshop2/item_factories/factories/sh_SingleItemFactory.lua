Pointshop2.SingleItemFactory = class( "Pointshop2.SingleItemFactory", Pointshop2.ItemFactory )
local SingleItemFactory = Pointshop2.SingleItemFactory

SingleItemFactory.Name = "Item"
SingleItemFactory.Icon = "pointshop2/cowboy5.png"
SingleItemFactory.Description = "Pick a single item from the shop."

SingleItemFactory.Settings = {
	BasicSettings = {
		info = {
			label = "Item Settings",
		},
		ItemClass = ""
	}
}

/*
	Creates an item as needed
*/
function SingleItemFactory:CreateItem( temporaryInstance )
	local class = Pointshop2.GetItemClassByName( self.settings["BasicSettings.ItemClass"] )
	if not class then
		return Promise.Reject( "Invalid item class " .. self.settings["BasicSettings.ItemClass"] )
	end

	local item = class:new( )
	return temporaryInstance and item or item:save( )
end

function SingleItemFactory:GetChanceTable( )
	local itemClass = Pointshop2.GetItemClassByName( self.settings["BasicSettings.ItemClass"] )
	if not itemClass then
		error( "Invalid item class " .. self.settings["BasicSettings.ItemClass"] )
	end

	return {
		{ chance = 1, itemOrInfo = itemClass }
	}
end

function SingleItemFactory:IsValid( )
	local class = Pointshop2.GetItemClassByName( self.settings["BasicSettings.ItemClass"] )
	return class != nil
end

/*
	Name of the control used to configurate this factory
*/
function SingleItemFactory:GetConfiguratorControl( )
	return "DSingleItemFactoryConfigurator"
end

function SingleItemFactory:GetShortDesc( )
	local class = Pointshop2.GetItemClassByName( self.settings["BasicSettings.ItemClass"] )
	if not class then
		return "<Invalid Item>"
	end
	return class.PrintName
end

Pointshop2.ItemFactory.RegisterFactory( SingleItemFactory )
