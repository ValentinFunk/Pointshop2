local PANEL = {}

Pointshop2.SettingsButtons = {}
function Pointshop2.AddSettingsButton( category, buttonLabel, icon, control )
	table.insert( Pointshop2.SettingsButtons, { category = category, buttonLabel = buttonLabel, icon = icon, control = control } )
end

function PANEL:Init( )
	self.loadingNotifier = vgui.Create( "DLoadingNotifier", self )
	self.loadingNotifier:Dock( TOP )
	hook.Add("PS2_SettingsSavingStart", self, function()
		self.loadingNotifier:Expand()
	end)
	hook.Add("PS2_ServerSettingsSaved", self, function()
		self.loadingNotifier:Collapse()
	end)
	hook.Add("PS2_OnSettingsUpdate", self, function()
		self.loadingNotifier:Collapse()
	end)

	local scroll = vgui.Create( "DScrollPanel", self )
	scroll:Dock( FILL )

	self:SetSkin( Pointshop2.Config.DermaSkin )

	self:DockPadding( 10, 0, 5, 10 )

	local label = vgui.Create( "DLabel", scroll )
	label:SetText( "Select a section to configure" )
	label:SetColor( color_white )
	label:SetFont( self:GetSkin( ).TabFont )
	label:SizeToContents( )
	label:Dock( TOP )

	self.panels = vgui.Create( "DPanel", scroll )
	self.panels.Paint = function( a, w, h )
	end
	function self.panels:PerformLayout( )
		self:SizeToChildren( false, true )
	end
	self.panels:Dock( TOP )

	for k, mod in pairs( Pointshop2.Modules) do
		if not mod.SettingButtons or #mod.SettingButtons == 0 then
			continue
		end

		local categoryPanel = vgui.Create( "DPanel", self.panels )
		Derma_Hook( categoryPanel, "Paint", "Paint", "InnerPanel" )
		categoryPanel:DockMargin( 0, 0, 0, 5 )
		categoryPanel:DockPadding( 11, 8, 0, 8 )
		categoryPanel:Dock( TOP )
		function categoryPanel:PerformLayout( )
			self.items:SizeToChildren( false, true )
			self:SizeToChildren( false, true )
		end


		categoryPanel.label = vgui.Create( "DLabel", categoryPanel )
		categoryPanel.label:DockMargin( 0, -5, 0, 8 )
		categoryPanel.label:SetFont( self:GetSkin( ).SmallTitleFont )
		categoryPanel.label:SetText( mod.Name )
		categoryPanel.label:SizeToContents( )
		categoryPanel.label:Dock( TOP )

		categoryPanel.items = vgui.Create( "DIconLayout", categoryPanel )
		categoryPanel.items:SetSpaceX( 5 )
		categoryPanel.items:SetSpaceY( 5 )
		categoryPanel.items:DockMargin( 0, 0, 8, 0 )
		categoryPanel.items:Dock( TOP )

		for _, buttonInfo in pairs( mod.SettingButtons ) do
			local iconButton = categoryPanel.items:Add( "DSettingsButton" )
			iconButton:SetSettingsInfo( buttonInfo, mod )
			function iconButton.OnLoad( )
				self.panels:SetDisabled( true )
				self.loadingNotifier:Expand( )
			end
			function iconButton.OnLoadFinished( success, err )
				self.panels:SetDisabled( false )
				self.loadingNotifier:Collapse( )
				if not success then
					Pointshop2View:getInstance( ):displayError( "Error loading settings: " .. err )
				end
			end
		end
	end
end

function PANEL:Paint( )
end

function PANEL:PerformLayout( )

end

derma.DefineControl( "DPointshopManagementTab_Settings", "", PANEL, "DPanel" )

Pointshop2:AddManagementPanel( "Settings", "pointshop2/advanced.png", "DPointshopManagementTab_Settings", function()
	return PermissionInterface.query( LocalPlayer(), "pointshop2 managemodules" )
end )
