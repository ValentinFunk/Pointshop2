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
	function SavePanel:Highlight( )
		local function flashButton( )
			self.Selected = true
			local setColor = function( p )
				if not IsValid( self ) then
					return
				end

				self.forcedCol = { ColorToHSV( self:GetSkin( ).Highlight ) }
				local standardCol = { ColorToHSV( self:GetSkin( ).ButtonColor ) }
				self.forcedCol = HSVToColor( unpack( {
					Lerp( p, standardCol[1], self.forcedCol[1] ),
					Lerp( p, standardCol[2], self.forcedCol[2] ),
					Lerp( p, standardCol[3], self.forcedCol[3] ),
				} ) )
				PrintTable( self.forcedCol )
			end

			LibK.tween( easing.inQuad, 0.2, function( p )
				if not IsValid( self ) then
					return
				end
				setColor( p )
			end )
			:Then( function( )
				return LibK.tween( easing.outQuad, 0.2, function( p )
					setColor( 1 - p )
				end )
			end )
			:Done( function( )
				if not IsValid( self ) then
					return
				end
				self.Selected = false
				self.forcedCol = nil
			end )
		end
		timer.Create( "PS2_FlashSaveBtn", 0.3, 3, flashButton )
		flashButton( )
	end
	SavePanel:Dock( TOP )
	SavePanel:DockMargin( 0, 1, 0, 4 )
	SavePanel:SetIcon( "pointshop2/floppy1.png" )
	SavePanel.m_Image:SetSize( 16, 16 )
	SavePanel:SetText( "Save changes" )
	SavePanel:SetVisible( false )
	SavePanel:SetFont( self:GetSkin( ).fontName )
	derma.SkinHook( "Layout", "PointshopMenuButton", SavePanel )
	function SavePanel:Paint( w, h )
		surface.SetDrawColor( self.forcedCol or self:GetSkin( ).ButtonColor )
		surface.DrawRect( 0, 0, w, h )
	end
	SavePanel.DoClick = function()
		SavePanel:SlideUp( 0.2 )
		hook.Run( "PS2_OnSaveSpawnlist" );
		hook.Run( "PS2_PreReload" )
	end
	hook.Add( "PS2_PreReload", SavePanel, function( SavePanel )
		if SavePanel:IsVisible( ) then
			SavePanel:SetVisible( false )
			-- SavePanel.DoClick( )
		end
	end )

	hook.Add( "PS2_SpawnlistContentChanged", self, function()
		if SavePanel:IsVisible( ) then
			return
		end
		SavePanel:Highlight( )
		SavePanel:SlideDown( 0.2 )
	end )


end

Derma_Hook( PANEL, "Paint", "Paint", "InnerPanel" )

derma.DefineControl( "DPointshopContentSidebar", "", PANEL, "DPanel" )
