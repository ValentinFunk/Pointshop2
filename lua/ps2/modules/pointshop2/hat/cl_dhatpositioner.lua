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
	
	self.bottomButtons = vgui.Create( "DPanel", self )
	self.bottomButtons:Dock( BOTTOM )
	self.bottomButtons:DockMargin( 0, 5, 0, 0 )
	self.bottomButtons:SetTall( 30 )
	self.bottomButtons:MoveToBack( )
	self.bottomButtons.Paint = function( ) end
	
	local cancel = vgui.Create( "DButton", self.bottomButtons )
	cancel:SetText( "Cancel" )
	cancel:Dock( RIGHT )
	cancel:SetWide( 150 )
	cancel:DockMargin( 5, 0, 5, 0 )
	function cancel.DoClick( )
		self:Remove( )
	end
	
	local save = vgui.Create( "DButton", self.bottomButtons )
	save:SetText( "Save" )
	save:Dock( RIGHT )
	save:SetWide( 150 )
	save:SetImage( "pointshop2/floppy1.png" )
	save.m_Image:SetSize( 16, 16 )
	function save.DoClick( )
		local partTable = {}
		for key, part in pairs(pac.GetParts and pac.GetParts() or pac.GetLocalParts()) do
			if not part:HasParent() and part.show_in_editor ~= false then
				table.insert(partTable, part:ToSaveTable())
			end
		end
		if self:OnSave( partTable ) then
			self:Remove( )
		end
	end
	
	local save = vgui.Create( "DButton", self.bottomButtons )
	save:SetText( "Use as Icon View" )
	save:Dock( RIGHT )
	save:SetWide( 150 )
	save:DockMargin( 0, 0, 5, 0 )
	save:SetImage( "pointshop2/floppy1.png" )
	save.m_Image:SetSize( 16, 16 )
	function save.DoClick( )
		self:OnSaveIconViewInfo( self.modelPanel.result )
	end
	
	self:SetTitle( "Hat Maker - powered by PAC3" )
end

function PANEL:OnSave( partTable )
	--For overwriting
end

function PANEL:OnSaveIconViewInfo( partTable )
	--For overwriting
end

function PANEL:SetModel( mdlPath )
	self.modelPanel:SetModel( mdlPath )
end

function PANEL:NewEmptyOutfit( )
	timer.Simple(0.01, function()
		if not pace.Editor:IsValid() then return end
	
		pace.ClearParts()
		pace.Call("CreatePart", "model", "model part")
			
		pace.TrySelectPart()
		pace.ResetView( )
	end)
end

function PANEL:LoadOutfit( outfitPart )
	timer.Simple( 0.01, function( )
		if not pace.Editor:IsValid() then return end
		
		pace.LoadPartsFromTable( outfitPart, true )
		pace.ResetView( )
	end )
end

function PANEL:ImportPacOutfit( )
	timer.Simple(0.1, function()
		local override_part = pac.CreatePart("group")
		override_part:SetOwner(self.modelPanel.Entity)
		pace.LoadParts(nil, true, override_part)
		pace.SetViewPart(override_part, true)
	end )
end

function PANEL:OnRemove( )
	pace.Active = false
	pace.Call("CloseEditor") 
	RunConsoleCommand("pac_in_editor", "0")
end

vgui.Register( "DHatPositioner", PANEL, "DFrame" )
