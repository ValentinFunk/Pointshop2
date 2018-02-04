ITEM.PrintName = "Pointshop Hat Base"
ITEM.baseClass = "base_pointshop_item"

ITEM.static.outfitIds = {} --Model -> Outfit ID map

ITEM.category = "Hats"
ITEM.color = ""

function ITEM:initialize( )
	ITEM.super.initialize( self )
	self.attached = false
end

if CLIENT then
	function ITEM:AttachOutfit( )
		local ply = self:GetOwner( )
		if not IsValid(ply) then
			debug.Trace( )
			PrintTable( self )
			return
		end

		if Pointshop2.ClientSettings.GetSetting( "BasicSettings.VisualsDisabled" ) then
			return
		end

		if hook.Run( "PS2_VisualsShouldShow", ply ) == false then
			return
		end

		if not ply.AttachPACPart then
			pac.SetupENT( ply )
			ply:SetShowPACPartsInEditor( false )
		end

		local outfit, id = self:getOutfitForModel( ply:GetModel() )
		self.outfit = outfit
		self.model = ply:GetModel()
		ply:AttachPACPart( outfit, ply )
		self.attached = true
	end

	function ITEM:RemoveOutfit( )
		self.attached = false

		local ply = self:GetOwner()
		if not ply.RemovePACPart then
			return
		end

		local outfit = self.outfit or self.class.getOutfitForModel( ply:GetModel() )
		ply:RemovePACPart( outfit )
	end

	-- Monitor Model Changes
	function ITEM:Think( )
		if not self.outfit or not self.model or not IsValid( self:GetOwner( ) ) then
			return
		end

		if self.model != self:GetOwner( ):GetModel( ) then
			self:RemoveOutfit( )
			self:AttachOutfit( )
		end

		local shouldShow = not ( hook.Run( "PS2_VisualsShouldShow", self:GetOwner( ) ) == false )
		if shouldShow != self.attached then
			if shouldShow then
				self:AttachOutfit( )
			else
				self:RemoveOutfit( )
			end
		end
	end
	Pointshop2.AddItemHook( "Think", ITEM )
else
	function ITEM:Think( )
	end

	function ITEM:PlayerSpawn( ply )
		if not ply:Alive( ) then
			return
		end

		if ply.IsSpec and ply:IsSpec() then
			return
		end

		if ply.IsGhost and ply:IsGhost() then
			return
		end

		if ply == self:GetOwner( ) then
			timer.Simple( 0.5, function( )
				self:ClientRPC( "AttachOutfit" )
			end )
		end
	end
	Pointshop2.AddItemHook( "PlayerSpawn", ITEM )

	function ITEM:PlayerDeath( victim, inflictor, attacker )
		if victim == self:GetOwner( ) then
			self:ClientRPC( "RemoveOutfit" )
		end
	end
	ITEM.PlayerSilentDeath = ITEM.PlayerDeath
	Pointshop2.AddItemHook( "PlayerDeath", ITEM )
	Pointshop2.AddItemHook( "PlayerSilentDeath", ITEM )
end

function ITEM:OnEquip( )
	if SERVER then
		return
	end

	local ply = self:GetOwner()
	if not IsValid( ply ) then
		timer.Simple( 1, function()
			if IsValid( self:GetOwner( ) ) then
				self:OnEquip( )
			end
		end )
		return
	end

	if not ply:Alive( ) then
		return
	end

	if ply.IsSpec and ply:IsSpec() then
		return
	end

	if ply.IsGhost and ply:IsGhost() then
		return
	end

	self:AttachOutfit( )
end

function ITEM:OnHolster( )
	if SERVER then
		return
	end

	self:RemoveOutfit( )
end

function Pointshop2.AllContentInstalled( self )
	local outfit = self.getBaseOutfit( )

	local missingModels = {}
	local function checkModel( part )
		for k, v in pairs( part.children or {} ) do
			checkModel( v )
		end

		if part.self and part.self.Model then
			local model = part.self.Model
			if not file.Exists( model, "GAME" ) then
				table.insert( missingModels, model )
			end
		end
	end

	for k, part in pairs( outfit ) do
		checkModel( part )
	end

	return missingModels
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

function ITEM.static:GetPointshopLowendIconControl( )
	return "DPointshopSimpleHatIcon"
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

	-- Can be used for outfits that the user can customize
	function itemTable:getOutfitForModel( model )
		return itemTable.static.getOutfitForModel( model )
	end
end

function ITEM:getOutfitForModel( model )
	return self.class.getOutfitForModel( model )
end

function ITEM.static.GetPointshopIconDimensions( )
	return Pointshop2.GenerateIconSize( 4, 4 )
end

-- Overwrite to prevent Hat Preview (use for custom previews)
function ITEM:NoPreview( )
	return false
end
