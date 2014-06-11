ITEM.PrintName = "Pointshop Hat Base"
ITEM.baseClass = "base_pointshop_item"

ITEM.outfitId = 0

ITEM.category = "Hats"
ITEM.color = ""

function ITEM:initialize( )
	print( "CONSTRUCT: Item Hat" )
end

/*
	Inventory icon
*/
function ITEM:getIcon( )
	self.icon = vgui.Create( "DPointshopHatInvIcon" )
	self.icon:SetItem( self )
	self.icon:SetSize( 64, 64 )
	return self.icon
end

function ITEM:OnEquip( ply )
end

function ITEM:OnHolster( ply )
end

function ITEM.static:GetPointshopIconControl( )
	return "DPointshopHatIcon"
end

function ITEM.static.getPersistence( )
	return Pointshop2.HatPersistence
end

function ITEM.static.generateFromPersistence( itemTable, persistenceItem )
	ITEM.super.generateFromPersistence( itemTable, persistenceItem.ItemPersistence )
	
	itemTable.outfitId = persistenceItem.outfitId
	itemTable.iconMaterial = persistenceItem.iconMaterial
	itemTable.useMaterialIcon = persistenceItem.useMaterialIcon
end

function ITEM.static.GetPointshopIconDimensions( )
	return 74, 64
end