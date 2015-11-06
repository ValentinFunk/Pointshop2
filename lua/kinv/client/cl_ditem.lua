local PANEL = {}
function PANEL:Init( )
	self:SetSize( 64, 64 )
	self.items = {}
	self.icon = nil
	self:Droppable( "Items" )
	self:SetUseLiveDrag( true )
end

Derma_Hook( PANEL, "Paint", "Paint", "Item" )

function PANEL:OnMousePressed( code )
	if code == MOUSE_LEFT and input.IsKeyDown( KEY_LSHIFT ) then
		if self.items and #self.items > 1 then
			local frame = vgui.Create( "DFrame" )
			frame:SetSize( 200, 110 )
			frame:SetTitle( "Split stack" )
			frame:Center( )
			frame:MakePopup( )
			frame:DoModal( )
			frame:SetBackgroundBlur( true )
			function frame:Think( )
				if not self.dontStopDrag then
					dragndrop.StopDragging()
				end
			end

			local wrap = vgui.Create( "DPanel", frame )
			function wrap:Paint( ) end
			wrap:DockMargin( 5, 5, 5, 5 )
			wrap:Dock( TOP )

			local desc = vgui.Create( "DLabel", wrap )
			desc:DockMargin( 5, 5, 5, 5 )
			desc:SetFont( "MenuFont" )
			desc:Dock( FILL )
			--desc:SetContentAlignment( 5 )
			desc:SetText( "Items to seperate" )
			desc:SetColor( color_black )

			local picker = vgui.Create( "DNumberWang", wrap )
			picker:Dock( RIGHT )
			picker:SetMinMax( 1, #self.items - 1 )
			picker:SetValue( 1 )

			local buttonsPanel = vgui.Create( "DPanel", frame )
			function buttonsPanel:Paint( ) end
			buttonsPanel:DockMargin( 5, 5, 5, 5 )
			buttonsPanel:Dock( TOP )

			local splitBtn = vgui.Create( "DButton", buttonsPanel )
			splitBtn:SetText( "Split" )
			splitBtn:DockMargin( 5, 0, 5, 0 )
			splitBtn:Dock( LEFT )

			/*local abortBtn = vgui.Create( "FSButton", buttonsPanel )
			abortBtn:SetText( "Cancel" )
			abortBtn:SetFont( "MenuFont" )
			abortBtn:DockMargin( 5, 0, 5, 0 )
			abortBtn:Dock( LEFT )
			function abortBtn.DoClick( )
				frame:Close( )
			end*/

			function splitBtn.DoClick( )
				local amount = tonumber( picker:GetValue( ) )
				if not amount then
					return
				end

				if amount < 1 or amount >= #self.items then
					return
				end

				frame:Close( )

				local newItems = {}
				for i = 1, amount do
					local removedItem = self:removeItem( )
					if removedItem then
						table.insert( newItems, removedItem )
					end
				end

				local slotFound
				local myslot = self:GetParent( )
				local itemsContainer = myslot:GetParent( )
				local firstItem = table.remove( newItems )
				for k, slot in pairs( itemsContainer:GetChildren( ) ) do
					if slot == myslot then
						continue --dont add item to the stack we just split it from
					end
					if IsValid( slot.itemStack ) then
						continue --find space for a new stack, dont put it on some other stack
					end
					if slot:addItem( firstItem ) then
						slotFound = slot
						break
					end
				end

				for k, item in pairs( newItems ) do
					slotFound:addItem( item )
				end

				frame.dontStopDrag = true
				dragndrop.m_DragWatch = slotFound.itemStack
				dragndrop.m_MouseCode = MOUSE_LEFT
				dragndrop.m_MouseX = gui.MouseX( )
				dragndrop.m_MouseY = gui.MouseY( )
				dragndrop:StartDragging( )
				itemsContainer:savePositions( )
			end
		end
		return
	end
	return self.BaseClass.OnMousePressed( self, code )
end

function PANEL:canAddItem( item )
	if not self.items[1] then
		return true --newly created stack, we can add to it
		--error( "There should always be an item at first position in the stack" )
	end

	if #self.items >= self.items[1].class.stackCount then
		return false
	end
	if self.items[1].class != item.class then
		return false
	end

	return true
end

function PANEL:addItem( item )
	if self:canAddItem( item ) then
		table.insert( self.items, item )
		return true
	end
	return false
end

function PANEL:removeItem( itemId )
	local removed = false
	if itemId then
		local removeKey
		for k, v in pairs( self.items ) do
			if v.id == itemId then
				removeKey = k
			end
		end
		if removeKey then
			removed = table.remove( self.items, removeKey )
		end
	else
		removed = table.remove( self.items )
	end
	if removed and table.Count( self.items ) == 0 and IsValid( self.icon ) then
		self.icon:Remove( )
	end
	return removed
end

function PANEL:Think( )

	if not IsValid( self.icon ) and self.items[1] then
		self.icon = self.items[1]:getCrashsafeIcon( )
		self.icon:SetParent( self )
		self.icon.stackPanel = self
		self.icon:SetDragParent( self )
		/*function self.icon:PaintOver( w, h )
			derma.SkinHook( "PaintOver", "ItemIcon", self, w, h )
		end*/
		if not IsValid( self.itemCountLabel ) then
			self.itemCountLabel = vgui.Create( "DLabel", self.icon )
			self.itemCountLabel:SetPos( 50, 50 )
			self.itemCountLabel:SetContentAlignment( 6 )
			self.itemCountLabel:SetColor( color_bright )
			--self.itemCountLabel:SetFont( "MenuFontBold" )
			function self.itemCountLabel.Think( )
				if #self.items > 1 then
					self.itemCountLabel:SetText( #self.items )
				else
					self.itemCountLabel:SetText( "" )
				end
			end
		end
	end

	if #self.items == 0 then
		self:Remove( )
	end
end

derma.DefineControl( "DItemStack", "", PANEL, "DDragBase" )
