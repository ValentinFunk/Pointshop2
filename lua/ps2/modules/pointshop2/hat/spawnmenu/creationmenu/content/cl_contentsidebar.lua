if gmod.GetGamemode( ).IsSandboxDerived then return end

local pnlSearch = vgui.RegisterFile( "cl_contentsearch.lua" )


local PANEL = {}

function PANEL:Init()
	
	self.Tree = vgui.Create( "DTree", self );
	self.Tree:SetClickOnDragHover( true );
	self.Tree.OnNodeSelected = function( Tree, Node ) hook.Call( "PS2ContentSidebarSelection", GAMEMODE, self:GetParent(), Node ) end
	self.Tree:Dock( FILL )
	self.Tree:SetBackgroundColor( Color( 240, 240, 240, 255 ) )
	
	self:SetPaintBackground( false )
	
end

function PANEL:EnableModify()

	self.Search = vgui.CreateFromTable( pnlSearch, self )
	self:CreateSaveNotification()

	self.Toolbox = vgui.Create( "PS2PS2ContentSidebarToolbox", self )

	hook.Add( "OpenToolbox", "OpenToolbox", function()
		
		if ( !IsValid( self.Toolbox ) ) then return end
		
		self.Toolbox:Open()
	
	end )

end

function PANEL:CreateSaveNotification()

	local SavePanel = vgui.Create( "DButton", self )
		SavePanel:Dock( TOP )
		SavePanel:DockMargin( 32, 1, 32, 4 )
		SavePanel:SetIcon( "icon16/disk.png" )
		SavePanel:SetText( "Save changes" )
		SavePanel:SetVisible( false )
		
		SavePanel.DoClick = function()
		
			SavePanel:SlideUp( 0.2 )
			hook.Run( "OnSaveSpawnlist" );
		
		end
		
	hook.Add( "SpawnlistContentChanged", "ShowSaveButton", function()
	
		if ( SavePanel:IsVisible() ) then return end
		
		SavePanel:SlideDown( 0.2 )
		
	
	end )
		

end

vgui.Register( "PS2ContentSidebar", PANEL, "DPanel" )