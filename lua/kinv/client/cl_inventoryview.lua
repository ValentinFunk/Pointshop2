InventoryView = class( "InventoryView" )
InventoryView.static.controller = "InventoryController"
InventoryView:include( BaseView )

function InventoryView:initialize( )
	self.inventories = {}
	setmetatable( self.inventories, {__mode = 'v' } ) --weak token holder for easy access

	self.inventoryPanels = {}
end

function InventoryView:receiveInventory( inventory )
	if IsValid( inventory:getOwner( ) ) then
		local owner = inventory:getOwner( )
		owner.inventories = owner.inventories or {}
		table.insert( owner.inventories, inventory )
	else
		KLogf( 3, "WARNING: Pure weak reference to inventory " .. inventory.id .. "\n" )
		timer.Simple( 1, function( )
			self:receiveInventory( inventory )
		end )
	end
	self.inventories[inventory.id] = inventory
end

function InventoryView:itemAdded( inventoryId, itemId, item )
	item = item or KInventory.ITEMS[itemId]
	if not item then
		LibK.GLib.Error( "Received itemAdded for uncached item %s (%s)", tostring(itemId), type(itemId))
	else
		KInventory.ITEMS[itemId] = item
	end

	if not self.inventories[inventoryId] then
		error( "Cannot add item to inventory " .. inventoryId .. ": inventory not cached on the client" )
	end
	self.inventories[inventoryId]:addItem( item )
	hook.Run( "KInv_ItemAdded", self.inventories[inventoryId], item )
end

function InventoryView:itemRemoved( inventoryId, itemId, resetSelection )
	if not self.inventories[inventoryId] then
		error( "Cannot remove item from inventory " .. inventoryId .. ": not cached on the client" )
	end

	self.inventories[inventoryId]:removeItemById( itemId )
	hook.Run( "KInv_ItemRemoved", self.inventories[inventoryId], itemId, resetSelection )
	if IsValid( self.inventoryPanels[inventoryId] ) then
		self.inventoryPanels[inventoryId]:itemRemoved( itemId, { resetSelection = resetSelection } )
	end
end

function InventoryView:dropItem( item )
	self:controllerAction( "dropItem", item.id )
end

if IsValid( invFrame ) then
	invFrame:Remove( )
end
function InventoryView:displayInventory( inventoryId )
	--TODO make this nicer
	if not inventoryId then
		for k, v in pairs( self.inventories ) do
			if v:getOwner( ) == LocalPlayer( ) then
				inventoryId = k
				break
			end
		end
	end

	if not self.inventories[inventoryId] then
		error( "Cannot open inventory " .. tostring( inventoryId ) .. ": not cached on the client" )
	end

	if IsValid( self.inventoryPanels[inventoryId] ) then
		self.inventoryPanels[inventoryId]:MakePopup( )
		self.inventoryPanels[inventoryId]:SetVisible( true )
	else
		local invPanel = vgui.Create( "DInventory" )
		invPanel:Center( )
		invPanel:MakePopup( )
		invPanel:setInventory( self.inventories[inventoryId] )

		self.inventoryPanels[inventoryId] = invPanel
		invFrame = invPanel
	end
end
