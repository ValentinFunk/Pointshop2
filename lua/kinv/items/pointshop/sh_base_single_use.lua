ITEM.PrintName = "Single Use Item Base"
ITEM.baseClass = "base_pointshop_item"

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
		LibK.GLib.Error( Format( "[ERROR] Item %s Use failed: %s", self.class.name, err ) )
		return
	end
	self.used = true

	local ply = self:GetOwner( )
	Promise.Resolve()
	:Then(function() 
		-- Pcall returns either the argument or the returned value
		-- By wrapping the return value in a promise here we make sure
		-- that if a promise is returned we wait on it.
		return err 
	end):Then( function( )
		KLogf( 4, "Player %s used an item", ply:Nick( ) )
	end, function( errid, err )
		LibK.GLib.Error( Format( "Error using item: %s %s", tostring(errid), tostring(err) ) )
	end )
	:Always(function() 
		return Pointshop2Controller:getInstance( ):removeItemFromPlayer( ply, self )
	end)
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
