ITEM.PrintName = "Pointshop Playermodel Base"
ITEM.baseClass = "base_pointshop_item"

ITEM.playerModel = "models/player/kleiner.mdl"
ITEM.bodygroups = "0"
ITEM.skin = 0

ITEM.category = "Playermodels"

/*
	Inventory icon
*/
function ITEM:getIcon( )
	self.icon = vgui.Create( "DPointshopPlayerModelInvIcon" )
	self.icon:SetItem( self )
	self.icon:SetSize( 64, 64 )
	return self.icon
end

function ITEM:OnEquip( ply )
	if not ply._oldModel then
		ply._oldModel = ply:GetModel( )
	end
	
	timer.Simple( 1, function( )
		ply:SetModel( self.playerModel )
		
	end )
end

function ITEM:OnHolster( ply )
	if ply._oldModel then
		ply:SetModel(ply._oldModel)
	end
end

function ITEM:PlayerSetModel( ply )
	ply:SetModel( self.playerModel )
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
	itemTable.playerModel = persistenceItem.playerModel
	itemTable.skin = persistenceItem.skin
	itemTable.bodygroups = persistenceItem.bodygroups
end

function ITEM.static.GetPointshopIconDimensions( )
	return 100, 128
end