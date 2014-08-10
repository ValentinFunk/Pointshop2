ITEM.PrintName = "Pointshop Hat Base"
ITEM.baseClass = "base_pointshop_item"

ITEM.static.outfitIds = {} --Model -> Outfit ID map

ITEM.category = "Hats"
ITEM.color = ""

function ITEM:initialize( )
end

if CLIENT then
	function ITEM:AttachOutfit( )
		local ply = self:GetOwner( )
		if not IsValid(ply) then
			debug.Trace( )
			PrintTable( self )
		end
		if not ply.AttachPACPart then
			pac.SetupENT( ply )
			ply:SetShowPACPartsInEditor( false )
		end
		
		local outfit, id = self.class.getOutfitForModel( ply:GetModel( ) )
		ply:AttachPACPart( outfit )
	end

	function ITEM:RemoveOutfit( )
		print( "ITEM:RemoveOutfit" )
		local ply = self:GetOwner() 
		if not ply.RemovePACPart then
			return
		end
		
		local outfit, id = self.class.getOutfitForModel( ply:GetModel( ) )
		ply:RemovePACPart( outfit )
	end
else
	function ITEM:PlayerSpawn( ply )
		if ply == self:GetOwner( ) then
			self:ClientRPC( "AttachOutfit" )
		end
	end
	Pointshop2.AddItemHook( "PlayerSpawn", ITEM )

	function ITEM:PlayerDeath( victim, inflictor, attacker )
		if victim == self:GetOwner( ) then
			self:ClientRPC( "RemoveOutfit" )
		end
	end
	Pointshop2.AddItemHook( "PlayerDeath", ITEM )
end

function ITEM:OnEquip( ply )
	if SERVER then 
		return
	end
	
	if ply:Alive( ) and not (ply.IsSpec and ply:IsSpec()) then
		self:AttachOutfit( )
	end
end

function ITEM:OnHolster( ply )
	if SERVER then 
		return
	end
	
	self:RemoveOutfit( )
end


/*
	Tech stuff
*/
function ITEM:getIcon( )
	self.icon = vgui.Create( "DPointshopHatInvIcon" )
	self.icon:SetItem( self )
	self.icon:SetSize( 64, 64 )
	return self.icon
end

function ITEM:CanBeEquippedInSlot( slotName )
	return table.HasValue( self.class.validSlots, slotName )
end

function ITEM.static:GetPointshopIconControl( )
	return "DPointshopHatIcon"
end

function ITEM.static.getPersistence( )
	return Pointshop2.HatPersistence
end

local CSSModels = {
	"gign.mdl",
	"gsg9.mdl",
	"sas.mdl",
	"sas.mdl",
	"urban.mdl",
	"arctic.mdl",
	"guerilla.mdl",
	"leet.mdl",
	"phoenix.mdl",
}

local function isCssModel( model )
	for k, v in pairs( CSSModels ) do
		if string.find( model, v ) then
			return true
		end
	end
	return false
end

/*
	Creates a new class that inherits this base
*/
function ITEM.static.generateFromPersistence( itemTable, persistenceItem )
	ITEM.super.generateFromPersistence( itemTable, persistenceItem.ItemPersistence )
	
	itemTable.static.iconInfo = persistenceItem.iconInfo
	itemTable.static.validSlots = persistenceItem.validSlots
	itemTable.static.outfitIds = {}
	for k, mapping in pairs( persistenceItem.OutfitHatPersistenceMapping ) do
		itemTable.static.outfitIds[mapping.model] = mapping.outfitId
	end
	
	function itemTable.static.getBaseOutfit( )
		local outfitId = itemTable.outfitIds[Pointshop2.HatPersistence.ALL_MODELS]
		return Pointshop2.Outfits[outfitId], outfitId
	end
	
	function itemTable.static.getOutfitForModel( model )
		local outfitId
		if itemTable.outfitIds[model] then
			outfitId = itemTable.outfitIds[model]
		elseif isCssModel( model ) then
			outfitId = itemTable.outfitIds[Pointshop2.HatPersistence.ALL_CSS_MODELS]
			if not outfitId then
				return itemTable.static.getBaseOutfit( )
			end
		else
			outfitId = itemTable.outfitIds[Pointshop2.HatPersistence.ALL_MODELS]
		end
		return Pointshop2.Outfits[outfitId], outfitId
	end
end

function ITEM.static.GetPointshopIconDimensions( )
	return Pointshop2.GenerateIconSize( 4, 4 )
end