local L = pace.LanguageString
local PANEL = {}

--W2S, S2W found on facepunch, author unknown
function W2S( vDir, iScreenW, iScreenH, angCamRot, fFoV )
	local fHalfWidth = iScreenW*0.5;
    local fHalfHeight = iScreenH*0.5;

    --This code works by basically treating the camera like a frustrum of a pyramid.
    --We slice this frustrum at a distance "d" from the camera, where it's width is the screen width, and it's height is the screen height.
    local d = fHalfWidth/math.tan(fFoV*0.5);

    local fdp = angCamRot:Forward():Dot( vDir );

    --fdp must be nonzero ( in other words, vDir must not be perpendicular to angCamRot:Forward() )
    --or we will get a divide by zero error when calculating vProj below.
    if fdp == 0 then
        return 0, 0, -1
    end

    --Using linear projection, project this vector onto the plane of the slice
    local vProj = ( d / fdp ) * vDir;

    --Dotting the projected vector onto the right and up vectors gives us screen positions relative to the center of the screen.
    --We add half-widths / half-heights to these coordinates to give us screen positions relative to the upper-left corner of the screen.
    --We have to subtract from the "up" instead of adding, since screen coordinates decrease as they go upwards.
    local x = 0.5 * iScreenW + angCamRot:Right():Dot( vProj );
    local y = 0.5 * iScreenH - angCamRot:Up():Dot( vProj );

    --Lastly we have to ensure these screen positions are actually on the screen.
    local iVisibility
    if fdp < 0 then          --Simple check to see if the object is in front of the camera
        iVisibility = -1;
    elseif x < 0 || x > iScreenW || y < 0 || y > iScreenH then  --We've already determined the object is in front of us, but it may be lurking just outside our field of vision.
        iVisibility = 0;
    else
        iVisibility = 1;
    end

    return x, y, iVisibility;
end

