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

function ITEM.static:GetSellPrice( )
	return ITEM.Price.points * 0.75
end

function ITEM:CanBeSold( )
	return true
end

function ITEM:OnPurchased( )

end

function ITEM:OnSold( )

end

function ITEM:CanBeTraded( receivingPly )

end

function ITEM:OnEquip( )

end

function ITEM:OnHolster( )

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
	print( "added persistence: ", persistenceItem.price, persistenceItem.pricePremium )
	PrintTable( itemTable )
	itemTable.Ranks = persistenceItem.ranks
	itemTable.PrintName = persistenceItem.name
	itemTable.Description = persistenceItem.description
end