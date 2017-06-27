KInventory.ITEMS = {}
setmetatable(KInventory.ITEMS, { __mode = 'v' }) --weak table, allow collection if not referenced anywhere else

local Item = class( "KInventory.Item" )
KInventory.Item = Item

Item.static.DB = "Pointshop2"
Item.static.printName = "Basic Item"
Item.static.description = { "This is a basic item." }
Item.static.droppable = true
Item.static.usable = false
Item.static.stackCount = 1
Item.static.validModifiers = 0
Item.static.category = "Misc"
Item.static.iconModel = "models/props/cs_office/cardboard_box03.mdl"
Item.static.worldModel = "models/props/cs_office/cardboard_box03.mdl"
Item.static.weight = 0

Item.static.model = {
	tableName = "kinv_items",
	fields = {
		itemclass = "classname",
		itempersistence_id = "optKey",
		inventory_id = "optKey", --optional foreign key, if this doesnt exist item is dropped
		data = "table" --Table is a special field, saves all instance vars that weren't saved already
	},
	belongsTo = {
		Inventory = {
			class = "KInventory.Inventory",
			foreignKey = "inventory_id",
			onDelete = "CASCADE"
		},
		ItemPersistence = {
			class = "Pointshop2.ItemPersistence",
			foreignKey = "itempersistence_id",
			onDelete = "CASCADE"
		}
	}
}
Item:include( DatabaseModel )

function Item:postLoad( )
	local def = Deferred( )

	--i know this is disgusting :( a possible alternative would be no relationships
	local cached = KInventory.ITEMS[self.id]
	if cached then
		for k, v in pairs( self ) do
			if not cached[k] then
				cached[k] = self
			end
		end
	else
		KInventory.ITEMS[self.id] = self
	end


	local inv = KInventory.INVENTORIES[self.inventory_id]
	if inv then
		self.owner = inv:getOwner( )
	end

	def:Resolve( )
	return def:Promise( )
end

function Item:getWeight( )
	return self.weight or self.class.weight
end

function Item:getWorldModel( )
	return self.worldModel or self.class.worldModel
end

function Item:getIconControl( )
	return "DItemIcon"
end

-- Pre save we make sure to update the itempersistence_id field which is
-- directly linked to the item persistence constraint of Pointshop 2
-- to prevent DB corruption
function Item:preSave()
	if self.class._persistenceId != "STATIC" then
		self.itempersistence_id = self.class.className
	end
	return Promise.Resolve()
end