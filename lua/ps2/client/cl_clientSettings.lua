Pointshop2.ClientSettings = {}

Pointshop2.ClientSettings.SettingsTable = {
	BasicSettings = {
		info = {
			label = "General Settings"
		},
		LowendMode = {
			tooltip = "This turns all icons into simple icons to save performance",
			label = "Lowend Mode", 
			value = false
		},
		DrawDistance = {
			value = 20000,
			tooltip = "Distance that PAC items are drawn",
			label = "Item Draw Distance",
		},
		VisualsDisabled = {
			label = "Disable Visuals",
			tooltip = "Disables all Pointshop2 ingame visuals (trails, hats, pets etc.)",
			value = false
		},
		AutoconfirmSale = {
			label = "Autoconfirm selling items",
			tooltip = "Disables the confirmation when selling an item",
			value = false
		},
		HoverPanelEnabled = {
			label = "Show hover panel",
			tooltip = "Displays information in inventory on hover",
			value = false
		}
	}, 
}

function Pointshop2.ClientSettings.SaveSettings( settings )
	Pointshop2.ClientSettings.Settings = settings
	file.Write( "pointshop2-settings.txt", util.TableToJSON( settings ) )
end

function Pointshop2.ClientSettings.LoadSettings( )
	local settings = util.JSONToTable( file.Read( "pointshop2-settings.txt" ) or "{}" )
	
	Pointshop2.ClientSettings.Settings = {}
	Pointshop2.recursiveSettingsInitialize( Pointshop2.ClientSettings.SettingsTable, settings, Pointshop2.ClientSettings.Settings )
	hook.Run( "PS2_ClientSettingsUpdated" )
	
	KLogf( 5, "[PS2] Loaded client settings" )
end

function Pointshop2.ClientSettings.GetSetting( path )
	return Pointshop2.ClientSettings.Settings[path]
end

Pointshop2.ClientSettings.LoadSettings( )

hook.Add( "PS2_ClientSettingsUpdated", "UpdatePACConvars", function( )
	RunConsoleCommand( "pac_draw_distance", Pointshop2.ClientSettings.GetSetting( "BasicSettings.DrawDistance" ) )
	if IsValid( Pointshop2.Menu ) then
		if Pointshop2.Menu.LowendModeEnabled != Pointshop2.ClientSettings.GetSetting( "BasicSettings.LowendMode" ) then
			Pointshop2.Menu:Remove( )
			Pointshop2.OpenMenu( )
		end
	end
end )

hook.Add("OnReloaded", "reloadsettingsclient", function()
	if LibK.Debug then
		Pointshop2.ClientSettings.LoadSettings( )		
	end
end)