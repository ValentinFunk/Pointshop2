local PANEL = {}

AccessorFunc( PANEL, "m_pSelectedPanel", 		"SelectedPanel" )

--[[---------------------------------------------------------
   Name: Paint
-----------------------------------------------------------]]
function PANEL:Init()
		
	self:SetPaintBackground( false )
	
	self.CategoryTable = {}	
	
	self.ContentNavBar = vgui.Create( "PS2ContentSidebar", self );
	self.ContentNavBar:Dock( LEFT );
	self.ContentNavBar:SetSize( 190, 10 );
	self.ContentNavBar:DockMargin( 0, 0, 4, 0 )
	
	
	self.HorizontalDivider = vgui.Create( "DHorizontalDivider", self );	
	self.HorizontalDivider:Dock( FILL );
	self.HorizontalDivider:SetLeftWidth( 175 )
	self.HorizontalDivider:SetLeftMin( 175 )
	self.HorizontalDivider:SetRightMin( 450 )
	
	self.HorizontalDivider:SetLeft( self.ContentNavBar );
	
end

function PANEL:EnableModify()
	self.ContentNavBar:EnableModify()
end

function PANEL:CallPopulateHook( HookName )

	hook.Call( HookName, GAMEMODE, self, self.ContentNavBar.Tree, self.OldSpawnlists )

end

function PANEL:SwitchPanel( panel )

	if ( IsValid( self.SelectedPanel ) ) then
		self.SelectedPanel:SetVisible( false );
		self.SelectedPanel = nil;
	end
	
	self.SelectedPanel = panel

	self.SelectedPanel:Dock( FILL )
	self.SelectedPanel:SetVisible( true )
	self:InvalidateParent()
	
	self.HorizontalDivider:SetRight( self.SelectedPanel );
	
end


vgui.Register( "DPS2_SpawnmenuContentPanel", PANEL, "DPanel" )



local function CreateContentPanel()

	local ctrl = vgui.Create( "DPS2_SpawnmenuContentPanel" )

	ctrl.OldSpawnlists = ctrl.ContentNavBar.Tree:AddNode( "#spawnmenu.category.browse", "icon16/cog.png" )
	
	ctrl:EnableModify()
	hook.Call( "PS2_PopulatePropMenu", GAMEMODE )
	ctrl:CallPopulateHook( "PS2_SpawnMenu_PopulateContent" );

		
	ctrl.OldSpawnlists:MoveToFront()
	ctrl.OldSpawnlists:SetExpanded( true )

	return ctrl

end

local existing = spawnmenu.GetCreationTabs()
if not existing["#spawnmenu.content_tab"] then
	spawnmenu.AddCreationTab( "#spawnmenu.content_tab", CreateContentPanel, "icon16/application_view_tile.png", -10 )
end