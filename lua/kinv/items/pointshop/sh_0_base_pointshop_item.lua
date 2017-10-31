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

ITEM.static.Servers = {
}

ITEM.static.Ranks = {
}

function ITEM:GetPrintName( )
	return self.PrintName
end

function ITEM:GetDescription( )
	return self.Description
end

--CTOR
function ITEM:initialize(id)
	--Fields that are JSON saved for each item
	self.saveFields = self.saveFields or {}
	table.insert(self.saveFields, "purchaseData" )
end

function ITEM.static:GetBuyPrice( ply )
	return {
		points = self.Price.points,
		premiumPoints = self.Price.premiumPoints
	}
end

function ITEM:isPremiumItem( )
	return not self.Price.points and self.Price.premiumPoints
end

function ITEM:GetSellPrice( ply )
	--New way
	if self.purchaseData then
		self.purchaseData.amount = self.purchaseData.amount or 0
		self.purchaseData.currency = self.purchaseData.currency or "points"
		return math.floor( self.purchaseData.amount * Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.SellRatio" ) ), self.purchaseData.currency
	end

	--Legacy way
	if self.class.Price.points then
		return math.floor( self.class.Price.points * Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.SellRatio" ) ), "points"
	elseif self.class.Price.premiumPoints then
		return math.floor( self.class.Price.premiumPoints * Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.SellRatio" ) ), "premiumPoints"
	end
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

-- Allow server method to be called by clients.
ITEM.static.RPCMethods = { Hi = true }
function ITEM.static.AllowRPC( rpcFuncName )
		ITEM.static.RPCMethods[rpcFuncName] = true
end

if SERVER then
	/*
		Calls the item function on the client
	*/
	function ITEM:ClientRPC( funcName, ... )
		Pointshop2.ItemClientRPC( self, funcName, ... )
	end
else
	function ITEM:ServerRPC( funcName, ... )
		Pointshop2.ItemServerRPC( self, funcName, ... )
	end
end

--Get the player owner
function ITEM:GetOwner( )
	return self.owner
end

function ITEM.static:GetConfiguredIconControl( )
	if Pointshop2.ClientSettings.GetSetting( "BasicSettings.LowendMode" ) then
		return self:GetPointshopLowendIconControl( )
	else
		return self:GetPointshopIconControl( )
	end
end

function ITEM.static:GetPointshopIconControl( )
	return "DPointshopItemIcon"
end

function ITEM.static:GetPointshopLowendIconControl( )
	return "DPointshopSimpleItemIcon"
end

function ITEM.static.GetPointshopDescriptionControl( )
	return "DPointshopItemDescription"
end

function ITEM.static:GetPointshopIconDimensions( )
	return Pointshop2.GenerateIconSize( 2, 2 )
end

function ITEM.static:IsValidForServer( id )
	if #self.Servers == 0 then
		return true
	end

	return table.HasValue( self.Servers, id )
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
	itemTable.static.UUID = persistenceItem.uuid
	itemTable.PrintName = persistenceItem.name
	itemTable.Description = persistenceItem.description
	itemTable.Servers = persistenceItem.servers or {}
	if not persistenceItem.ranks or persistenceItem.ranks == "" then
		itemTable.Ranks = {}
	else
	 	itemTable.Ranks = persistenceItem.ranks
 end
end

function ITEM.static:PassesRankCheck( ply )
	if self.Ranks and #self.Ranks > 0 then
		if not table.HasValue( self.Ranks, ply:GetUserGroup( ) ) then
			return false
		end
	end
	return true
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

-- Hacky way to keep compatible
function ITEM:getNewInventoryIcon( )
	if self.icon then
		local old = self.icon
		self.icon = nil
		local icon = self:getIcon( )
		self.icon = old
		return icon
	else
		local icon = self:getIcon( )
		self.icon = nil
		return icon
	end
end

function ITEM:getLowendInventoryIcon( )
	self.icon = vgui.Create( "DPointshopSimpleInventoryIcon" )
	self.icon:SetItem( self )
	return self.icon
end

function ITEM:getCrashsafeIcon( )
	if Pointshop2.ClientSettings.GetSetting( "BasicSettings.LowendMode" ) then
		return self:getLowendInventoryIcon( )
	else
		return self:getIcon( )
	end
end
