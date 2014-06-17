ITEM.PrintName = "Pointshop Hat Base"
ITEM.baseClass = "base_pointshop_item"

ITEM.static.outfitIds = {} --Model -> Outfit ID map
ITEM.static.iconViewInfo = {} --Table: fov, angles, origin used for preview rendering

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

/*
	Creates a new class that inherits this base
*/
function ITEM.static.generateFromPersistence( itemTable, persistenceItem )
	ITEM.super.generateFromPersistence( itemTable, persistenceItem.ItemPersistence )
	itemTable.static.iconViewInfo = persistenceItem.iconViewInfo
	itemTable.static.useMaterialIcon = persistenceItem.useMaterialIcon
	itemTable.static.iconMaterial = persistenceItem.iconMaterial
	itemTable.static.slotType = persistenceItem.slotType
	itemTable.static.outfitIds = {}
	for k, mapping in pairs( persistenceItem.OutfitHatPersistenceMapping ) do
		itemTable.static.outfitIds[mapping.model] = mapping.outfitId
	end
	function itemTable.static.getBaseOutfit( )
		local outfitId = itemTable.outfitIds[Pointshop2.HatPersistence.ALL_MODELS]
		return Pointshop2.Outfits[outfitId]
	end
	function itemTable.static.getSlotType( )
		return itemTable.static.slotType
	end
end

function ITEM.static.GetPointshopIconDimensions( )
	return 108, 128
end