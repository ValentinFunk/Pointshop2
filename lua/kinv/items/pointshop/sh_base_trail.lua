ITEM.PrintName = "Pointshop Playermodel Base"
ITEM.baseClass = "base_pointshop_item"

ITEM.material = ""

ITEM.category = "Trails"
ITEM.color = ""

function ITEM:initialize( )
end

function ITEM:AttachTrail( )
	if SERVER then
		local ply = self:GetOwner()
		if (ply.IsSpec and ply:IsSpec()) then
			return
		end
		self.trailEnt = util.SpriteTrail( ply, 0, self.color, false, 15, 1, 4, 0.125, self.material .. ".vmt" )
		timer.Simple( 1, function( )
			self:ClientRPC( "TrailAdded", self.trailEnt )
		end )
	end
end

function ITEM:TrailAdded( trailEnt )
	if Pointshop2.ClientSettings.GetSetting( "BasicSettings.VisualsDisabled" ) then 
		if IsValid( trailEnt ) then
			trailEnt:SetVisible( false )
		end
	end
end

function ITEM:RemoveTrail( )
	if SERVER then
		SafeRemoveEntity( self.trailEnt )
	end
end

function ITEM:OnEquip( )
	self:AttachTrail( )
end

function ITEM:PlayerSpawn( ply )
	if ply == self:GetOwner( ) then
		self:AttachTrail( )
	end
end
Pointshop2.AddItemHook( "PlayerSpawn", ITEM )

function ITEM:PlayerDeath( victim, inflictor, attacker )
	if victim == self:GetOwner( ) then
		self:RemoveTrail( )
	end
end
Pointshop2.AddItemHook( "PlayerDeath", ITEM )

function ITEM:OnHolster( ply )
	self:RemoveTrail( )
end

function ITEM.static:GetPointshopIconControl( )
	return "DPointshopTrailIcon"
end

function ITEM.static.getPersistence( )
	return Pointshop2.TrailPersistence
end

function ITEM.static.generateFromPersistence( itemTable, persistenceItem )
	ITEM.super.generateFromPersistence( itemTable, persistenceItem.ItemPersistence )
	itemTable.material = persistenceItem.material
end

function ITEM.static.GetPointshopIconDimensions( )
	return Pointshop2.GenerateIconSize( 2, 4 )
end

/*
	Inventory icon
*/
function ITEM:getIcon( )
	self.icon = vgui.Create( "DPointshopMaterialInvIcon" )
	self.icon:SetItem( self )
	self.icon:SetSize( 64, 64 )
	return self.icon
end