KInventory.INVENTORIES = {}
setmetatable(KInventory.INVENTORIES, { __mode = 'v' }) --weak table, allow collection if not referenced anywhere else

local Inventory = class( "KInventory.Inventory" )
KInventory.Inventory = Inventory

Inventory.static.DB = "Pointshop2"
Inventory.static.model = {
	tableName = "inventories",
	fields = {
		ownerId = "int",
		numSlots = "int",
		parentInventory = "optKey" --INT(11), optional foreign key
	},
	/*hasMany = {
		Items = {
			class = "KInventory.Item",
			foreignKey = "inventory_id"
		},
	},*/
	belongsTo = {
		ParentInventory = {
			class = "KInventory.Inventory",
			foreignKey = "parentInventory"
		}
	}
}
Inventory:include( DatabaseModel )

function Inventory:postLoad( )
	local def = Deferred( )
	
	KInventory.INVENTORIES[self.id] = self
	
	def:Resolve( )
	return def:Promise( )
end

function Inventory:getWeight( )
	local weight = 0
	for k, v in pairs( self.Items ) do
		weight = weight + v:getWeight( )
	end
	return weight
end

function Inventory:getOwner( )
	for k, v in pairs( player.GetAll( ) ) do
		if tonumber( v:GetNWInt( "KPlayerId" ) ) == self.ownerId then
			return v
		end
	end
end


function Inventory:getItems( )
	return self.Items
end

function Inventory:containsItem( item )
	for k, v in pairs( self.Items ) do
		if v.id == item.id then
			return true
		end
	end
	return false
end

function Inventory:getNumSlots( )
	return self.numSlots
end