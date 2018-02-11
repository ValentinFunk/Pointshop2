local SetupCategoryNode

local function addEditMenu( panel, itemClass )
	function panel:OpenMenu( )
		local persistence = Pointshop2View:getInstance( ):getPersistenceForClass( itemClass )
		if persistence == "STATIC" then
			timer.Simple( 0.5, function( )
				local m = Derma_Message( "The Item " .. itemClass.PrintName .. " is Lua defined and cannot be modified ingame. To modify it edit " .. itemClass.originFilePath, "Info" )
				m:MakePopup( )
				--m:DoModal( )
			end )
			return
		end
		if not persistence then
			error("Could not find persistence for class " .. itemClass.PrintName)
		end

		local menu = DermaMenu( )
		menu:SetSkin( self:GetSkin( ).Name )

		local btn = menu:AddOption( "Edit", function( )
			local creatorControl = Pointshop2.GetCreatorControlForClass( itemClass )

			local creator = vgui.Create( creatorControl )
			creator:Center( )
			creator:MakePopup( )
			creator:SetItemBase( itemClass.name )
			creator:SetSkin( Pointshop2.Config.DermaSkin )
			creator:EditItem( persistence, itemClass )
		end )
		btn:SetImage( "pointshop2/pencil54.png" )
		btn.m_Image:SetSize( 16, 16 )

		local btn = menu:AddOption( "Delete", function( )
			Derma_Query( "Do you really want to permanently delete this item?", "Confirm",
				/*"Yes and refund players", function( )
					Pointshop2View:getInstance( ):removeItem( itemClass, true )
				end,*/
				"Yes", function( )
					Pointshop2View:getInstance( ):removeItem( itemClass )
				end,
				"No", function( )
				end
			)
		end )
		btn:SetImage( "pointshop2/cross66.png" )
		btn.m_Image:SetSize( 16, 16 )

		local btn = menu:AddOption( "Restrict Server", function( )
			local frame = vgui.Create( "DSelectServers" )
			frame:MakePopup( )
			frame:Center( )
			frame:SetSelectedServers( itemClass.Servers or {} )
			function frame.OnSave( )
				local validServers = frame:GetSelectedIds( )
				Pointshop2View:getInstance( ):updateServerRestrictions( { itemClass.className }, validServers )
			end
		end )
		btn:SetImage( "pointshop2/rack1.png" )
		btn.m_Image:SetSize( 16, 16 )

		local btn = menu:AddOption( "Restrict Ranks", function( )
			local frame = vgui.Create( "DSelectRanks" )
			frame:MakePopup( )
			frame:Center( )
			frame:SetSelectedRanks( itemClass.Ranks or { } )
			function frame.OnSave( )
				local validRanks = frame:GetSelectedRanks( )
				Pointshop2View:getInstance( ):updateRankRestrictions( { itemClass.className }, validRanks )
			end
		end )
		btn:SetImage( "pointshop2/sign.png" )
		btn.m_Image:SetSize( 16, 16 )

		hook.Run( "PS2_ItemEditOptions", menu, itemClass )

		menu:Open( )
	end
end

local function AddCategoryNode( pnlContent, name, icon, parent, noEdit, rightClickNodeFunction, rightClickItemFunction )
	local node = parent:AddNode( name, icon )
	SetupCategoryNode( node, pnlContent, noEdit, rightClickNodeFunction, rightClickItemFunction )
	return node
end

