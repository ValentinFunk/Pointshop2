local PANEL = {}
local PANEL = { }

function PANEL:Init( )
	self:Receiver( "Items", self.DropAction_EquipmentItem )
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
	self:OnModified( )
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

	hook.Add( "PS2_SlotChanged", self, function( self, slot )
		if slot.slotName == self.slotName then
			self.actualSlot:removeItem( )

			if slot.Item then
				local item = KInventory.ITEMS[slot.Item.id]
				self.actualSlot:addItem( item )

				local function remove( )
					if IsValid( self.actualSlot.itemStack ) then
						self.actualSlot.itemStack:Think( )
					end
					if IsValid( self.actualSlot.itemStack.icon ) then
						self.actualSlot.itemStack.icon:Select( )
					end
				end

				timer.Simple( 0.01, remove )
				remove( )
			end
		end
	end )
	derma.SkinHook( "Layout", "PointshopEquipmentSlot", self )
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

	for k, v in pairs(LocalPlayer().PS2_Slots) do
		hook.Run("PS2_SlotChanged", {slotName = k, Item = v})
	end
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

function PANEL:SetItem( item )
	self.actualSlot:removeItem( )
	self.actualSlot:addItem( item )
end

--Can item be equiped in this slot?
function PANEL:CanHoldItem( item )
	return true
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopEquipmentSlot" )
derma.DefineControl( "DPointshopEquipmentSlot", "", PANEL, "DPanel" )
