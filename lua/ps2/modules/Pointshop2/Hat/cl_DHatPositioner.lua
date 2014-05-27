local PANEL = {}
local L = pace.LanguageString

function PANEL:Init( )
	self:SetSize( 1024, 768 )
	
	--[[local pnl = pace.CreatePanel( "properties", self )
	pace.properties = pnl
	pnl:Dock( BOTTOM )
	
	local edit = pace.CreatePanel( "tree", self )
	edit:Dock( LEFT )
	edit:SetWide( 240 )
	
	edit.MakeBar = function( ) end
	]]--
	
	local edit = vgui.Create( "pace_editor", self )
	edit:Dock( LEFT )
	edit.menu_bar:Remove( )
	edit:SetWide( 240 )
	function edit:Think( )
		DFrame.Think( self )
	end
	
	pace.Editor = edit
	pace.Active = true
	
	pac.RemoveAllParts(true, false)
	pace.RefreshTree()
	
	timer.Simple(0.1, function()
		if not pace.Editor:IsValid() then return end
	
		if table.Count(pac.GetParts(true)) == 0 then
			pace.Call("CreatePart", "group", L"Pointshop Item", L"add parts to me!")
		end	
			
		pace.TrySelectPart()
	end)
	
	self.modelPanel = vgui.Create( "DPointshopPacView", self )
	self.modelPanel:Dock( FILL )
	self.modelPanel:SetModel( LocalPlayer( ):GetModel( ) )
	
	self:MakePopup( )
end

function PANEL:OnRemove( )
	pace.Active = false
	pace.Call("CloseEditor") 
	RunConsoleCommand("pac_in_editor", "0")
end

vgui.Register( "DHatPositioner", PANEL, "DFrame" )
