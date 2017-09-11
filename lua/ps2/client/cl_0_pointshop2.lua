Pointshop2.Menu = nil
Pointshop2.RegisteredTabs = {}
local GLib = LibK.GLib

function Pointshop2:OpenMenu( )
	if not IsValid( Pointshop2.Menu ) then
		Pointshop2.Menu = vgui.Create( "DPointshopFrame" )
		Pointshop2.Menu:Center( )
		Pointshop2.Menu.LowendModeEnabled = Pointshop2.ClientSettings.GetSetting( "BasicSettings.LowendMode" )
	end
	Pointshop2.Menu:SetVisible( true )
	CloseDermaMenus( )
	Pointshop2.Menu:MakePopup( )
	Pointshop2.Menu:SetKeyboardInputEnabled( false )
	Pointshop2.Menu:SetMouseInputEnabled( true )

	gui.EnableScreenClicker( true )
end

--[[---------------------------------------------------------
   Name: HOOK PointshopMenuKeyboardFocusOn
		Called when text entry needs keyboard focus
-----------------------------------------------------------]]
local function PointshopMenuKeyboardFocusOn( pnl )
	if not ValidPanel( Pointshop2.Menu ) then
		return
	end

	if IsValid( pnl ) and not pnl:HasParent( Pointshop2.Menu ) then
		return
	end

	Pointshop2.Menu:StartKeyFocus( pnl )
end
hook.Add( "OnTextEntryGetFocus", "PointshopMenuKeyboardFocusOn", PointshopMenuKeyboardFocusOn )

--[[---------------------------------------------------------
   Name: HOOK PointshopMenuKeyboardFocusOff
		Called when text entry stops needing keyboard focus
-----------------------------------------------------------]]
local function PointshopMenuKeyboardFocusOff( pnl )
	if not ValidPanel( Pointshop2.Menu ) then
		return
	end

	if IsValid( pnl ) and not pnl:HasParent( Pointshop2.Menu ) then
		return
	end

	Pointshop2.Menu:EndKeyFocus( pnl )
end
hook.Add( "OnTextEntryLoseFocus", "PointshopMenuKeyboardFocusOff", PointshopMenuKeyboardFocusOff )

function Pointshop2:CloseMenu( )
	if not IsValid( Pointshop2.Menu ) then
		return
	end
	Pointshop2.Menu:SetVisible( false )
	if LibK.Debug then
		Pointshop2.Menu:Remove( )
	end
	gui.EnableScreenClicker( false )
end

function Pointshop2:ToggleMenu( )
	if IsValid( Pointshop2.Menu ) and Pointshop2.Menu:IsVisible( ) then
		Pointshop2.CloseMenu( )
	else
		Pointshop2.OpenMenu( )
	end
end

function Pointshop2:AddTab( title, controlName, shouldShow )
	KLogf( 4, "     - Tab %s: %s added", title, controlName )
	for k, v in pairs( Pointshop2.RegisteredTabs ) do
		if v.title == title then
			return
		end
	end
	table.insert( Pointshop2.RegisteredTabs, { title = title, control = controlName, shouldShow = shouldShow } )
end

function Pointshop2:IsPlayerModelEquipped( )
	if LocalPlayer( ).PS2_Slots["Model"] then
		return LocalPlayer( ).PS2_Slots["Model"] != nil
	end
	return false
end

function Pointshop2:GetPreviewModel( )
	local previewInfo = hook.Run( "PS2_GetPreviewModel" )
	if previewInfo then
		return previewInfo
	end

	if self:IsPlayerModelEquipped( ) then
		local playerModelItem = LocalPlayer( ).PS2_Slots["Model"]
		return {
			model = playerModelItem.playerModel,
			skin =  playerModelItem.skin,
			bodygroups = playerModelItem.bodygroups
		}
	end

	return {
		model = LocalPlayer( ):GetModel( ),
		bodygroups = "0",
		skin = 0
	}
end

function Pointshop2.GenerateIconSize( ratioX, ratioY )
	return ratioX * 32 - 5, ratioY * 32 - 5
end

--debug
concommand.Add( "pointshop2_reload", function( )
	Pointshop2.CloseMenu( )
	RunConsoleCommand( "libk_reload" )
	hook.Add( "OnReloaded", "openWhenReady", function( )
		timer.Simple( 2, function( )
			CompileString( "Pointshop2View:getInstance():toggleMenu( )", "chink" )( )
		end )
	end )
end )

concommand.Add( "pointshop2_toggle", function()
	Pointshop2View:getInstance( ):toggleMenu( )
end )

-- Hide PAC Parts on First Person spectated player
hook.Add( "PostDrawOpaqueRenderables", "UnhookPac", function( )
	if LocalPlayer( ):GetObserverMode() == OBS_MODE_IN_EYE then
		local ply = LocalPlayer( ):GetObserverTarget( )
		LocalPlayer( ).lastSpecTarget = ply
		if IsValid( ply ) then
			ply.partsHidden = ply.partsHidden or {}
			for k, v in pairs( ply.pac_parts or {} ) do
				table.insert( ply.partsHidden, k )
				pac.UnhookEntityRender( ply, k )
			end
		end
	end
end )

-- Unhide parts when player is not spectated anymore
function Pointshop2.HidePacOnSpectate( )
	if IsValid( LocalPlayer( ).lastSpecTarget )
		and LocalPlayer( ):GetObserverMode() != OBS_MODE_IN_EYE
	then
		pac.ShowEntityParts( LocalPlayer( ).lastSpecTarget )
		for k, v in pairs( LocalPlayer( ).lastSpecTarget.partsHidden or {} ) do
			pac.HookEntityRender( LocalPlayer( ).lastSpecTarget, v )
		end
		LocalPlayer( ).lastSpecTarget = nil
	end
end
hook.Add( "Think", "PS2_HidePacOnSpectate", Pointshop2.HidePacOnSpectate )

local function InitNotificationsPanel( )
	if IsValid( LocalPlayer( ).notificationPanel ) then
		LocalPlayer( ).notificationPanel:Remove( )
	end

	local notificationPanel = vgui.Create( "KNotificationManagerPanel" )
	notificationPanel:SetPos( 5, 5 )
	--notificationPanel:ParentToHUD( )
	notificationPanel:SetSize( 250, 0 )
	LocalPlayer( ).notificationPanel = notificationPanel
end

hook.Add( "InitPostEntity", "InitNotifications", function( )
	InitNotificationsPanel( )
end )

hook.Add( "OnReloaded", "InitNotifications", function( )
	InitNotificationsPanel( )
end )

hook.Remove("InitPostEntity", "pace_autoload_parts") -- Disable PAC autoload

-- Used to request a Settings table from the server to get serverside settings for a specified module
-- returns a Promise
function Pointshop2.RequestSettings( moduleName )
	local def = Deferred( )

	local outBuffer = GLib.StringOutBuffer()
	outBuffer:String( moduleName )
	local transfer = GLib.Transfers.Request( "Server", "Pointshop2.Settings", outBuffer:GetString() )
	transfer:AddEventListener( "Finished", function( )
		local inBuffer = GLib.StringInBuffer( transfer:GetData( ) )
		local serializedData = inBuffer:LongString( )

		local data = util.JSONToTable( serializedData )
		def:Resolve( data )
	end )
	transfer:AddEventListener( "RequestRejected", function( )
		def:Reject( "Transfer Request was rejected" )
	end )

	return def:Promise( )
end
