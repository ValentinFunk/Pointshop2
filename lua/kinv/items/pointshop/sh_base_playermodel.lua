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

function ITEM:ApplyModel( )
	if CLIENT then
		return
	end

	local ply = self:GetOwner( )

	if not IsValid( ply ) then
		ErrorNoHalt( "[PS2] Invalid owner for item " .. self.id .. ": " .. tostring( ply ) )
		return
	end

	if hook.Run( "PS2_PlayermodelShouldShow", ply ) == false then
		return
	end

	ply:SetModel( self.playerModel )
	ply:SetupHands()

	local groups = string.Explode( " ", self.bodygroups )
	for k = 0, ply:GetNumBodyGroups( ) - 1 do
		if ( ply:GetBodygroupCount( k ) <= 1 ) then continue end
		ply:SetBodygroup( k, groups[ k + 1 ] or 0 )
	end

	if ply:SkinCount( ) - 1 > 0 then
		ply:SetSkin( self.skin )
	end
end

function ITEM:OnEquip( )
	self:ApplyModel( )
	timer.Simple( 1, function( )
		self:ApplyModel( )
		hook.Run( "PS2_DoUpdatePreviewModel" )
	end )
	hook.Run( "PS2_DoUpdatePreviewModel" )
end

function ITEM:OnHolster( )
	local ply = self:GetOwner( )
	timer.Simple( 0, function( )
		hook.Run( "PS2_DoUpdatePreviewModel" )
	end )
	hook.Run( "PS2_ModelHolstered" )
	timer.Simple( 1, function( )
		hook.Run( "PlayerSetModel", ply )
	end )
end

function ITEM:PlayerSetModel( ply )
	if not IsValid( ply ) or not IsValid( self:GetOwner( ) ) then
		KLogf( 3, "Invalid ply or owner: ply %s (%s) owner %s (%s)",
			tostring(ply), type(ply),
			tostring(self:GetOwner()), type(self:GetOwner()) )
		return
	end

	if ply != self:GetOwner( ) then
		return
	end

	self:ApplyModel( )
	timer.Simple( 1, function( )
		self:ApplyModel( )
		hook.Run( "PS2_DoUpdatePreviewModel" )
	end )
end
Pointshop2.AddItemHook( "PlayerSetModel", ITEM )

/*
function ITEM:PlayerSpawn( ply )
	print( "Player Spawn called", ply, self:GetOwner( ) )
	if ply == self:GetOwner( ) then
		self:OnEquip( ply )
	end
end
Pointshop2.AddItemHook( "PlayerSpawn", ITEM )
*/

function ITEM.static:GetPointshopIconControl( )
	return "DPointshopPlayerModelIcon"
end


function ITEM.static:GetPointshopLowendIconControl( )
	return "DPointshopSimplePlayerModelIcon"
end

function ITEM.static.getPersistence( )
	return Pointshop2.PlayermodelPersistence
end

function ITEM.static.generateFromPersistence( itemTable, persistenceItem )
	ITEM.super.generateFromPersistence( itemTable, persistenceItem.ItemPersistence )
	itemTable.playerModel = persistenceItem.playerModel
	util.PrecacheModel( itemTable.playerModel )
	itemTable.skin = persistenceItem.skin
	itemTable.bodygroups = persistenceItem.bodygroups
end

function ITEM.static.GetPointshopIconDimensions( )
	return Pointshop2.GenerateIconSize( 4, 6 )
end
