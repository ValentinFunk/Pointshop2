local PANEL = {}
local GLib = LibK.GLib
GLib.Transfers.RegisterHandler( "Pointshop2.Settings", GLib.NullCallback )

function PANEL:Init( )
end

function PANEL:OnMousePressed( )
	self:OnLoad( ) -- Notify parent to show loading indicator
	Pointshop2.RequestSettings( self.mod.Name )
	:Then( function( data )
		self:OnLoadFinished( true ) -- Notify parent to hide loading indicator

		if self.settingsInfo.onClick then
			self.settingsInfo.onClick( )
		else
			local creator = vgui.Create( self.settingsInfo.control )
			creator:Center( )
			creator:MakePopup( )
			creator:SetSkin( Pointshop2.Config.DermaSkin )
			creator:SetModule( self.mod )
			creator:SetData( data )
		end
	end, function( err )
		self:OnLoadFinished( false, err ) -- Notify parent to hide loading indicator
	end )
end

function PANEL:SetSettingsInfo( settingsInfo, mod )
	self.icon:SetMaterial( Material( settingsInfo.icon, "noclamp smooth" ) )
	self.label:SetText( settingsInfo.label )
	self.settingsInfo = settingsInfo
	self.mod = mod
end

derma.DefineControl( "DSettingsButton", "", PANEL, "DBigButton" )