function SetupCategoryNode( node, pnlContent, noEdit, rightClickNodeFunction, rightClickItemFunction )
	node.OnModified = function( )
		hook.Run( "PS2_SpawnlistContentChanged" )
	end

	/*node.SetupCopy = function( self, copy )
		SetupCategoryNode( copy, pnlContent, noEdit, rightClickNodeFunction, rightClickItemFunction )
		self:DoPopulate()
		copy.PropPanel = self.PropPanel:Copy()
		copy.PropPanel:SetVisible( false )
		copy.PropPanel:SetTriggerSpawnlistChange( true )
		copy.DoPopulate = function() end
	end*/

	node.DoPopulate = function( self )
		if not self.PropPanel then
			self.PropPanel = vgui.Create( "DPointshopContentContainer", pnlContent )
			self.PropPanel:Dock( FILL )
			self.PropPanel:DockMargin( 5, 5, 5, 5 )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( true )

			if not self.categoryInfo then return end
			for k, itemClassName in pairs( self.categoryInfo.items ) do
				itemClass = Pointshop2.GetItemClassByName( itemClassName )
				if not itemClass then
					KLogf( 2, "[ERROR] Invalid item class %s detected, database corrupted?", itemClassName )
					continue
				end
				local panel = vgui.Create( itemClass:GetConfiguredIconControl( ) )
				self.PropPanel:Add( panel )
				panel:SetItemClass( itemClass )
				panel.isAdminPnl = true

				if noEdit then
					panel.noEditMode = true
				else
					addEditMenu( panel, itemClass )
				end
				if rightClickItemFunction then
					panel.OpenMenu = rightClickItemFunction
				end
			end
		end
	end

	node.DoClick = function( self )
		self:DoPopulate( )
		pnlContent:SwitchPanel( self.PropPanel )
		hook.Run( "PS2_CategorySelected", self, self.categoryInfo )
	end

	if not noEdit then
		node.DoRightClick = function( self )
			local menu = DermaMenu()
			menu:SetSkin( self:GetSkin( ).Name )
			local subMenu = menu:AddSubMenu( "Create Item Here")
			subMenu:SetDisabled(not self.categoryInfo)
			
			for k, mod in pairs( Pointshop2.Modules ) do
				if not mod.Blueprints or #mod.Blueprints == 0 then
					continue
				end

				for _, itemInfo in pairs( mod.Blueprints ) do
					local iconButton = subMenu:AddOption( itemInfo.label, function() 
						self:InternalDoClick();
						if not self.categoryInfo then
							Derma_Message('Please press the save button before adding items.', 'Error')
							return
						end

						local creator = vgui.Create( itemInfo.creator )
						creator:MakePopup( )
						creator:SetItemBase( itemInfo.base )
						creator:SetSkin( Pointshop2.Config.DermaSkin )
						creator:InvalidateLayout( true )
						creator:Center( )
						creator:SetTargetCategoryId( self.categoryInfo.self.id )
					end)
					iconButton:SetTooltip( itemInfo.tooltip )
					iconButton:SetImage( itemInfo.icon )
					iconButton.m_Image:SetMaterial( Material( itemInfo.icon, "noclamp smooth" ) )
					iconButton.m_Image:SetSize( 16, 16 )
				end
				subMenu:AddSpacer()
			end
			subMenu:SetSkin( self:GetSkin( ).Name )
			-- subMenu:SetImage( "pointshop2/wizard.png" )
			-- subMenu.m_Image:SetSize( 16, 16 )

			menu:AddSpacer()

			local btn = menu:AddOption( "Edit", function()
				self:InternalDoClick();
				hook.Run( "PS2_OpenToolbox" )
				hook.Run( "PS2_ToolboxFocus" )
			end )
			btn:SetImage( "pointshop2/edit21.png" )
			btn.m_Image:SetSize( 16, 16 )

			btn = menu:AddOption( "New Category", function()
				local node = AddCategoryNode( pnlContent, "New Category", "pointshop2/folder62.png", self, noEdit, rightClickNodeFunction, rightClickItemFunction );
				self:SetExpanded( true )
				self:InstallDraggable(node)
				timer.Simple( 0.1, function( )
					node:DoClick( )
					node:InternalDoClick()
					hook.Run( "PS2_ToolboxFocus" )
				end )
				hook.Run( "PS2_SpawnlistContentChanged" )
				hook.Run( "PS2_OpenToolbox" )
			end )
			btn:SetImage( "pointshop2/category2.png" )
			btn.m_Image:SetSize( 16, 16 )

			btn = menu:AddOption( "Delete", function()
				print( self.PropPanel:GetCount( ), self.ChildNodes and #self.ChildNodes:GetChildren( ) )
				if self.PropPanel:GetCount( ) > 0 or self.ChildNodes and #self.ChildNodes:GetChildren( ) > 0 then
					return Derma_Message( "Please clear the category of all items and subcategories before deleting it", "Error" )
				end
				node:GetParentNode( ):DoClick( )
				node:Remove( )
				hook.Run( "PS2_SpawnlistContentChanged" )
			end )
			btn:SetImage( "pointshop2/category1.png" )
			btn.m_Image:SetSize( 16, 16 )
			btn.m_Image:SetSize( 16, 16 )

			menu:Open()
		end
	end
	if rightClickNodeFunction then
		node.DoRightClick = rightClickNodeFunction
	end
end

local function treeNodeItemReceiver( self, Drops, bDoDrop, Command, x, y )
	local closest = self:GetClosestChild( x, y )
	if self.specialNode or closest.specialNode then return end -- prevent dropping items onto invalid item holders (not for sale category, shop category)

	if ( !IsValid( closest ) ) then
		return self:DropAction_Simple( Drops, bDoDrop, Command, x, y )
	end

	local x, y = closest:GetPos()
	local w, h = closest:GetSize( )
	self:SetDropTarget( x, y, w, h )

	if ( table.HasValue( Drops, closest ) ) then return end
	if ( !bDoDrop ) then return end

	for k, v in pairs( Drops ) do
		-- Don't drop one of our parents onto us
		-- because we'll be sucked into a vortex
		if ( v:IsOurChild( self ) ) then continue end

		v = v:OnDrop( self )

		if not closest.PropPanel then
			closest:DoPopulate()
		end
		v:SetParent( closest.PropPanel.IconList )
	end
	self:OnModified()
end

local function PopulateWithExistingCategories( pnlContent, node, dataNode, noEdit, rightClickNodeFunction, rightClickItemFunction )
	for id, subcategory in pairs( dataNode.subcategories ) do
		local newNode = AddCategoryNode( pnlContent, subcategory.self.label, subcategory.self.icon, node, noEdit, rightClickNodeFunction, rightClickItemFunction )
		PopulateWithExistingCategories( pnlContent, newNode, subcategory, noEdit, rightClickNodeFunction, rightClickItemFunction )
		newNode:SetExpanded( true )
		newNode.categoryInfo = subcategory
		newNode:DoPopulate( )
	end
end

-- ALlow items to be dropped directly onto the child nodes of this node, placing them in the content panel
local function AllowItemDropping( node )
	function node:InstallDraggable( node )
		DTree_Node.InstallDraggable( self, node )
		self.ChildNodes:Receiver( "SandboxContentPanel", treeNodeItemReceiver )

		AllowItemDropping( node )
	end
end

Pointshop2.nodeToSelectText = nil
hook.Add( "PS2_PopulateContent", "AddPointshopContent", function( pnlContent, tree, node, noEdit, rightClickNodeFunction, rightClickItemFunction )
	local nodeToSelect
	local old = tree.OnNodeSelected
	function tree:OnNodeSelected( node )
		old( self, node )
		nodeToSelect = node
	end
	hook.Add( "PS2_PreReload", tree, function( )
		if IsValid( nodeToSelect ) then
			Pointshop2.nodeToSelectText = nodeToSelect:GetText( )
		end
	end )

	-- Allow dropping items into uncategorized
	AllowItemDropping(tree.RootNode)
	function tree.RootNode:OnModified( )
		hook.Run( "PS2_SpawnlistContentChanged" )
	end

	local categoriesNode = AddCategoryNode( pnlContent, "Shop Categories", "pointshop2/folder62.png", tree )
	categoriesNode:SetDraggableName( "CustomContent" )
	categoriesNode.specialNode = true
	function categoriesNode:DoRightClick( )
		local menu = DermaMenu( )
		menu:SetSkin( self:GetSkin( ).Name )
		local btn = menu:AddOption( "New Category", function( )
			local n2 = AddCategoryNode( pnlContent, "New Category", "pointshop2/folder62.png", categoriesNode )
			categoriesNode:SetExpanded( true )
			categoriesNode:InstallDraggable(n2)
			timer.Simple( 0.1, function( )
				n2:DoClick( )
				n2:InternalDoClick()
				hook.Run( "PS2_ToolboxFocus" )
			end )
			hook.Run( "PS2_SpawnlistContentChanged" )
			hook.Run( "PS2_OpenToolbox" )
		end )
		btn:SetImage( "pointshop2/category2.png" )
		btn.m_Image:SetSize( 16, 16 )
		menu:Open( )
	end
	categoriesNode.immuneToChanges = true
	function categoriesNode:DoPopulate( )
		self.PropPanel = vgui.Create( "DPanel", pnlContent )
		self.PropPanel:Dock( FILL )
		self.PropPanel:DockMargin( 5, 5, 5, 5 )
		self.PropPanel:SetVisible( false )
		function self.PropPanel:Paint( )
		end
		function self.PropPanel:GetItems( )
			return {}
		end

		local info = vgui.Create( "DInfoPanel", self.PropPanel )
		info:Dock( TOP )
		info:SetInfo( "Categories",
[[Drag and Drop items into any of the subcategories to move them.
To create a new subcategory, right-click on the category's folder.
To take an item out of sale drop it into the "Not for sale Items" Category.
]] )
		info:DockMargin( 5, 5, 5, 5 )

		local info = vgui.Create( "DInfoPanel", self.PropPanel )
		info:Dock( TOP )
		info:SetInfo( "Moving Items",
[[
When moving items first hover over the entry in the tree on the left, then drop them into place in the grey area on the right.
]] )
		info:DockMargin( 5, 5, 5, 5 )
	end

	--Populate with existing stuff
	local dataNode = Pointshop2View:getInstance( ):getShopCategory( )
	PopulateWithExistingCategories( pnlContent, categoriesNode, dataNode, noEdit, rightClickNodeFunction, rightClickItemFunction )
	categoriesNode:SetExpanded( true )

	local notForSaleNode = AddCategoryNode( pnlContent, "Not for sale Items", "pointshop2/circle14.png", tree, noEdit, rightClickNodeFunction, rightClickItemFunction )
	notForSaleNode.immuneToChanges = true
	notForSaleNode.specialNode = true
	notForSaleNode:SetDraggableName( "CustomContent" )
	function notForSaleNode:DoRightClick( )
		local menu = DermaMenu( )
		menu:SetSkin( self:GetSkin( ).Name )
		local btn = menu:AddOption( "New Category", function( )
			local n2 = AddCategoryNode( pnlContent, "New Category", "pointshop2/folder62.png", notForSaleNode )
			notForSaleNode:SetExpanded( true )
			notForSaleNode:InstallDraggable(n2)
			timer.Simple( 0.1, function( )
				n2:DoClick( )
				n2:InternalDoClick()
				hook.Run( "PS2_ToolboxFocus" )
			end )
			hook.Run( "PS2_SpawnlistContentChanged" )
			hook.Run( "PS2_OpenToolbox" )
		end )
		btn:SetImage( "pointshop2/category2.png" )
		btn.m_Image:SetSize( 16, 16 )
		menu:Open( )
	end

	local old = notForSaleNode.DoPopulate
	function notForSaleNode:DoPopulate( )
		self.PropPanel = vgui.Create( "DPanel", pnlContent )
		self.PropPanel:Dock( FILL )
		self.PropPanel:DockMargin( 5, 5, 5, 5 )
		self.PropPanel:SetVisible( false )
		function self.PropPanel:Paint( )
		end
		function self.PropPanel:GetItems( )
			return {}
		end

		local info = vgui.Create( "DInfoPanel", self.PropPanel )
		info:Dock( TOP )
		info:SetInfo( "Not for Sale items",
[[You can use this to organize items that are currently out of sale (events, special promotions, crate/drop items).

Categories and organization of items are saved, but the categories will not appear in the shop.
]] )
		info:DockMargin( 5, 5, 5, 5 )
	end
	local dataNode = Pointshop2View:getInstance( ):getNoSaleCategory( )
	PopulateWithExistingCategories( pnlContent, notForSaleNode, dataNode, noEdit, rightClickNodeFunction, rightClickItemFunction )
	notForSaleNode:SetExpanded( true )

	local node = AddCategoryNode( pnlContent, "Uncategorized Items", "pointshop2/folder62.png", tree, noEdit, rightClickNodeFunction, rightClickItemFunction )
	node:SetDraggableName( "CustomContent" )
	function node:DoRightClick( )
	end
	node.immuneToChanges = true
	function node:DoPopulate( )
		if self.PropPanel then
			return
		end

		self.PropPanel = vgui.Create( "DPointshopContentContainer", pnlContent )
		self.PropPanel:DockMargin( 5, 5, 5, 5 )
		self.PropPanel:SetVisible( false )
		self.PropPanel:Dock( FILL )
		self.PropPanel:SetTriggerSpawnlistChange( true )

		for _, itemClass in pairs(  Pointshop2View:getInstance( ):getUncategorizedItems( ) ) do
			local panel = vgui.Create( itemClass:GetConfiguredIconControl( ) )
			panel.isAdminPnl = true
			self.PropPanel:Add( panel )
			panel:SetItemClass( itemClass )
			addEditMenu( panel, itemClass )
		end
	end

	local gotNode
	local function selectNode( node )
		for _, node in pairs( node.ChildNodes:GetChildren( ) ) do
			node:SetExpanded( true )
			if node:HasChildren() then
				selectNode( node )
			end
			if node:GetText( ) == Pointshop2.nodeToSelectText then
				gotNode = true
				timer.Simple( 0, function( )
					node:InternalDoClick( )
					node:InternalDoClick( )
				end )
			end
		end
	end

	if Pointshop2.nodeToSelectText then
		selectNode( tree.RootNode )
	end

	if not gotNode then
		timer.Simple( 0.1, function( )
			tree.RootNode.ChildNodes:GetChildren( )[1]:InternalDoClick( )
			tree.RootNode.ChildNodes:GetChildren( )[1]:InternalDoClick( )
		end )
	end


	hook.Add( "PS2_OnSaveSpawnlist", tree, function()
		Pointshop2.DoSaveCategories( categoriesNode, notForSaleNode )
	end )
end )
