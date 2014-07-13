local PANEL = {}

function PANEL:Init()
	self:DockPadding( 10, 10, 10, 10 )
	
	self.Tree = vgui.Create( "DTree", self );
	self.Tree:SetClickOnDragHover( true );
	self.Tree.OnNodeSelected = function( Tree, Node ) 
		hook.Call( "PS2_ContentSidebarSelection", GAMEMODE, self:GetParent(), Node )
	end
	self.Tree:Dock( FILL )
	self.Tree:SetBackgroundColor( Color( 240, 240, 240, 255 ) )
	
	self:SetPaintBackground( false )
	
	derma.SkinHook( "Layout", "PointshopContentSidebar", self )
end

function PANEL:EnableModify()
	self:CreateSaveNotification()

	self.Toolbox = vgui.Create( "DPointshopContentSidebarToolbox", self )
	self.Toolbox:Dock( BOTTOM )
	
	hook.Add( "PS2_OpenToolbox", self, function()
		
		if ( !IsValid( self.Toolbox ) ) then return end
		
		self.Toolbox:Open()
	
	end )

end

function PANEL:CreateSaveNotification()

	local SavePanel = vgui.Create( "DButton", self )
	SavePanel:Dock( TOP )
	SavePanel:DockMargin( 0, 1, 0, 4 )
	SavePanel:SetIcon( "pointshop2/floppy1.png" )
	SavePanel.m_Image:SetSize( 16, 16 )
	SavePanel:SetText( "Save changes" )
	SavePanel:SetVisible( false )
	SavePanel:SetFont( self:GetSkin( ).fontName )
	derma.SkinHook( "Layout", "PointshopMenuButton", SavePanel )
	Derma_Hook( SavePanel, "Paint", "Paint", "PointshopMenuButton" )
	SavePanel.DoClick = function()
		SavePanel:SlideUp( 0.2 )
		hook.Run( "PS2_OnSaveSpawnlist" );
	end
		
	hook.Add( "PS2_SpawnlistContentChanged", self, function()
		if SavePanel:IsVisible( ) then
			return
		end
		SavePanel:SlideDown( 0.2 )
	end )
		

end

Derma_Hook( PANEL, "Paint", "Paint", "InnerPanel" )

derma.DefineControl( "DPointshopContentSidebar", "", PANEL, "DPanel" )