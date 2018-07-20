local PANEL = {}

function PANEL:Init( )
	self:Receiver( "Items", self.DropAction_EquipmentItem )
	self.__IS_EQUIPMENTSLOT = true
	self.AllowSwap = false
end

function PANEL:DropAction_EquipmentItem( drops, bDoDrop, command, x, y )
	local itemsSlotHolder = self:GetParent( )

	local dropPanel = drops[1]
	if not dropPanel then
		return
	end

	local dropItem = dropPanel.items[1]
	if not dropItem then
		return
	end

	if itemsSlotHolder:CanHoldItem( dropItem ) then
		self.invalidDrop = false
		self:SetDropTarget( self.x, self.y, self:GetWide( ), self:GetTall( ) )
	else
		self.invalidDrop = true
		self:SetDropTarget( self.x, self.y, self:GetWide( ), self:GetTall( ) )
	end

	if not bDoDrop or self.invalidDrop then
		return
	end

	if dropPanel:IsOurChild( self ) then
		return
	end

	local oldParent = dropPanel:GetParent( )

	dropPanel = dropPanel:OnDrop( self )
	self:DroppedOn( dropPanel )

	oldParent:OnModified( )
	-- self:OnModified( )
end

-- Called from item slots whenever the basic transfer will not work and a swap is needed
function PANEL:AcceptItems( otherStack )
	local otherSlot = otherStack:GetParent( )

	-- This is the item we want to hold
	local item = otherStack:removeItem( )
	local ourItem = IsValid(self.itemStack) and #self.itemStack.items == 1 and self.itemStack:removeItem( )

	if ourItem then
		-- Move our current item somewhere into the inventory
		local slotFound
		local inventorySlotsContainer = otherSlot:GetParent( )
		for k, slot in pairs( inventorySlotsContainer:GetChildren( ) ) do
			if slot:addItem( ourItem ) then
				slotFound = slot
				break
			end
		end

		-- There is no slot for us, move the items back onto our slot
		if not slotFound then
			KLogf( 2, "No slot found in inv to unequip item into!" )
			self:addItem( ourItem )
			otherStack:addItem( item )
			return
		end

		inventorySlotsContainer:savePositions( )
	end

	-- Move the other item into this slot
	self:addItem( item )
	self.itemStack:Think()
	self.itemStack.icon:Select()
	self:OnModified( )
end

-- Item stack got dropped on this panel
function PANEL:DroppedOn( panel )
	if panel:GetParent( ) == self then
		return
	end

	local otherStack = panel
	local otherSlot = otherStack:GetParent( )

	-- Support swapping items between e.g. two accessory slots
	if otherStack.__IS_EQUIPMENTSLOT then
		otherSlot.itemStack = self.itemStack
		self.itemStack:SetParent( otherSlot )

		self.itemStack = otherStack
		otherStack:SetParent( self )
		otherSlot:OnModified( )

		return
	else
		self:AcceptItems( otherStack )
	end
end

derma.DefineControl( "DItemSlotEquipment", "", PANEL, "DItemSlot" )

local PANEL = { }

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )

	self.actualSlot = vgui.Create( "DItemSlotEquipment", self )
	self.actualSlot:Dock( TOP )
	function self.actualSlot:GetSlotTable( )
		return self:GetParent():GetSlotTable( )
	end

	self.label = vgui.Create( "DLabel", self )
	self.label:Dock( TOP )
	self.label:SetContentAlignment( 5 )

	derma.SkinHook( "Layout", "PointshopEquipmentSlot", self )
end

function PANEL:SelectItem( )
	if IsValid( self.actualSlot.itemStack ) then
		self.actualSlot.itemStack:Think( )
	end
	if IsValid( self.actualSlot.itemStack.icon ) then
		self.actualSlot.itemStack.icon:Select( )
	end
end

function PANEL:Clear( )
	self.actualSlot:removeItem( )
end

function PANEL:SetEquippedItem( item, opts )
	opts = opts or { doSelect = true }

	self:Clear( )
	self.actualSlot:addItem( item )

	if opts.doSelect then
		self.actualSlot.itemStack:Think( ) -- Force icon creation
		self.actualSlot.itemStack.icon:Select( ) -- Select the icon
	end
end

function PANEL:SetSlotTable( slotTable )
	self.slotTable = slotTable
end

function PANEL:GetSlotTable()
	return self.slotTable
end

function PANEL:SetLabel( txt )
	self.slotName = txt
	self.label:SetText( txt )
end

function PANEL:PerformLayout( )
	self:SizeToChildren( true, true )
end

function PANEL:OnModified( )
	Pointshop2View:getInstance( ):equipItem( self:GetItem( ), self.slotName )
end

function PANEL:GetItem( )
	if IsValid( self.actualSlot.itemStack ) and self.actualSlot.itemStack.items then
		return self.actualSlot.itemStack.items[1]
	end
end

--Can item be equiped in this slot?
function PANEL:CanHoldItem( item )
	return true
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopEquipmentSlot" )
derma.DefineControl( "DPointshopEquipmentSlot", "", PANEL, "DPanel" )