function S2W(iScreenX,iScreenY,iScreenW,iScreenH,aCamRot,fFoV)
    --We use half screen widths/half screen heights in the code
    local fHalfWidth = iScreenW*0.5;
    local fHalfHeight = iScreenH*0.5;

    --This code works by basically treating the camera like a frustrum of a pyramid.
    --We slice this frustrum at a distance "d" from the camera, where it's width is the screen width, and it's height is the screen height.
    local d = fHalfWidth/math.tan(fFoV*0.5);

    --Forward, right, and up vectors (need these to convert from local to world coordinates
    local vForward=aCamRot:Forward();
    local vRight=aCamRot:Right();
    local vUp=aCamRot:Up();

    --Then convert vec to proper world coordinates and return it  
	local vResult = (vForward*d + vRight*(iScreenX-fHalfWidth) + vUp*(fHalfHeight-iScreenY))
	vResult:Normalize( )
    return vResult;
end


local oldT, oldV2S, oldS2V, oldGMP, oldPaceOpenMenu
local oldGuiMousePos = gui.MousePos

GAMEMODE.hookRestore = GAMEMODE.hookRestore or {
	--oldT = pace.mctrl.GetTarget,
	oldV2S = pace.mctrl.VecToScreen,
	oldS2V = pace.mctrl.ScreenToVec,
	oldGuiMousePos = gui.MousePos,
	oldGMP = pace.mctrl.GetMousePos,
	oldPaceOpenMenu = pace.OnOpenMenu,
	oldAddRegisteredPartsToMenu = pace.AddRegisteredPartsToMenu,
	oldIsInBasicMode = pace.IsInBasicMode,
	oldBasicParts = pace.BasicParts,
	oldBasicProps = pace.BasicProperties,
	oldAddRegisteredPartsToMenu = pace.AddRegisteredPartsToMenu
}

local function hookPac( panel )
	local result, w, h = panel.result, panel:GetWide( ), panel:GetTall( )
	
	--function pace.mctrl.GetTarget( )
	--	return outfit
	--end
	
	--local pnl = vgui.GetControlTable( "pace_editor" )
	-- pnl.Base = "DPanel"
	-- pace.RegisterPanel(pnl)
	
	function pace.mctrl.VecToScreen( vec )
		local x, y, vis = W2S(
			( vec - result.origin ):GetNormalized( ),
			w,
			h,
			result.angles,
			math.rad( result.fov )
		)
		return {x=x-1,y=y-1, visible = vis > 0}
	end

	function pace.mctrl.ScreenToVec(x,y)
		local vec = S2W(
			x,
			y,
			w,
			h,
			result.angles,
			math.rad(result.fov)
		)
		return vec
	end
	
	function pace.mctrl.GetMousePos( )
		return panel:ScreenToLocal( gui.MousePos( ) )
	end
	
	function pace.OnOpenMenu()
		panel:OnOpenMenu( )
	end

	function pace.selectControl.VecToScreen(vec)
		local pos = pace.mctrl.VecToScreen(vec)
		return { x = pos.x, y = pos.y }
	end
	
	function pace.selectControl.GetMousePos()
		return pace.mctrl.GetMousePos()
	end

	pace.BasicParts = {
		model = true,
		light = true,
		sprite = true,
		bone = true
	}
	
	function pace.AddRegisteredPartsToMenu(menu)
		local partsToShow = {}
		
		for class_name, part in pairs(pac.GetRegisteredParts()) do
			print (class_name, pace.BasicParts[class_name])
			if pace.BasicParts[class_name] then
				partsToShow[class_name] = part
			end
		end

		table.sort(partsToShow)

		for class_name, part in pairs(partsToShow) do
			local newMenuEntry = menu:AddOption(L(class_name), function()
				pace.Call("CreatePart", class_name)
			end)

			if part.Icon then
				newMenuEntry:SetImage(part.Icon)
			end
		end
	end
	
	pace.IsInBasicMode = function() return true end 
	pace.BasicProperties = {
		Position = true,
		Scale = true,
		Model = true,
		Angles = true,
		Size = true,
		Alpha = true,
		Color = true,
		Skin = true,
		Material = true,
		Name = true,
		Hide = true,
		SpritePath = true,
		Brightness = true,
		Bone = true,
	}
end

local function unHookPac( )
	--pace.mctrl.GetTarget = GAMEMODE.hookRestore.oldT
	pace.mctrl.VecToScreen = GAMEMODE.hookRestore.oldV2S
	pace.mctrl.ScreenToVec = GAMEMODE.hookRestore.oldS2V
	pace.mctrl.GetMousePos = GAMEMODE.hookRestore.oldGMP
	pace.OnOpenMenu = GAMEMODE.hookRestore.oldPaceOpenMenu
	pace.IsInBasicMode = GAMEMODE.hookRestore.oldIsInBasicMode
	pace.BasicParts = GAMEMODE.hookRestore.oldBasicParts
	pace.BasicProperties = GAMEMODE.hookRestore.oldBasicProps

	function pace.selectControl.VecToScreen(vec)
		return vec:ToScreen()
	end
	
	function pace.selectControl.GetMousePos()
		return gui.MousePos()
	end
	
	local pnl = vgui.GetControlTable( "pace_editor" )
	pnl.Base = "DFrame"
	pace.RegisterPanel(pnl)
end

function PANEL:Init( )
	self:SetMouseInputEnabled( true )
	Pointshop2.EditorWin = self
	
	self.dbg = vgui.Create( "DLabel", self )
	self.dbg:Dock( TOP )
	self.dbg:DockMargin( 5, 5, 5, 5 )
	self.dbg:SetText("Movement: WASD, Space, Shift" ..
					 "\nLooking: Mouse (Click + Drag)" ..
					 "\nUse the tree in the left to add parts. Click on '...' next to model in the panel below to pick a model." ..
					 "\nWhen done, select a nice view and click 'Use as Icon View', then save.")
	self.dbg:SizeToContents()
	
	hook.Add( "pace_OnPartSelected", self, self.Pace_OnPartSelected )
	
	RunConsoleCommand( "pac_in_editor", 1 )
	
	self:InvalidateLayout( )
	self:SetAnimated( false )
end

function PANEL:Pace_OnPartSelected( part )
	if not IsValid(part) then return end
	local root = part:GetRootPart( )
	root:SetOwner( self.Entity )
	--root:SetOwnerName( "persist " .. pac.CalcEntityCRC(self.Entity) )
	-- pac.HookEntityRender(self.Entity, part)		
end

function PANEL:Paint( w, h )
	--pace.current_part:GetRootPart( ):SetOwner( self.Entity )
	--pace.current_part:SetOwner( self.Entity )
	--pace.current_part:Think( )

	if not IsValid( self.Entity ) then return end
	self.Entity:ResetSequence(self.Entity:LookupSequence("reference"))

	--[[ self.dbg:SetText( 
		"pace.current_part:GetOwner(true): " .. (pace.current_part:IsValid( ) and ( tostring( pace.current_part:GetOwner( true ) ) .. " - " .. tostring( self.Entity ) ) or "No Part")
		.. "\n" .. "pace.ViewEntity: " .. (tostring(pace:GetViewEntity()))
		.. "\n" .. "pace.ViewEntity:GetPos: " .. (tostring(pace:GetViewEntity():GetPos()))
		.. "\n" .. "pace.CurrentPart.self: " .. (pace.current_part.ClassName)
		.. "\n" .. "RootPart: " .. tostring(pace.current_part:GetRootPart():GetDrawPosition())
		.. "\n" .. "pace.current_part.cached_pos" .. (tostring(pace.current_part.cached_pos))
		.. "\n" .. "pace.current_part.GetDrawPosition" .. (tostring(pace.current_part:GetDrawPosition(nil, true)))
		.. "\n" .. "mctrl.GetTargetPos" .. (tostring(pace.mctrl.GetTargetPos() or "no pos"))
		.. "\n" .. "mctrl.target" .. (tostring(pace.mctrl.target))
		.. "\n" .. "current_part:IsHidden" .. (tostring(pace.current_part:IsHidden()))
	)
	self.dbg:SizeToContents()
	]]--

	local PrevMins, PrevMaxs = self.Entity:GetRenderBounds()
	self:SetLookAt((PrevMaxs + PrevMins) / 2 + Vector( 0, 0, 10 ) )
	
	local pos = Vector( 50, 50, 50 )
	local ang = ( Vector( 0, 0, 0 ) - Vector( 50,50, 50 ) ):Angle( )
	local fov = 45

	pace.Focused = true
	pace.HUDPaint() --Update View pos (movement is done here)
	surface.SetDrawColor(color_white)
	pace.selectControl.HUDPaint( )
	
	local result = pace.CalcView( LocalPlayer( ), pos, ang, fov )
	
	pos, ang, fov =  result.origin, result.angles, result.fov
	self.result = result

	pac.ShowEntityParts( self.Entity )
	pac.HookEntityRender( self.Entity, pace.current_part )
	
	pac.FrameNumber = pac.FrameNumber - 100

	if pac.Think then pac.Think() end
	
	local x, y = self:LocalToScreen( 0, 0 )
	cam.Start3D( pos, ang, fov, x, y, w, h, 0.1, 4096 )
		cam.IgnoreZ( true )
		render.SuppressEngineLighting( true )
		render.SetLightingOrigin( self.Entity:GetPos() )
		render.ResetModelLighting( self.colAmbientLight.r/255, self.colAmbientLight.g/255, self.colAmbientLight.b/255 )
		render.SetColorModulation( self.colColor.r/255, self.colColor.g/255, self.colColor.b/255 )
		render.SetBlend( self.colColor.a/255 )
		
		for i=0, 6 do
			local col = self.DirectionalLight[ i ]
			if ( col ) then
				render.SetModelLighting( i, col.r/255, col.g/255, col.b/255 )
			end
		end
		
		--pac.HookEntityRender( self.Entity, self.pacOutfit )
			pac.RenderOverride( self.Entity, "opaque" )
			pac.RenderOverride( self.Entity, "translucent", false )
			self.Entity:DrawModel( )
			pac.RenderOverride( self.Entity, "translucent", false )
		--pac.UnhookEntityRender( self.Entity, self.pacOutfit )
		
		cam.IgnoreZ( false )
		render.SuppressEngineLighting( false )
	cam.End3D( )

	pace.mctrl.HUDPaint( )
	pace.selectControl.HUDPaint( )

	if not self.hooked then
		hookPac( self )
		--self.hooked = true
	end
	
	self.LastPaint = RealTime()
end

function PANEL:OnRemove( )
	unHookPac( )
	RunConsoleCommand( "pac_in_editor", 0 )
end

function PANEL:OnMouseWheeled( delta )
	pace.OnMouseWheeled( delta )
end 

function PANEL:OnMousePressed( mc )
	pace.GUIMousePressed( mc )
	pace.selectControl.GUIMousePressed( mc )
end

function PANEL:OnMouseReleased( mc )
	pace.GUIMouseReleased( mc )
	pace.selectControl.GUIMouseReleased( mc )
end

function PANEL:OnOpenMenu( )
	local menu = DermaMenuHack(self)
	menu:SetPos(gui.MousePos())
	
		menu:AddOption(L"Save for PAC", function() pace.SaveParts() end)
		menu:AddOption(L"Import from PAC", function() pace.LoadParts(nil, true) end)
		
	menu:AddSpacer()
		
		--menu:AddOption(L"toggle basic mode", function() pace.ToggleBasicMode() end)
		--menu:AddOption(L"toggle t pose", function() pace.SetTPose(not pace.GetTPose()) end)
		
	--menu:AddSpacer()
		
		menu:AddOption(L"PAC3 Help", function()  gui.OpenURL(pace.WikiURL) end)
		menu:AddOption("Cancel", function() CloseDermaMenus() end)
		
	menu:OpenForModal()
end

vgui.Register( "DPointshopPacView", PANEL, "DModelPanel" )