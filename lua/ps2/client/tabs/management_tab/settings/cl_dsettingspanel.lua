local PANEL = {}

function PANEL:Init( )
	self.settings = {}
end

function PANEL:AddSection( name )
	local section = vgui.Create( "DSettingsSection", self )
	section:SetSettingsListener( self )
	section:Dock( TOP )
	section:DockMargin( 0, 5, 0, 5 )
	section.title:SetText( name )
	
	return section
end

function PANEL:SetData( data )
	self.settings = data
	self:InitSettings( )
end

function PANEL:InitSettings( )
	for path, value in pairs( self.settings ) do
		if self.settingsLookup[path] then
			self.settingsLookup[path]:SetValue( value )
		end
	end
end

function PANEL:OnValueChanged( path, value )
	self.settings[path] = value
end

function PANEL:AutoAddSettingsTable( tbl, settingListener )
	settingListener = settingListener or self
	
	self.settingsLookup = self.settingsLookup or {}
	for catPath, settingsTable in pairs( tbl ) do
		if settingsTable.info and settingsTable.info.isManualSetting then
			continue
		end
		
		self[catPath] = self:AddSection( settingsTable.info and settingsTable.info.label or catPath )
		self[catPath]:SetSettingsListener( settingListener )
		
		for settingPath, settingInfo in pairs( settingsTable ) do
			if settingPath == "info" then
				--Info about the category
				continue
			end
			
			local path = catPath .. "." .. settingPath
			local panel = self[catPath]:AddSettingByType( path, settingInfo )
			self.settingsLookup[path] = panel
		end
	end
end

function PANEL:PerformLayout( )
	self:SizeToChildren( false, true )
end

function PANEL:Paint( w, h )
end

derma.DefineControl( "DSettingsPanel", "", PANEL, "DPanel" )