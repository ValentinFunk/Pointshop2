local PANEL = {}
local L = pace.LanguageString

function PANEL:Init( )
	self:SetSize( 1024, 768 )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	--[[local pnl = pace.CreatePanel( "properties", self )
	pace.properties = pnl
	pnl:Dock( BOTTOM )
	
	local edit = pace.CreatePanel( "tree", self )
	edit:Dock( LEFT )
	edit:SetWide( 240 )
	
	edit.MakeBar = function( ) end
	]]--
	self:MakePopup( )
	self:MoveToFront( )
	
	local edit = vgui.Create( "DPanel", self )
	edit:Dock( LEFT )
	edit:SetWide( 240 )
	function edit:PerformLayout( )
		self.div:InvalidateLayout()
		self.top:PerformLayout()
		self.bottom:PerformLayout()
		pace.properties:PerformLayout()
		
		if true then
			--self.div:SetTopHeight(600 - math.min(pace.properties:GetHeight() + 10 + 0 - 6, 600 / 1.5))
		end
	end
	
	local div = vgui.Create("DVerticalDivider", edit)
	div:SetDividerHeight(10)
	div:Dock(FILL)
	div:SetTopMin(100)
	div:SetTopHeight(300)
	edit.div = div
	
	local topPnl = pace.CreatePanel("tree", div)
	div:SetTop(topPnl)
	edit.top = div
	
	local pnl = pace.CreatePanel("properties", div)
	pace.properties = pnl
	
	div:SetBottom(pnl)
	edit.bottom = pnl
	
	pace.Editor = edit
	pace.Active = true
	
	self:InvalidateLayout( )
	
	pac.RemoveAllParts(true, false)
	pace.RefreshTree()
	
	self.modelPanel = vgui.Create( "DPointshopPacView", self )
	self.modelPanel:Dock( FILL )
	self.modelPanel:SetModel( "models/player/kleiner.mdl" )
	
	
	self:SetTitle( "Hat Maker - powered by PAC3" )
end

function PANEL:NewEmptyOutfit( )
	timer.Simple(0.01, function()
		if not pace.Editor:IsValid() then return end
	
		if table.Count(pac.GetParts(true)) == 0 then
			pace.Call("CreatePart", "group", L"Pointshop Item", L"add parts to me!")
		end	
			
		pace.TrySelectPart()
	end)
end

function PANEL:ImportPacOutfit( )
	timer.Simple(0.01, function()
		pace.LoadParts(nil, true)
	end )
end

function PANEL:OnRemove( )
	pace.Active = false
	pace.Call("CloseEditor") 
	RunConsoleCommand("pac_in_editor", "0")
end

vgui.Register( "DHatPositioner", PANEL, "DFrame" )
