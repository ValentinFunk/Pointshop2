local PANEL = {}

--[[---------------------------------------------------------
   Name: Init
-----------------------------------------------------------]]
function PANEL:Init()

	self:SetOpenSize( 200 )
	self:DockPadding( 5, 5, 5, 5 )
		
	local panel = vgui.Create( "DPanel", self )
	panel:Dock( TOP )
	panel:SetSize( 24, 24 )
	panel:DockPadding( 2, 2, 2, 2 )
	function panel:Paint( ) end
		
	local panel = vgui.Create( "DPanel", self )
	panel:Dock( FILL )
	panel:DockPadding( 5, 5, 5, 5 )
	function panel:Paint( ) end
	
	local label = vgui.Create( "DTextEntry", panel )
	label:Dock( TOP )
	
	local icons = vgui.Create( "DPointshopIconBrowser", panel )
	icons:Fill( )
	icons:Dock( FILL )
	
	--
	-- If we select a node from the sidebar, update the text/icon/actions in the toolbox (at the bottom)
	--
	hook.Add( "PS2_ContentSidebarSelection", self, function( _self, pnlContent, node )
		label:SetText( node:GetText() )
		icons:SelectIcon( node:GetIcon() )
		icons:ScrollToSelected()
		
		label.OnChange = function()
			if node.immuneToChanges then return end 
			
			node:SetText( label:GetText() )
			hook.Run( "PS2_SpawnlistContentChanged" )
		end
		
		icons.OnChange = function()
			if node.immuneToChanges then return end 
			
			node:SetIcon( icons:GetSelectedIcon() )
			hook.Run( "PS2_SpawnlistContentChanged" )
		end
	end )
	
	hook.Add( "PS2_ToolboxFocus", self, function( _self )
		label:SelectAllOnFocus()
		label:RequestFocus()
		label:SelectAll()
		hook.Run( "OnTextEntryGetFocus", label )
	end )
end

function PANEL:Think()
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopMenuButton" )

derma.DefineControl( "DPointshopContentSidebarToolbox", "", PANEL, "DDrawer" )

local PANEL = {}

function PANEL:Init( )
	self.IconLayout:SetSpaceX( 5 )
	self.IconLayout:SetSpaceY( 5 )
end

function PANEL:Fill( )
	self.Filled = true
	if ( self.m_bManual ) then return end
	
	if ( !local_IconList ) then
		 local_IconList = file.Find( "materials/pointshop2/*.png", "GAME" )
	end
	
	for k, v in SortedPairs( local_IconList ) do			
		timer.Simple( k * 0.001, function()
			if ( !IsValid( self ) ) then return end
			if ( !IsValid( self.IconLayout ) ) then return end
	
			local btn = self.IconLayout:Add( "DImageButton" )
			btn.FilterText = string.lower( v )
			btn:SetOnViewMaterial( "materials/pointshop2/" .. v )
			btn:SetStretchToFit( true )
			btn:SetSize( 22, 22 )
			btn:SetPos( -22, -22 )
			
			btn.DoClick = function()
				self.m_pSelectedIcon = btn
				self.m_strSelectedIcon = btn:GetImage()
				self:OnChangeInternal()
			end
			
			btn.Paint = function( btn, w, h )
				if ( self.m_pSelectedIcon != btn ) then 
					btn.m_Image:SetImageColor( color_white )
					return 
				end
				
				btn.m_Image:SetImageColor( self:GetSkin( ).Highlight or color_white )
				derma.SkinHook( "Paint", "Selection", btn, w, h )
			end
			
			if ( !self.m_pSelectedIcon || self.m_strSelectedIcon == btn:GetImage() ) then
				self.m_pSelectedIcon = btn
			end
		
			self.IconLayout:Layout()
		end )
	end
end

Derma_Hook( PANEL, "Paint", "Paint", "InnerPanel" )

derma.DefineControl( "DPointshopIconBrowser", "", PANEL, "DIconBrowser" )
