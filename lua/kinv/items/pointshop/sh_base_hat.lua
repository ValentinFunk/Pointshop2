ITEM.PrintName = "Pointshop Hat Base"
ITEM.baseClass = "base_pointshop_item"

ITEM.static.outfitIds = {} --Model -> Outfit ID map

ITEM.category = "Hats"
ITEM.color = ""

function ITEM:initialize( )
end

function ITEM:AttachOutfit( ply )
	if SERVER then
		return 
	end
	
	if not ply.AttachPACPart then
		pac.SetupENT( ply )
		ply:SetShowPACPartsInEditor( false )
	end
	
	local outfit, id = self.class.getOutfitForModel( ply:GetModel( ) )
	ply:AttachPACPart( outfit )
end

function ITEM:RemoveOutfit( ply )
	if SERVER then
		return 
	end
	
	if not ply.AttachPACPart then
		return
	end
	
	local outfit, id = self.class.getOutfitForModel( ply:GetModel( ) )
	ply:RemovePACPart( outfit )
end

function ITEM:OnEquip( ply )
	if ply:Alive( ) and not (ply.IsSpec and ply:IsSpec()) then
		self:PlayerSpawn( ply )
	end
end

function ITEM:OnHolster( ply )
	self:RemoveOutfit( ply )
end

function ITEM:PlayerSpawn( ply )
	if ply == self:GetOwner( ) then
		self:AttachOutfit( ply )
	end
end
Pointshop2.AddItemHook( "PlayerSpawn", ITEM )

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
	return 108, 128
end