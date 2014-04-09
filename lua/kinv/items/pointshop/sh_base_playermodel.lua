ITEM.PrintName = "Pointshop Playermodel Base"
ITEM.baseClass = "base_pointshop_item"

ITEM.model = "models/player/kleiner.mdl"
ITEM.bodygroups = "0"
ITEM.skin = 0

ITEM.category = "Playermodels"

function ITEM:OnEquip( )
	if not ply._OldModel then
		ply._OldModel = ply:GetModel( )
	end
	
	timer.Simple( 1, function( )
		ply:SetModel( self.Model )
		
	end )
end

function ITEM:OnHolster( )
	if ply._OldModel then
		ply:SetModel(ply._OldModel)
	end
end

function ITEM:PlayerSetModel( ply )
	ply:SetModel( self.Model )
end
Pointshop2.AddItemHook( "PlayerSetModel", ITEM )

function ITEM.static:GetPointshopIconControl( )
	return "DPointshopPlayerModelIcon"
end

function ITEM.static.getPersistence( )
	return Pointshop2.PlayermodelPersistence
end

function ITEM.static.generateFromPersistence( itemTable, persistenceItem )
	ITEM.super.generateFromPersistence( itemTable, persistenceItem.ItemPersistence )
	itemTable.model = persistenceItem.model
	itemTable.skin = persistenceItem.skin
	itemTable.bodygroups = persistenceItem.bodygroups
end

function ITEM.static.GetPointshopIconDimensions( )
	return 100, 128
end