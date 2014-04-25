Pointshop2.EquipmentSlot = class( "Pointshop2.EquipmentSlot" )
local EquipmentSlot = Pointshop2.EquipmentSlot 

EquipmentSlot.static.DB = "Pointshop2"

EquipmentSlot.static.model = {
	tableName = "ps2_equipmentslot",
	fields = {
		itemId = "optKey",			--Contained item
		slotName = "string",
		ownerId = "int"			--Owning player id
	},
	belongsTo = {
		Item = {
			class = "KInventory.Item",
			foreignKey = "itemId"
		}
	}
}

EquipmentSlot:include( DatabaseModel )

function EquipmentSlot:removeItem( item )
	local def = Deferred( )
	
	if self.itemId != item.id then
		def:Reject( -1, "Slot doesn't hold this item" )
		return def:Promise( )
	end
	
	self.itemId = nil
	self.Item = nil
	return self:save( )
end