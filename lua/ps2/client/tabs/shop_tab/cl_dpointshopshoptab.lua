local PANEL = {}

function PANEL:Init( )
	self.rightBar = vgui.Create( "DScrollPanel", self )
	self.rightBar:Dock( RIGHT )
	self.rightBar:SetWide( self.leftBar:GetWide( ) - 23 )
	Derma_Hook( self.rightBar, "Paint", "Paint", "InnerPanel" )

	self.loading = vgui.Create( "DLoadingNotifier", self )
	self.loading:DockMargin( 15, 0, 15, 0 )
	self.loading:Dock( TOP )

	hook.Add( "PS2_PreReload", self.loading, function( )
		self.loading:Expand( )
	end )
	hook.Add( "PS2_DynamicItemsUpdated", self.loading, function( )
		self.loading:Collapse( )
	end )
	
	self.previewPanel = vgui.Create( "DPointshopPreviewPanel", self.rightBar )
	self.previewPanel:Dock( TOP )
	self.previewPanel:SetTall( 320 )
	self.previewPanel:SetFOV( 43 )
	self.previewPanel:SetAnimated( true )
	
	self.descPanel = vgui.Create( "DPointshopItemDescription", self.rightBar )
	self.descPanel:Dock( TOP )
	hook.Add( "PS2_ItemIconSelected", self, function( self, panel, itemClass )
		if not IsValid( panel ) or not itemClass then
			self.descPanel:SelectionReset( )
			return
		end
		if self.descPanel.ClassName != itemClass.GetPointshopDescriptionControl( ) then
			self.descPanel:Remove( )
			self.descPanel = vgui.Create( itemClass.GetPointshopDescriptionControl( ), self.rightBar )
			self.descPanel:Dock( TOP )
		end
		self.descPanel:SetItemClass( itemClass )
	end )
	
	Pointshop2.previewPanel = self.previewPanel
	
	self:DoPopulate( )
	hook.Add( "PS2_DynamicItemsUpdated", self, function( )
		self:Clear( )
		self:DoPopulate( )
	end )
end

function PANEL:OnTabChanged( newTab )
	hook.Call( "PS2_ItemIconSelected" ) --Reset selection
	
	if not newTab then
		return
	end
	
	local categoryPanel = newTab:GetPanel( ).categoryPanel
	if not categoryPanel.itemsAdded then
		categoryPanel:Populate( )
	end
end

local function anyItemValidForServer( category )
	for k, itemClassName in pairs( category.items ) do
		local itemClass = Pointshop2.GetItemClassByName( itemClassName )
		if not itemClass then
			KLogf( 2, "[ERROR] Invalid item class %s detected, database corrupted?", itemClassName )
			continue
		end
		if itemClass:IsValidForServer( Pointshop2.GetCurrentServerId( ) ) then
			return true
		end
	end
	
	for k, subcat in pairs( category.subcategories ) do
		if anyItemValidForServer( subcat ) then
			return true
		end
	end
end

function PANEL:ShowInstall( )
	local overlay = vgui.Create( "DPanel", self )
	overlay:SetPos(0, 0)
	overlay:SetZPos(100)
	overlay:Dock(FILL)
	Derma_Hook( overlay, "Paint", "Paint", "InnerPanelDark" )

	local pnl = vgui.Create( "DPanel", overlay )
	function pnl:PerformLayout( )
		self:SizeToChildren( false, true )
	end
	pnl:Dock( TOP )
	pnl.Paint = function( ) end

	local timerLabel = vgui.Create( "DLabel", pnl )
	timerLabel:Dock( TOP )
	timerLabel:SetText( "Welcome to your Pointshop 2!" )
	timerLabel:SetColor( color_white )
	timerLabel:SetContentAlignment( 5 )
	timerLabel:SetFont( self:GetSkin( ).BigTitleFont )
	timerLabel:SizeToContents( )

	local timerLabel2 = vgui.Create( "DLabel", pnl )
	timerLabel2:Dock( TOP )
	timerLabel2:SetContentAlignment( 5 )
	timerLabel2:SetFont( self:GetSkin( ).fontName )
	timerLabel2:SetText( "No items have been installed yet." )
	timerLabel2:SizeToContents( )
	
	if PermissionInterface.query( LocalPlayer(), "pointshop2 reset" ) then
		local btn = vgui.Create( "DButton", pnl )
		btn:Dock( TOP )
		btn:SetContentAlignment( 5 )
		btn:SetFont( self:GetSkin( ).TabFont )
		btn:SetText( "Install Default Items" )
		btn:DockMargin( 125, 20, 125, 20)
		btn:SetTall( 45 )
		function btn.DoClick()
			if btn:GetDisabled() then return end
			btn:SetDisabled( true )
			Pointshop2View:getInstance( ):installDefaults( )
			btn:SetText("Installing, please wait...")
			self.loading:Expand( )
			timerLabel:SetText( "We are preparing your shop" )
			timerLabel2:SetText( "This may take a minute." )
		end
	end

	function overlay:PerformLayout( )
		pnl:DockMargin( 0, ( self:GetTall( ) - pnl:GetTall( ) ) / 2 , 0, 0 )
	end

	self.ShowInstallPanel = overlay
end

function PANEL:PerformLayout()
	if IsValid(self.ShowInstallPanel) then
		self.ShowInstallPanel:SetSize( self:GetTall(), self:GetWide() )
	else
		DPointshopMenuedTab.PerformLayout(self)
	end
end

function PANEL:DoPopulate( )
	if #Pointshop2View:getInstance().itemMappings == 0 then
		if IsValid(self.ShowInstallPanel) then self.ShowInstallPanel:Remove() end

		self:ShowInstall()
		return
	else
		if IsValid(self.ShowInstallPanel) then
			self.ShowInstallPanel:Remove()
		end
	end

	local dataNode = Pointshop2View:getInstance( ):getShopCategory( )
	for k, category in pairs( dataNode.subcategories ) do
		if anyItemValidForServer( category ) then
			local sp = vgui.Create("DScrollPanel")
			local panel = vgui.Create( "DPointshopCategoryPanel", sp )
			panel:Dock(FILL)
			panel:SetCategory( category )
			sp.categoryPanel = panel
			local sheet = self:addMenuEntry( category.self.label, category.self.icon, sp )
		end
	end
end

derma.DefineControl( "DPointshopShopTab", "", PANEL, "DPointshopMenuedTab" )

Pointshop2:AddTab( "Shop", "DPointshopShopTab" )