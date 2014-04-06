local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self:SetSize( 650, 400 )
	
	self:SetTitle( "Select a Playermodel" )
	
	local window = self
	window.skin = 0
	window.bodygroups = "0"
	
	local mdl = window:Add( "DModelPanel" )
	mdl:Dock( FILL )
	mdl:SetFOV( 36 )
	mdl:SetCamPos( Vector( 0, 0, 0 ) )
	mdl:SetDirectionalLight( BOX_RIGHT, Color( 255, 160, 80, 255 ) )
	mdl:SetDirectionalLight( BOX_LEFT, Color( 80, 160, 255, 255 ) )
	mdl:SetAmbientLight( Vector( -64, -64, -64 ) )
	mdl:SetAnimated( true )
	mdl.Angles = Angle( 0, 0, 0 )
	mdl:SetLookAt( Vector( -100, 0, -22 ) )

	local sheet = window:Add( "DPropertySheet" )
	sheet:Dock( RIGHT )
	sheet:SetSize( 430, 0 )
	sheet.tabScroller:SetTall( 50 )

	local PanelSelect = sheet:Add( "DPanelSelect" )

	for name, model in SortedPairs( player_manager.AllValidModels() ) do

		local icon = vgui.Create( "SpawnIcon" )
		icon:SetModel( model )
		icon:SetSize( 64, 64 )
		icon:SetTooltip( name )
		icon.playermodel = name

		PanelSelect:AddPanel( icon )

	end

	local modelSheet = sheet:AddSheet( "Model", PanelSelect )
	derma.SkinHook( "Layout", "PropertySheetSheet", self, modelSheet )

	local bdcontrols = window:Add( "DPanel" )
	bdcontrols:DockPadding( 8, 8, 8, 8 )

	local bdcontrolspanel = bdcontrols:Add( "DPanelList" )
	bdcontrolspanel:EnableVerticalScrollbar( true )
	bdcontrolspanel:Dock( FILL )

	local bgtab = sheet:AddSheet( "Bodygroups", bdcontrols )
	derma.SkinHook( "Layout", "PropertySheetSheet", self, bgtab )

	-- Helper functions

	local function MakeNiceName( str )
		local newname = {}

		for _, s in pairs( string.Explode( "_", str ) ) do
			if ( string.len( s ) == 1 ) then table.insert( newname, string.upper( s ) ) continue end
			table.insert( newname, string.upper( string.Left( s, 1 ) ) .. string.Right( s, string.len( s ) - 1 ) ) -- Ugly way to capitalize first letters.
		end

		return string.Implode( " ", newname )
	end

	local function PlayPreviewAnimation( panel, playermodel )

		if ( !panel or !IsValid( panel.Entity ) ) then return end

		local default_animations = { "idle_all_01", "menu_walk" }
		local anims = list.Get( "PlayerOptionsAnimations" )
		local anim = default_animations[ math.random( 1, #default_animations ) ]
		if ( anims[ playermodel ] ) then
			anims = anims[ playermodel ]
			anim = anims[ math.random( 1, #anims ) ]
		end

		local iSeq = panel.Entity:LookupSequence( anim )
		if ( iSeq > 0 ) then panel.Entity:ResetSequence( iSeq ) end

	end

	-- Updating

	local function UpdateBodyGroups( pnl, val )
		if ( pnl.type == "bgroup" ) then
			mdl.Entity:SetBodygroup( pnl.typenum, math.Round( val ) )

			local str = string.Explode( " ", window.bodygroups )
			if ( #str < pnl.typenum + 1 ) then for i = 1, pnl.typenum + 1 do str[ i ] = str[ i ] or 0 end end
			str[ pnl.typenum + 1 ] = math.Round( val )
			
			window.bodygroups = table.concat( str, " " )
			window:OnChange( )
		elseif ( pnl.type == "skin" ) then
			mdl.Entity:SetSkin( math.Round( val ) )
			window.skin = math.Round( val )
			window:OnChange( )
		end
	end

	local function RebuildBodygroupTab()
		bdcontrolspanel:Clear()
		
		bgtab.Tab:SetVisible( false )

		local nskins = mdl.Entity:SkinCount() - 1
		if ( nskins > 0 ) then
			local skins = vgui.Create( "DNumSlider" )
			skins:Dock( TOP )
			skins:SetText( "Skin" )
			skins:SetDark( true )
			skins:SetTall( 50 )
			skins:SetDecimals( 0 )
			skins:SetMax( nskins )
			skins:SetValue( window.skin )
			skins.type = "skin"
			skins.OnValueChanged = UpdateBodyGroups
			
			bdcontrolspanel:AddItem( skins )

			mdl.Entity:SetSkin( window.skin )
			
			bgtab.Tab:SetVisible( true )
		end

		local groups = string.Explode( " ", window.bodygroups )
		for k = 0, mdl.Entity:GetNumBodyGroups() - 1 do
			if ( mdl.Entity:GetBodygroupCount( k ) <= 1 ) then continue end

			local bgroup = vgui.Create( "DNumSlider" )
			bgroup:Dock( TOP )
			bgroup:SetText( MakeNiceName( mdl.Entity:GetBodygroupName( k ) ) )
			bgroup:SetDark( true )
			bgroup:SetTall( 50 )
			bgroup:SetDecimals( 0 )
			bgroup.type = "bgroup"
			bgroup.typenum = k
			bgroup:SetMax( mdl.Entity:GetBodygroupCount( k ) - 1 )
			bgroup:SetValue( groups[ k + 1 ] or 0 )
			bgroup.OnValueChanged = UpdateBodyGroups
			
			bdcontrolspanel:AddItem( bgroup )

			mdl.Entity:SetBodygroup( k, groups[ k + 1 ] or 0 )
			
			bgtab.Tab:SetVisible( true )
		end
	end

	function PanelSelect:OnActivePanelChanged( old, new )
		if ( old != new ) then -- Only reset if we changed the model
			window.bodygroups = "0"
			window.skin = 0
		end

		local model = new.playermodel
		local modelname = player_manager.TranslatePlayerModel( model )
		util.PrecacheModel( modelname )
		mdl:SetModel( modelname )
		mdl.Entity:SetPos( Vector( -100, 0, -61 ) )

		PlayPreviewAnimation( mdl, model )
		RebuildBodygroupTab()
		
		window.selectedModel = modelname
		window:OnChange( )
	end
	PanelSelect:SelectPanel( PanelSelect.Items[1] )

	-- Hold to rotate

	function mdl:DragMousePress()
		self.PressX, self.PressY = gui.MousePos()
		self.Pressed = true
	end

	function mdl:DragMouseRelease() self.Pressed = false end

	function mdl:LayoutEntity( Entity )
		if ( self.bAnimated ) then self:RunAnimation() end

		if ( self.Pressed ) then
			local mx, my = gui.MousePos()
			self.Angles = self.Angles - Angle( 0, ( self.PressX or mx ) - mx, 0 )
			
			self.PressX, self.PressY = gui.MousePos()
		end

		Entity:SetAngles( self.Angles )
	end
end

function PANEL:OnChange( )
	--for overwriting
end

vgui.Register( "DPlayerModelSelector", PANEL, "DFrame" )

list.Set( "PlayerOptionsAnimations", "gman", { "menu_gman" } )

list.Set( "PlayerOptionsAnimations", "hostage01", { "idle_all_scared" } )
list.Set( "PlayerOptionsAnimations", "hostage02", { "idle_all_scared" } )
list.Set( "PlayerOptionsAnimations", "hostage03", { "idle_all_scared" } )
list.Set( "PlayerOptionsAnimations", "hostage04", { "idle_all_scared" } )

list.Set( "PlayerOptionsAnimations", "zombine", { "menu_zombie_01" } )
list.Set( "PlayerOptionsAnimations", "corpse", { "menu_zombie_01" } )
list.Set( "PlayerOptionsAnimations", "zombiefast", { "menu_zombie_01" } )
list.Set( "PlayerOptionsAnimations", "zombie", { "menu_zombie_01" } )
list.Set( "PlayerOptionsAnimations", "skeleton", { "menu_zombie_01" } )

list.Set( "PlayerOptionsAnimations", "combine", { "menu_combine" } )
list.Set( "PlayerOptionsAnimations", "combineprison", { "menu_combine" } )
list.Set( "PlayerOptionsAnimations", "combineelite", { "menu_combine" } )
list.Set( "PlayerOptionsAnimations", "police", { "menu_combine" } )
list.Set( "PlayerOptionsAnimations", "policefem", { "menu_combine" } )

list.Set( "PlayerOptionsAnimations", "css_arctic", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_gasmask", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_guerilla", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_leet", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_phoenix", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_riot", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_swat", { "pose_standing_02", "idle_fist" } )
list.Set( "PlayerOptionsAnimations", "css_urban", { "pose_standing_02", "idle_fist" } )