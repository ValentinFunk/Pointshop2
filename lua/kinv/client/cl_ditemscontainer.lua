local PANEL = {}

function PANEL:Init( )
	self:SetSpaceX( 5 )
	self:SetSpaceY( 5 )
end

function PANEL:setCategoryName( catName )
	self.categoryName = catName
end

function PANEL:initSlots( amount )
	dp( amount )
	if self.initializedSlots then
		for k, v in pairs( self:GetChildren( ) ) do
			v:Remove( )
		end
	end
	
	if not amount then
		local x, y = self.m_iBorder, self.m_iBorder
		local MaxWidth	= self:GetWide() - self.m_iBorder * 2;
		local MaxHeight	= self:GetTall() - self.m_iBorder * 2;
		local w, h = 64, 64
		local RowHeight = h;
		
		self.count = 0
		while y < MaxHeight do
			if ( x + w > MaxWidth ) then
				x = self.m_iBorder
				y = y + RowHeight + self.m_iSpaceY
				if y > MaxHeight then
					break 
				end
			end
			self.count = self.count + 1
			x = x + w + self.m_iSpaceX
			if self.count > 1000 then
				print( "count > 1000" )
				return 
			end
		end
	else
		self.count = amount
	end
	
	for i = 1, self.count do
		local slot = self:Add( "DItemSlot" )
	end
	self.initializedSlots = true
	
	if self.loadedItems then
		self:setItems( self.itemsTbl )
		self:loadItems( )
	end
end

function PANEL:SizeToFullHeight( )
	self:InvalidateLayout( true )
	local h = 0
	for k, v in pairs( self:GetChildren( ) ) do
		local x, y = self:GetPos( )
		if y + v:GetTall( ) > h then
			h = y + v:GetTall( )
		end
	end
	self:SetTall( h )
end

function PANEL:Think( )
	if self.initializedSlots and not self.loadedItems then
		self:loadItems( true )
		self.loadedItems = true
	end
end

function PANEL:OnModified( )
	--print("OnModified", self )
	for k, s in pairs( self:GetChildren( ) ) do
		if s.itemStack and s.itemStack.items and s.itemStack.items[1] then
			--print( s.itemStack.items[1].id )
		end
	end
	self:savePositions( )
end

function PANEL:savePositions( )
	self.fname = "itempositions_" .. Pointshop2.CalculateServerHash( ) .. self.categoryName .. ".txt"
	
	self.itemPositions = {}
	for pos, slot in ipairs( self:GetChildren( ) ) do
		if slot.itemStack and slot.itemStack.items then
			for _, item in pairs( slot.itemStack.items ) do
				self.itemPositions[item.id] = pos
			end
		end
	end
	file.Write( self.fname, util.TableToJSON( self.itemPositions ) )
end

/*
	Adds items from item positions into their slot and repositions/stacks if user did that from
	saved text file
*/
function PANEL:loadItems( dontSave )
	self.fname = "itempositions_" .. Pointshop2.CalculateServerHash( ) .. self.categoryName .. ".txt"
	
	self.itemPositions = {}
	if file.Exists( self.fname, "DATA" ) then
		self.itemPositions = util.JSONToTable( file.Read( self.fname, "DATA" ) or "[]" )
	end
	
	--Step 1: Add items with saved positions
	local addedItems = {}
	for _, item in pairs( self.itemsTbl ) do
		item.id = tonumber( item.id )
		if self.itemPositions and self.itemPositions[item.id] then
			local panelPos = self.itemPositions[item.id]
			if panelPos then
				local slots = self:GetChildren( )
				if slots[panelPos] and slots[panelPos]:addItem( item ) then
					table.insert( addedItems, item )
				end
			end
		end
	end
	
	--Step 2: Add new items that dont have saved positions
	for _, item in pairs( self.itemsTbl ) do
		if table.HasValue( addedItems, item ) then
			continue
		end
		
		for k, slot in pairs( self:GetChildren( ) ) do
			if slot:addItem( item ) then
				break
			end
		end
	end
	
	if not dontSave then
		--Step 3: Save positions
		self:savePositions( )
	end
end

function PANEL:itemRemoved( itemId )
	for k, item in pairs( self.itemsTbl ) do
		if item.id == itemId then
			self.itemsTbl[k] = nil
		end
	end
	
	for k, slot in pairs( self:GetChildren( ) ) do
		if slot:itemRemoved( itemId ) then
			break --found and removed the item
		end 
	end
end

function PANEL:itemAdded( item ) 
	if not table.HasValue( self.itemsTbl, item ) then
		table.insert( self.itemsTbl, item )
	end
	
	--Check if we already have the item (predicted)
	for k, slot in pairs( self:GetChildren( ) ) do
		if slot:containsItem( item ) then
			return true
		end
	end
	
	--Try to add to cached position
	item.id = tonumber( item.id )
	if self.itemPositions and self.itemPositions[item.id] then
		local panelPos = self.itemPositions[item.id]
		if panelPos then
			local slots = self:GetChildren( )
			if slots[panelPos]:addItem( item ) then
				return true
			end
		end
	end
	
	--Find next free slot
	for k, slot in pairs( self:GetChildren( ) ) do
		if slot:addItem( item ) then
			return true
		end
	end
	return false
end

function PANEL:setItems( tblItems )
	self.itemsTbl = tblItems
	self.loadedItems = false
end

function PANEL:Paint( )
	surface.SetDrawColor( color_white )
	surface.DrawRect( 0, 0, self:GetSize( ) )
end

--Derma_Hook( PANEL, "Paint", "Paint", "ItemsContainer" )
derma.DefineControl( "DItemsContainer", "", PANEL, "DIconLayout" )