InventoryController = class( "InventoryController" )
InventoryController:include( BaseController )

local Inventory = KInventory.Inventory

function InventoryController:canDoAction( ply, action )
	local def = Deferred( )
	def:Reject( "Access Denied" )
	return def:Promise( )
end

function InventoryController:itemAdded( inv, item )
	local owner = inv:getOwner( )
	if IsValid( owner ) and owner:IsPlayer( ) then
		self:startView( "InventoryView", "itemAdded", owner, inv.id, item )
	end
end

function InventoryController:itemRemoved( inv, itemId )
	local owner = inv:getOwner( )

	if IsValid( owner ) then
		self:startView( "InventoryView", "itemRemoved", owner, inv.id, itemId )
	else
		LibK.GLib.Error("InventoryController:itemRemoved - Invalid owner!")
	end
end

function InventoryController:itemPickUp( ply, item )
	print( "InventoryController:itemPickUp( " .. tostring( ply ) .. ", " .. tostring( item )  )
	return KInventory.Inventory.findByOwnerId( ply.kPlayerId )
	:Then( function( inv )
		return inv:addItem( item )
	end )
end

function InventoryController:dropItem( ply, itemId )
	KInventory.Item.findById( itemId )
	:Then( function( item )
		local def = Deferred( )
		if not item then
			def:Reject( 1, "Can't drop item: item doesn't exist" )
			--Inventory seems to be out of sync, resend
			KLogf( 3, "WARNING: %s inventory out of sync", ply:Nick( ) )
			return def:Promise( )
		end
		
		if not item.inventory_id then
			def:Reject( 0, "Item does not belong to an inventory" )
			return def:Promise( )
		end
		
		Inventory.findById( item.inventory_id )
		:Then( function( inv )
			if not inv then
				def:Reject( 0, "Invalid Inventory " .. item.inventory_id )
				return
			end
			
			if inv:getOwner( ) != ply then
				def:Reject( 1, "Can't drop item: You don't own this item" )
				return
			end
			
			if not ply:Alive( ) then
				def:Reject( 1, "You can't drop items when you are dead!" )
				return
			end
			
			def:Resolve( inv, item )
		end,
		function( errid, err )
			def:Reject( errid, err )
		end )
		
		return def:Promise( )
	end )
	:Then( function( inv, item )
		return inv:removeItem( item )
	end )
	:Then( function( inv, item )
		local def = Deferred( )
		local succ, err = pcall( item.handleDrop, item, ply )
		if not succ then
			def:Reject( 0, "Error dropping " .. item.class.name .. ": LUA ERROR " .. err )
			return def:Promise( )
		end
		
		def:Resolve( )
		return def:Promise( )
	end )
	:Fail( function( errid, err )
		if errid > 0 then
			self:startView( "InventoryView", "displayError", "Couldn't drop item: " .. err )
		else
			self:startView( "InventoryView", "displayError", "Internal Server Error: " .. errid )
			ErrorNoHalt( "Error dropping item: " .. errid .. ", " .. err )
		end
	end )
end