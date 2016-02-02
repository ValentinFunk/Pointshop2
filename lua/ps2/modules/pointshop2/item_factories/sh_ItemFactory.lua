Pointshop2.ItemFactory = class( "Pointshop2.ItemFactory" )
local ItemFactory = Pointshop2.ItemFactory

ItemFactory.static.Factories = {}

function ItemFactory.static.RegisterFactory( itemFactory )
	if not subclassOf( ItemFactory, itemFactory ) then
		KLogf( 2, "[ERROR] Invalid Item Factory registered!" )
		error( "Invalid itemFactory passed to ItemFactory.RegisterFactory: Does not inherit ItemFactory", 1 )
	end

	table.insert( ItemFactory.static.Factories, itemFactory )
end

function ItemFactory.static.GetItemFactories( )
	return ItemFactory.static.Factories
end

ItemFactory.static.Name = "Base Item Factory"
ItemFactory.static.Icon = "error"
ItemFactory.static.Description = "Short description of what it does"

-- Pointshop 2 Settings table
ItemFactory.static.Settings = {}

/*
	Name of the control used to configurate this factory
*/
function ItemFactory.static.GetConfiguratorControl( )
	return "DItemFactoryConfigurator"
end

/*
	Settings have been loaded
*/
function ItemFactory:SetLoadedSettings( settings )
	self.settings = settings
end

/*
	Short name as shown in lists
*/
function ItemFactory:GetShortDesc( )
	return "[ERROR]"
end

/*
	Runtime check: is the factory valid? Can the item still be created?
*/
function ItemFactory:IsValid( )
	return true
end

/*
	Returns instance settings table
*/
function ItemFactory:GetLoadedSettings( )
	return self.settings
end

/*
	Creates an item as needed
*/
function ItemFactory:CreateItem( saveToDb )
	error( "Virtual function call" )
end
