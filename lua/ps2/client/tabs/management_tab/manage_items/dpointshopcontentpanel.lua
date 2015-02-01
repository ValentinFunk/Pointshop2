local PANEL = {}

AccessorFunc( PANEL, "m_pSelectedPanel", 		"SelectedPanel" )

--[[---------------------------------------------------------
   Name: Paint
-----------------------------------------------------------]]
function PANEL:Init()
		
	self:SetPaintBackground( false )
	
	self.CategoryTable = {}
	
	self.ContentNavBar = vgui.Create( "DPointshopContentSidebar", self );
	self.ContentNavBar:Dock( LEFT );
	self.ContentNavBar:SetSize( 190, 10 );
	self.ContentNavBar:DockMargin( 10, 0, 4, 0 )
	
end

function PANEL:EnableModify()
	self.ContentNavBar:EnableModify()
end

function PANEL:CallPopulateHook( HookName, noEdit, rightClickNodeFunction, rightClickItemFunction )

	hook.Call( HookName, GAMEMODE, self, self.ContentNavBar.Tree, self.OldSpawnlists, noEdit, rightClickNodeFunction, rightClickItemFunction )

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

end


derma.DefineControl( "DPointshopContentPanel", "", PANEL, "DPanel" )