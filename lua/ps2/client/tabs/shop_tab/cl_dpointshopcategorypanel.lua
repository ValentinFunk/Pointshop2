local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self.title = vgui.Create( "DLabel", self )
	self.title:Dock( TOP )
	self.title:DockMargin( 8, 0, 5, 0 )
	
	self.layout = vgui.Create( "DTileLayout", self )
	self.layout:Dock( TOP )
	
	self.layout:SetBaseSize( 16 )
	self.layout:SetSpaceY( 5 )
	self.layout:SetSpaceX( 5 )
end

function PANEL:AddItems( )
	self.itemsAdded = true
	for _, itemClassName in pairs( self.category.items ) do
		local itemClass = Pointshop2.GetItemClassByName( itemClassName )
		if not itemClass then
			KLogf( 2, "[ERROR] Invalid item class %s detected, database corrupted?", itemClassName )
			continue
		end
		--timer.Simple( _ / 10, function( ) 
			if IsValid( self ) and IsValid( self.layout ) then
				local itemIcon = vgui.Create( itemClass:GetConfiguredIconControl( ), self.layout )
				itemIcon:SetItemClass( itemClass )
				itemIcon.drawPrices = true
			end
		--end )
	end
end

function PANEL:Populate( )
	self:AddItems( )
	self:AddSubcategories( )
	for k, v in pairs( self.category.subcategories ) do
		v.panel:Populate( )
	end
end

function PANEL:AddSubcategories( )
	for _, subcategory in pairs( self.category.subcategories ) do
		--timer.Simple( _ / 10, function( )
			local subcategoryPanel = vgui.Create( "DPointshopCategoryPanel", self.layout )
			subcategoryPanel.OwnLine = true
			subcategoryPanel:SetCategory( subcategory, self.depth + 1 )
			subcategory.panel = subcategoryPanel
		--end )
	end
end

function PANEL:SetCategory( category, depth )
	depth = depth or 0
	
	if depth == 3 and #category.subcategories > 0 then
		--Max depth reached
		KLogf( 3, "[Pointshop2][WARN] Reached max category depth for category %s, flattening all subcategories", category.self.label )
		
		local function flatten( subcategory, tbl )
			tbl = tbl or {}
			for k, v in pairs( subcategory.subcategories ) do
				flatten( v, tbl )
				subcategory.subcategories[k] = nil
			end
			for k, v in pairs( subcategory.items ) do
				table.insert( tbl, v )
			end
			subcategory.items = tbl
		end
		flatten( category )
	end
	
	self.depth = depth
	self.category = category
	
	self.title:SetText( category.self.label )
	
	derma.SkinHook( "Layout", "CategoryPanelLevel" .. self.depth, self )
	Derma_Hook( self, "Paint", "Paint", "CategoryPanelLevel" .. self.depth )
end

function PANEL:PerformLayout( )
	if self.depth > 0 then
		local w, h = self:GetParent( ):GetSize( )
		self:SetWide( w )
	end	
	self.layout:PerformLayout( true )
	-- self.layout:LayoutTiles()
	-- print(self.layout:GetTall())
	self:SizeToChildren( false, true )
	local w, h = self:ChildrenSize();
	self:SetHeight( h + 8 )
end

function PANEL:Paint( w, h )
end

derma.DefineControl( "DPointshopCategoryPanel", "", PANEL, "DPanel" )
print("hi")