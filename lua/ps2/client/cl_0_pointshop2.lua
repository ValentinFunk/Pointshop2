Pointshop2.Menu = nil
Pointshop2.RegisteredTabs = {}
Pointshop2.LowEndMode = true

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

-- Hide PAC Parts on First Person spectated player
function Pointshop2.HidePacOnSpectate( )
	local ply = LocalPlayer( )
	if ply:GetObserverMode() == OBS_MODE_IN_EYE then
		ply.lastSpecTarget = ply:GetObserverTarget( )
		pac.HideEntityParts( ply.lastSpecTarget )
	else
		if IsValid( ply.lastSpecTarget ) then
			pac.ShowEntityParts( ply.lastSpecTarget )
			ply.lastSpecTarget = nil
		end
	end
end
hook.Add( "Think", "PS2_HidePacOnSpectate", Pointshop2.HidePacOnSpectate )