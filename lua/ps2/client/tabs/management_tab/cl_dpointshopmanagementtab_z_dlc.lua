local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )

	local scroll = vgui.Create( "DScrollPanel", self )
	scroll:Dock( FILL )
	scroll:GetCanvas( ):DockPadding( 0, 0, 5, 5 )

	self:DockPadding( 10, 0, 10, 10 )

	local label = vgui.Create( "DLabel", scroll:GetCanvas( ) )
	label:SetText( "Available DLC" )
	label:SetColor( color_white )
	label:SetFont( self:GetSkin( ).TabFont )
	label:SizeToContents( )
	label:Dock( TOP )

	self.panels = vgui.Create( "DPanel", scroll:GetCanvas( ) )
	self.panels.Paint = function( a, w, h )
	end
	function self.panels:PerformLayout( )
		self:SizeToChildren( false, true )
	end
	self.panels:Dock( TOP )

	Promise.Resolve( )
	:Then( function( )
		local def = Deferred( )
		http.Fetch( "https://static.pointshop2.com/dlc.lua", function( body, len, headers, code )
			if code != 200 then
				return def:Reject( 'HTTP Error - No internet or server is down' )
			end

			local func = CompileString( body, "Pointshop 2", false )
			if not func then
				return def:Reject( "Your AntiCheat or similar is blocking CompileString" )
			elseif isstring( func ) then
				KLogf( 4, "[PS2] Lua error in DLC manifest: %s", func )
				return def:Reject( "Lua error in manifest" )
			else
				return def:Resolve( func( ) )
			end
		end, function( err )
			def:Reject( err )
		end )
		return def:Promise( )
	end )
	:Then( function( dlcList )
		if not IsValid( self ) then
			return
		end

		for realm, dlcs in pairs( dlcList ) do
			local modPanel = vgui.Create( "DPanel", self.panels )
			Derma_Hook( modPanel, "Paint", "Paint", "InnerPanel" )
			modPanel:DockMargin( 0, 5, 0, 5 )
			modPanel:DockPadding( 8, 8, 8, 8 )
			modPanel:Dock( TOP )
			function modPanel:PerformLayout( )
				if self.items then
					self.items:SizeToChildren( false, true )
				end
				self:SizeToChildren( false, true )
			end

			modPanel.label = vgui.Create( "DLabel", modPanel )
			modPanel.label:DockMargin( 0, -5, 0, 8 )
			modPanel.label:SetFont( self:GetSkin( ).SmallTitleFont )
			modPanel.label:SetText( realm )
			modPanel.label:SizeToContents( )
			modPanel.label:Dock( TOP )
			modPanel.label:SetColor( color_white )

			modPanel.label = vgui.Create( "DLabel", modPanel )
			modPanel.label:DockMargin( 0, -5, 0, 8 )
			modPanel.label:SetFont( self:GetSkin( ).fontName )
			modPanel.label:SetText( ( realm == "Official" and "Official DLC for Pointshop 2. Click on the icons to open the gmodstore page. Guranteed support." or "Pointshop 2 Addons created by third-party developers. Support provided by the respective authors." ) )
			modPanel.label:SizeToContents( )
			modPanel.label:Dock( TOP )

			modPanel.label = vgui.Create( "DLabel", modPanel )
			modPanel.label:DockMargin( 0, -5, 0, 8 )
			modPanel.label:SetFont( self:GetSkin( ).fontName )
			local count = #dlcs
			local owned = 0
			for k, v in pairs( dlcs ) do
				if v.isOwned( ) then
					owned = owned + 1
				end
			end
			modPanel.label:SetText( owned .. "/" .. count .. " owned" )
			modPanel.label:SizeToContents( )
			modPanel.label:Dock( TOP )

			modPanel.items = vgui.Create( "DIconLayout", modPanel )
			modPanel.items:SetSpaceX( 5 )
			modPanel.items:SetSpaceY( 5 )
			modPanel.items:DockMargin( 0, 0, 8, 0 )
			modPanel.items:Dock( TOP )

			for _, dlc in pairs( dlcs ) do
				local panel = modPanel.items:Add( "DDlcButton" )
				panel:SetDlc( dlc )
			end
		end
	end )
	:Fail( function( err )
		if not IsValid( self ) then
			return
		end

		local label = vgui.Create( "DLabel", self.panels )
		label:SetText( "Failed to load the DLC List. Possible reason: " .. err .. "." )
		label:SetFont( self:GetSkin( ).fontName )
		label:SizeToContents( )
		label:Dock( TOP )
	end )
	derma.SkinHook( "Layout", "DPointshopManagementTab_DLC", self )
end

function PANEL:Paint( )
end

derma.DefineControl( "DPointshopManagementTab_DLC", "", PANEL, "DPanel" )

Pointshop2:AddManagementPanel( "DLC Available", "pointshop2/download7.png", "DPointshopManagementTab_DLC", function( )
	return PermissionInterface.query( LocalPlayer(), "pointshop2 createitems" )
end )
