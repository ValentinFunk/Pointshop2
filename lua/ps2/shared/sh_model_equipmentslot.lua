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
			foreignKey = "itemId",
			onDelete = "SET NULL"
		},
		/*Owner = {
			class = "LibK.Player",
			foreignKey = "ownerId"
		}*/
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

function EquipmentSlot:getOwner( )
	for k, v in pairs( player.GetAll( ) ) do
		if tonumber( v:GetNWInt( "KPlayerId" ) ) == self.ownerId or 
			tonumber( v.kPlayerId or -1 ) == self.ownerId then
			return v
		end
	end
end

function EquipmentSlot:postLoad( )
	local def = Deferred( )
	
	if self.Item then
		self.Item.owner = self:getOwner( )
	end
	
	def:Resolve( )
	return def:Promise( )
end