ITEM.PrintName = "Pointshop Playermodel Base"
ITEM.baseClass = "base_pointshop_item"

ITEM.material = ""

ITEM.category = "Trails"
ITEM.color = ""

function ITEM:initialize( )
	print( "CONSTRUCT: Item Trail" )
end

/*
	Inventory icon
*/
function ITEM:getIcon( )
	self.icon = vgui.Create( "DPointshopTrailInvIcon" )
	self.icon:SetItem( self )
	self.icon:SetSize( 64, 64 )
	return self.icon
end

function ITEM:OnEquip( ply )
	if SERVER then
		self.trailEnt = util.SpriteTrail( ply, 0, self.color, false, 15, 1, 4, 0.125, self.material .. ".vmt" )
	end
	print( "Trail: OnEquip", self.trailEnt )
end

function ITEM:OnHolster( ply )
	print( "Trail: OnHolster", self.trailEnt )
	if SERVER then
		SafeRemoveEntity( self.trailEnt )
	end
end

function ITEM.static:GetPointshopIconControl( )
	return "DPointshopTrailIcon"
end

function ITEM.static.getPersistence( )
	return Pointshop2.TrailPersistence
end

function ITEM.static.generateFromPersistence( itemTable, persistenceItem )
	ITEM.super.generateFromPersistence( itemTable, persistenceItem.ItemPersistence )
	itemTable.material = persistenceItem.material
end

function ITEM.static.GetPointshopIconDimensions( )
	return 74, 64
end