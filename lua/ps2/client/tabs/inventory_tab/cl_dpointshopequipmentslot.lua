local PANEL = {}

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
