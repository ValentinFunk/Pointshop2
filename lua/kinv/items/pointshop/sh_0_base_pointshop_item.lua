ITEM.PrintName = "Pointshop Item Base"
ITEM.Material = "materials/error"
ITEM.Description = "Pointshop Item Base"

ITEM.static.Price = {
	points = 1,
	premiumPoints = 1
}

function ITEM.static:GetBuyPrice( ply )
	return { 
		points = self.Price.points,
		premiumPoints = self.Price.premiumPoints 
	}
end

function ITEM:GetSellPrice( ply )
	return self.class.Price.points * 0.75
end

--TODO add to editor
function ITEM:CanBeSold( )
	return self.class.Price.points != nil
end

function ITEM:OnPurchased( ply )

end

--TODO add to editor
function ITEM:CanBeEquipedInSlot( slotName )
	return false
end

function ITEM:OnSold( )

end

function ITEM:CanBeTraded( receivingPly )

end

function ITEM:OnEquip( ply )

end

function ITEM:OnHolster( ply )

end

function ITEM.static:GetPointshopIconControl( )
	return "DPointshopItemIcon"
end

function ITEM.static.GetPointshopDescriptionControl( )
	return "DPointshopItemDescription"
end

function ITEM.static:GetPointshopIconDimensions( )
	return 100, 100
end

/*
	This function is called to populate the itemTable (a new class which inherits the BaseClass from persistanceItem).
	Should be overwritten and called by any other item bases.
*/
function ITEM.static.generateFromPersistence( itemTable, persistenceItem )
	itemTable.static.Price = {
		points = persistenceItem.price,
		premiumPoints = persistenceItem.pricePremium,
	}
	itemTable.Ranks = persistenceItem.ranks
	itemTable.PrintName = persistenceItem.name
	itemTable.Description = persistenceItem.description
end

/*
	Inventory Icon control
*/
function ITEM:getIcon( )
	self.icon = vgui.Create( "DPointshopInventoryItemIcon" )
	self.icon:SetItem( self )
	self.icon.Paint = function( _, w, h )
		surface.SetDrawColor( 255, 0, 0 )
		surface.DrawRect( 0, 0, w, h )
	end
	return self.icon
end