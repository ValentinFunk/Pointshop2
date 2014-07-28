local PANEL = {}

--[[---------------------------------------------------------
   Name: Paint
-----------------------------------------------------------]]
function PANEL:Init()
	self.CreateMenu = vgui.Create( "DPS2_CreationMenu", self )
	self.CreateMenu:Dock( FILL );
	self.CreateMenu:DockMargin( 3, 20, 3, 10 )
	
	self.m_bHangOpen = false
	
	self:SetMouseInputEnabled( true )
end


function PANEL:OpenCreationMenuTab( name )

	self.CreateMenu:SwitchToName( name )

end

function PANEL:GetToolMenu()
	return self.ToolMenu;
end

--[[---------------------------------------------------------
   Name: OnClick
-----------------------------------------------------------]]
function PANEL:OnMousePressed()
	
	self:Close()
	
end


--[[---------------------------------------------------------
   Name: HangOpen
-----------------------------------------------------------]]
function PANEL:HangOpen( bHang )
	self.m_bHangOpen = bHang
end

--[[---------------------------------------------------------
   Name: HangingOpen
-----------------------------------------------------------]]
function PANEL:HangingOpen()
	return self.m_bHangOpen
end

--[[---------------------------------------------------------
   Name: Paint
-----------------------------------------------------------]]
function PANEL:Open()

	RestoreCursorPosition()

	self.m_bHangOpen = false
	
	
	if ( self:IsVisible() ) then return end
	
	CloseDermaMenus()
	
	self:MakePopup()
	self:SetVisible( true )
	self:SetKeyboardInputEnabled( false )
	self:SetMouseInputEnabled( true )
	self:SetAlpha( 255 )

end

--[[---------------------------------------------------------
   Name: Paint
-----------------------------------------------------------]]
function PANEL:Close( bSkipAnim )

	if ( self.m_bHangOpen ) then 
		self.m_bHangOpen = false
		return
	end
	
	RememberCursorPosition()
	
	CloseDermaMenus()

	self:SetKeyboardInputEnabled( false )
	self:SetMouseInputEnabled( false )
	self:SetVisible( false )

end

--[[---------------------------------------------------------
   Name: PerformLayout
-----------------------------------------------------------]]
function PANEL:PerformLayout()

	self:SetSize( ScrW(), ScrH() )
	self:SetPos( 0, 0 )

	local MarginX = math.Clamp( (ScrW() - 1024) * 5, 25, 256 )
	local MarginY = math.Clamp( (ScrH() - 768) * 5, 25, 256 )

	self:DockPadding( 0, 0, 0, 0 )

	self.CreateMenu:DockMargin( MarginX, MarginY, 1, MarginY )

end

vgui.Register( "DPS2_SpawnMenu", PANEL, "EditablePanel" )


--[[---------------------------------------------------------
   Called to create the spawn menu..
-----------------------------------------------------------]]
local function CreateSpawnMenu()

	-- If we have an old spawn menu remove it.
	if ( Pointshop2.SpawnMenu ) then
	
		Pointshop2.SpawnMenu:Remove()
		Pointshop2.SpawnMenu = nil
	
	end
	
	-- Add the tabs to the tool menu before trying
	-- to populate them with tools.
	--hook.Run("PS2_SpawnMenu_PopulateContent")

	Pointshop2.SpawnMenu = vgui.Create( "DPS2_SpawnMenu" )
	Pointshop2.SpawnMenu:SetVisible( false )
end

-- Hook to create the spawnmenu at the appropriate time (when all sents and sweps are loaded)
CreateSpawnMenu()

timer.Simple( 3, function( )
	--PAC needs g_SpawnMenu so create it if the gamemode doesn't
	g_SpawnMenu = g_SpawnMenu or Pointshop2.SpawnMenu
end )