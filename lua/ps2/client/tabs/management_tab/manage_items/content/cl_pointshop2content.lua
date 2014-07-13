local SetupCategoryNode

local function AddCategoryNode( pnlContent, name, icon, parent )
	local node = parent:AddNode( name, icon )
	SetupCategoryNode( node, pnlContent )
	return node
end

function SetupCategoryNode( node, pnlContent )
	node.OnModified = function( )
		hook.Run( "PS2_SpawnlistContentChanged" )
	end
	
	node.SetupCopy = function( self, copy ) 
		SetupCategoryNode( copy, pnlContent )
		self:DoPopulate()
		copy.PropPanel = self.PropPanel:Copy()
		copy.PropPanel:SetVisible( false )
		copy.PropPanel:SetTriggerSpawnlistChange( true )
		copy.DoPopulate = function() end
	end
	
	node.DoRightClick = function( self )
		local menu = DermaMenu()
		menu:SetSkin( self:GetSkin( ).Name )
		local btn =menu:AddOption( "Edit", function()
			self:InternalDoClick(); 
			hook.Run( "PS2_OpenToolbox" )  
		end )
		btn:SetImage( "pointshop2/edit21.png" )
		btn.m_Image:SetSize( 16, 16 )
		
		btn = menu:AddOption( "New Category", function()
			local node = AddCategoryNode( pnlContent, "New Category", "pointshop2/folder62.png", self );
			self:SetExpanded( true )
			node:DoClick( )
			node:InternalDoClick()
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
		
		menu:Open()
	end
	
	node.DoPopulate = function( self )
		if not self.PropPanel then
			self.PropPanel = vgui.Create( "DPointshopContentContainer", pnlContent )
			self.PropPanel:Dock( FILL )
			self.PropPanel:DockMargin( 5, 5, 5, 5 )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( true )
			
			if not self.categoryInfo then return end 
			for k, itemClass in pairs( self.categoryInfo.items ) do
				itemClass = Pointshop2.GetItemClassByName( itemClass )
				local panel = vgui.Create( itemClass:GetPointshopIconControl( ) )
				self.PropPanel:Add( panel )
				panel:SetItemClass( itemClass )
				
				function panel:OpenMenu( )
					local menu = DermaMenu( )
					menu:SetSkin( self:GetSkin( ).Name )
					
					local btn = menu:AddOption( "Edit", function( )
						local creatorControl = Pointshop2.GetCreatorControlForClass( itemClass )
						
						local persistence = Pointshop2View:getInstance( ):getPersistenceForClass( itemClass )
						assert( persistence )
						if not creatorControl or persistence == "STATIC" then
							return Derma_Message( "This item is Lua defined and cannot be edited ingame. To configure it edit " .. itemClass.originFilePath, "Error" )
						end
						
						local creator = vgui.Create( creatorControl )
						creator:Center( )
						creator:MakePopup( )
						creator:SetItemBase( itemClass.name )
						creator:SetSkin( Pointshop2.Config.DermaSkin )
						creator:EditItem( persistence, itemClass )
					end )
					btn:SetImage( "pointshop2/pencil54.png" )
					btn.m_Image:SetSize( 16, 16 )
					
					menu:Open( )
				end
			end
		end
	end
	
	node.DoClick = function( self )
		self:DoPopulate( )		
		pnlContent:SwitchPanel( self.PropPanel )
	end
	
end


local function PopulateWithExistingCategories( pnlContent, node, dataNode )
	for id, subcategory in pairs( dataNode.subcategories ) do
		local newNode = AddCategoryNode( pnlContent, subcategory.self.label, subcategory.self.icon, node )
		PopulateWithExistingCategories( pnlContent, newNode, subcategory )
		newNode:SetExpanded( true )
		newNode.categoryInfo = subcategory
		newNode:DoPopulate( )
	end
end

local categoriesNode
hook.Add( "PS2_PopulateContent", "AddPointshopContent", function( pnlContent, tree, node )
	local node = AddCategoryNode( pnlContent, "Categories", "pointshop2/folder62.png", tree )
	function node:DoRightClick( )
		local menu = DermaMenu( )
		menu:SetSkin( self:GetSkin( ).Name )
		local btn = menu:AddOption( "New Category", function( )
			AddCategoryNode( pnlContent, "New Category", "pointshop2/folder62.png", node )
			node:SetExpanded( true )
			hook.Run( "PS2_SpawnlistContentChanged" )
			hook.Run( "PS2_OpenToolbox" )
		end )
		btn:SetImage( "pointshop2/category2.png" )
		btn.m_Image:SetSize( 16, 16 )
		menu:Open( )
	end
	node.immuneToChanges = true
	function node:DoPopulate( )
		self.PropPanel = vgui.Create( "DPanel", pnlContent )
		self.PropPanel:Dock( FILL )
		self.PropPanel:DockMargin( 5, 5, 5, 5 )
		self.PropPanel:SetVisible( false )
		function self.PropPanel:Paint( )
		end
		
		local lbl = vgui.Create( "DLabel", self.PropPanel )
		lbl:SetText( "Drag and Drop items into any of the subcategories to move them." )
		lbl:Dock( TOP )
		lbl:SetContentAlignment( 5 )
		lbl:SetFont( self:GetSkin( ).fontName )
		lbl:SizeToContents( )
		lbl:DockMargin( 0, 5, 0, 5 )
		
		local lbl = vgui.Create( "DLabel", self.PropPanel )
		lbl:SetText( "To create a new subcategory, right-click on the category's folder." )
		lbl:Dock( TOP )
		lbl:SetContentAlignment( 5 )
		lbl:SetFont( self:GetSkin( ).fontName )
		lbl:SizeToContents( )
		lbl:DockMargin( 0, 5, 0, 5 )
		
		local lbl = vgui.Create( "DLabel", self.PropPanel )
		lbl:SetText( "To take an item out of sale drop it into the Uncategorized Items category." )
		lbl:Dock( TOP )
		lbl:SetContentAlignment( 5 )
		lbl:SetFont( self:GetSkin( ).fontName )
		lbl:SizeToContents( )
		lbl:DockMargin( 0, 5, 0, 5 )
	end
	categoriesNode = node
	
	--Populate with existing stuff
	local dataNode = Pointshop2View:getInstance( ):getCategoryOrganization( )
	PopulateWithExistingCategories( pnlContent, node, { subcategories = dataNode } )
	node:SetExpanded( true )
	
	local node = AddCategoryNode( pnlContent, "Uncategorized Items", "pointshop2/folder62.png", tree )
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
			local panel = vgui.Create( itemClass:GetPointshopIconControl( ) )
			self.PropPanel:Add( panel )
			panel:SetItemClass( itemClass )
		end
	end
end )

hook.Add( "PS2_OnSaveSpawnlist", "SaveCategories", function( )
	local categoriesWithItems = {}
	
	local function recursiveAddCategory( node, tbl )
		local nodeInTable = {
			self = {
				label = node:GetText( ),
				icon = node:GetIcon( )
			},
			subcategories = { },
			items = { }
		}
		
		if node.ChildNodes then
			for k, childNode in pairs( node.ChildNodes:GetChildren( ) ) do
				recursiveAddCategory( childNode, nodeInTable.subcategories )
			end
		end
		
		--make sure it has all items it should contain
		node:DoPopulate( )
		for k, itemIcon in pairs( node.PropPanel:GetItems( ) ) do
			table.insert( nodeInTable.items, itemIcon.itemClass.className )
		end
		
		table.insert( tbl, nodeInTable )
	end
	for k, v in pairs( categoriesNode.ChildNodes:GetChildren( ) ) do
		recursiveAddCategory( v, categoriesWithItems )
	end
	
	Pointshop2View:getInstance( ):saveCategoryOrganization( categoriesWithItems )
end )