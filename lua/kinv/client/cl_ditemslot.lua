local PANEL = {}

function PANEL:Init( )
	self:SetSize( 64, 64 )
	self.itemStack = nil
	self:SetDropPos( "5" )
	self:Receiver( "Items", self.DropAction_Item )
	self._ITEMSLOT = true
end

function PANEL:DropAction_Item( drops, bDoDrop, command, x, y )
	local itemsContainer = self:GetParent( )
	local itemSlot = itemsContainer:GetClosestChild( x, y )

	if not itemSlot._ITEMSLOT then
		return
		--return self:DropAction_Simple( drops, bDoDrop, command, x, y )
	end

	self:UpdateDropTarget( 5, itemSlot )

	if table.HasValue( drops, itemSlot ) then return end

    local dropItemPanel = drops[1]
    local myItem = self.itemStack and self.itemStack.items and self.itemStack.items[1]
    if myItem then
        local slot = dropItemPanel:GetParent()
        if slot.GetSlotTable and not slot:GetSlotTable().canHoldItem(myItem) then
            self.invalidDrop = true
            return
        end
    end

    self.invalidDrop = false

	if bDoDrop then
		for k, v in pairs( drops ) do
			if v:IsOurChild( self ) or v == self then
				continue
			end

            print(self)

			local oldParent = v:GetParent( )

			v = v:OnDrop( self )
			self:DroppedOn( v )
			v.Hovered = false
			self.Hovered = false

			oldParent:OnModified( )
		end
		self:OnModified( )
	end
end

function PANEL:containsItem( item )
	if not IsValid( self.itemStack ) then return false end
	for k, v in pairs( self.itemStack.items ) do
		if v.id == item.id then
			return true
		end
	end
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( 50, 50, 50 )
	surface.DrawRect( 0, 0, w, h )

	if self.Dragging then
		surface.SetDrawColor( 40, 40, 40 )
		surface.DrawRect( 0, 0, w, h )
	end

	self.key = -1
	for k, v in pairs( self:GetParent( ):GetChildren( ) ) do
		if v == self then
			self.key = k
		end
	end
end

--Called when item is removed externally
function PANEL:itemRemoved( itemId )
	if not IsValid( self.itemStack ) then
		return false
	end

	return self.itemStack:removeItem( itemId )
end

--Called when item is added externally
function PANEL:addItem( item )
	if IsValid( self.itemStack ) then
		return self.itemStack:addItem( item )
	else
		local stack = vgui.Create( "DItemStack", self )
		stack:addItem( item )
		self.itemStack = stack
		return true
	end
end

function PANEL:removeItem( )
	if IsValid( self.itemStack ) then
		self.itemStack:Remove( )
	end
end

function PANEL:OnModified( )
	self:GetParent( ):OnModified( )
end

--panel got dropped on me
function PANEL:DroppedOn( panel )
	if panel:GetParent( ) == self then
		return
	end

	local otherStack = panel

	local didStack = false
	--Stack all items from otherStack on myStack
	local item = otherStack:removeItem( ) --get an item
	while item do
		if not self:addItem( item ) then --try adding it
			otherStack:addItem( item )
			break
		else
			didStack = true
		end
		item = otherStack:removeItem( )
	end

	--Swap Items
	if not didStack then
		local otherSlot = otherStack:GetParent( )
		otherSlot.itemStack = self.itemStack
		self.itemStack:SetParent( otherSlot )

		self.itemStack = otherStack
		otherStack:SetParent( self )
		otherSlot:OnModified( )
	end
end

function PANEL:DrawDragHover( x, y, w, h )
	DisableClipping( true )

	if not self.invalidDrop then
		surface.SetDrawColor( 255, 190, 0, 100 )
		surface.DrawRect( x, y, w, h )

		surface.SetDrawColor( 255, 190, 0, 230 )
		surface.DrawOutlinedRect( x, y, w, h )

		surface.SetDrawColor( 255, 190, 0, 50 )
		surface.DrawOutlinedRect( x-1, y-1, w+2, h+2 )
	else
		surface.SetDrawColor( 255, 0, 0, 100 )
		surface.DrawRect( x, y, w, h )

		surface.SetDrawColor( 255, 0, 0, 230 )
		surface.DrawOutlinedRect( x, y, w, h )

		surface.SetDrawColor( 255, 0, 0, 50 )
		surface.DrawOutlinedRect( x-1, y-1, w+2, h+2 )
	end

	DisableClipping( false )
end

derma.DefineControl( "DItemSlot", "", PANEL, "DDragBase" )
