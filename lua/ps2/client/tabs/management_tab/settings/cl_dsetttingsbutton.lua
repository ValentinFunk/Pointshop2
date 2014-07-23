local PANEL = {}
local GLib = LibK.GLib
GLib.Transfers.RegisterHandler( "Pointshop2.Settings", GLib.NullCallback )

function PANEL:Init( )
end

function PANEL:OnMousePressed( )
	self:OnLoad( )
	
	local outBuffer = GLib.StringOutBuffer()
	outBuffer:String( self.mod.Name )
	local transfer = GLib.Transfers.Request( "Server", "Pointshop2.Settings", outBuffer:GetString() )
	transfer:AddEventListener( "Finished", function( )
		self:OnLoadFinished( true )
		local inBuffer = GLib.StringInBuffer( transfer:GetData( ) )
		local serializedData = inBuffer:LongString( )
		
		local data = LibK.von.deserialize( serializedData )
		
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
	end )
	transfer:AddEventListener( "RequestRejected", function( )
		self:OnLoadFinished( false, "Transfer Request was rejected" )
	end )
end

function PANEL:SetSettingsInfo( settingsInfo, mod )	
	self.icon:SetImage( settingsInfo.icon )
	self.label:SetText( settingsInfo.label )
	self.settingsInfo = settingsInfo
	self.mod = mod
end

derma.DefineControl( "DSettingsButton", "", PANEL, "DBigButton" )