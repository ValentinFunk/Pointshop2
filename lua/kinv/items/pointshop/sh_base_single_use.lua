ITEM.PrintName = "Single Use Item Base"
ITEM.baseClass = "base_pointshop_item"

function ITEM:initialize( )
end

--CLIENTSIDE: When use button is clicked
function ITEM:UseButtonClicked( )
	self:ServerRPC( "InternalOnUse" )
	return true --Disable Button
end

function ITEM:CanBeUsed( )
	local servers = self.class.Servers
	if #servers > 0 and not table.HasValue( servers, Pointshop2.GetCurrentServerId( ) ) then
		return false, "This item cannot be used on this server"
	end
	return true
end

--SERVERSIDE: When button is clicked
function ITEM:InternalOnUse( )
	--Avoid double use
	if self.used or not self:CanBeUsed( ) then
		return
	end

	local succ, err = pcall( self.OnUse, self )
	if not succ then
		KLogf( 2, "[ERROR] Item %s Use failed: %s", self.class.name, err )
		debug.Trace( )
		return
	end
	self.used = true

	local ply = self:GetOwner( )

	Pointshop2Controller:getInstance( ):removeItemFromPlayer( ply, self )
	:Then( function( )
		KLogf( 4, "Player %s used an item", ply:Nick( ) )
	end, function( errid, err )
		KLogf( 2, "Error using item: %s", err )
	end )
end
ITEM.static.AllowRPC( "InternalOnUse" )

--SERVERSIDE: For override on item use
function ITEM:OnUse( )
	debug.Trace()
end

function ITEM.static.GetPointshopDescriptionControl( )
	return "DUsableItemDescription"
end

function ITEM.static:GetPointshopIconControl( )
	return "DPointshopMaterialIcon"
end

function ITEM.static:GetPointshopLowendIconControl( )
	return "DPointshopMaterialIcon"
end

function ITEM:getIcon( )
	self.icon = vgui.Create( "DPointshopMaterialInvIcon" )
	self.icon:SetItem( self )
	return self.icon
end
