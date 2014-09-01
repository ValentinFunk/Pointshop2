--Indicates that this item base is statically lua defined and not loaded from a 
--persistence. This means that it cannot be edited dynamically
ITEM.static._persistenceId = "STATIC" 

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
	return math.floor( self.class.Price.points * Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.SellRatio" ) )
end

function ITEM:CanBeSold( )
	if self.class.Price.points then
		return true	
	end
	if self.class.Price.premiumPoints then
		if Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.AllowPremptsSale" ) then
			return true	
		end
	end
	return false
end

function ITEM:OnPurchased( ply )

end

-- [TODO add to editor] -> Done for Hat 
function ITEM:CanBeEquipedInSlot( slotName )
	return false
end

function ITEM:OnSold( ply )

end

function ITEM:CanBeTraded( receivingPly )

end

function ITEM:OnEquip( ply )

end

function ITEM:OnHolster( ply )

end

if SERVER then
	/*
		Calls the item function on the client
	*/
	function ITEM:ClientRPC( funcName, ... )
		Pointshop2.ItemClientRPC( self, funcName, ... )
	end
end

--Get the player owner
function ITEM:GetOwner( )
	return self.owner
end

function ITEM.static:GetPointshopIconControl( )
	return "DPointshopItemIcon"
end

function ITEM.static.GetPointshopDescriptionControl( )
	return "DPointshopItemDescription"
end

function ITEM.static:GetPointshopIconDimensions( )
	return Pointshop2.GenerateIconSize( 2, 2 )
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