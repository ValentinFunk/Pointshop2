ITEM.PrintName = "Pointshop Item Base"
ITEM.Material = "materials/error"

ITEM.Price = {
	DonorPoints = 1,
	Points = 1
}


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

function ITEM.static:GetPointshopIconDimensions( )
	return 128, 128
end