local PANEL = {}

function PANEL:Init( )
	self.modelAndPositioningPanel = vgui.Create( "DItemCreator_HatStage" )
	self.stepsPanel:AddStep( "Hat Settings", self.modelAndPositioningPanel )
end

vgui.Register( "DHatCreator", PANEL, "DItemCreator_Steps" )

local PANEL = {}

function PANEL:Paint( )
end

local function createHatPositioner( parentPanel, model )
	local f = vgui.Create( "DHatPositioner" )
	function f.OnSave( _self, outfit )
		return parentPanel:OutfitSaved( outfit, model )
	end
	function f.OnSaveIconViewInfo( _self, viewInfo )
		return parentPanel:IconViewInfoSaved( viewInfo )
	end
	f:Center( )
	timer.Simple(0.5, function() pace.ResetView( ) end)
	return f
end

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )

	local openBtn = vgui.Create( "DButton", self )
	openBtn:SetText( "Open Editor" )
	openBtn:SetWide( 120 )
	openBtn:SetImage( "pointshop2/pencil54.png" )
	openBtn.m_Image:SetSize( 16, 16 )
	function openBtn.DoClick( )
		local menu = DermaMenu( self )
		menu:SetSkin( Pointshop2.Config.DermaSkin )
		if self.baseOutfit then
			menu:AddOption( "Edit Outfit", function( )
				local f = createHatPositioner( self, Pointshop2.HatPersistence.ALL_MODELS )
				f:LoadOutfit( self.baseOutfit )
			end )
			menu:AddSpacer( )
		end

		menu:AddOption( "Create new Outfit", function( )
			local f = createHatPositioner( self, Pointshop2.HatPersistence.ALL_MODELS )
			f:NewEmptyOutfit( )
		end )
		menu:AddOption( "Import existing PAC Outfit", function( )
			local f = createHatPositioner( self, Pointshop2.HatPersistence.ALL_MODELS )
			f:ImportPacOutfit( )
		end )

		local x, y = openBtn:LocalToScreen( 0, openBtn:GetTall() )
		menu:SetMinimumWidth( openBtn:GetWide() )
		menu:Open( x, y )
	end

	local desc = vgui.Create( "DLabel", self )
	desc:SetText( "The Base outfit is applied to every Playermodel.\nUse Model Specific Outfits to adjust your item for special Player Models" )
	desc:Dock( TOP )
	desc:SizeToContents( )
	desc:DockMargin( 5, 5, 5, 5 )
	desc:SetColor(color_white)

	self:addFormItem( "Base Outfit", openBtn )

	self.addBtn = vgui.Create( "DButton", self )
	self.addBtn:SetText( "Add" )
	self.addBtn:SetWide( 120 )
	self.addBtn:SetImage( "pointshop2/plus24.png" )
	self.addBtn.m_Image:SetSize( 16, 16 )
	self.addBtn:Dock( LEFT )
	self.addBtn:SetDisabled( true )
	function self.addBtn.DoClick( )
		local menu = DermaMenu( self )
		menu:SetSkin( Pointshop2.Config.DermaSkin )

		local function requestModel( clone, overrideMdlPath )
			local modelPath = overrideMdlPath
			local function openEditor( )
				local line = self.listView:AddLine( modelPath, "No", "" )
				local f = createHatPositioner( self, modelPath )
				if modelPath == Pointshop2.HatPersistence.ALL_CSS_MODELS then
					line.model = "models/player/t_guerilla.mdl"
				elseif modelPath == Pointshop2.HatPersistence.ALL_MODELS then
					line.model = "models/player/kliener.mdl"
				else
					line.model = modelPath
				end
				f:SetModel( line.model )
				if clone then
					f:LoadOutfit( self.baseOutfit )
				else
					f:NewEmptyOutfit( )
				end
			end
			if not modelPath then
				Derma_StringRequest( "Enter a model path", "Enter the path of the model", "models/player/alyx.mdl", function( mdlPath )
					modelPath = mdlPath
					openEditor( )
				end, function( )
					return false
				end )
			else
				openEditor( )
			end
		end

		local sub = menu:AddSubMenu( "Specify custom Model Path" )
		sub:AddOption( "Clone Base Outfit", function( )
			requestModel( true )
		end )
		sub:AddOption( "New Outfit", function( )
			requestModel( false )
		end )

		local cssSub = menu:AddSubMenu( "All CS:S Models" )
		cssSub:AddOption( "Clone Base Outfit", function( )
			requestModel( true, Pointshop2.HatPersistence.ALL_CSS_MODELS )
		end )
		cssSub:AddOption( "New Outfit", function( )
			requestModel( false, Pointshop2.HatPersistence.ALL_CSS_MODELS )
		end )

		menu:Open()
	end

	local pnl = self:addFormItem( "Model Specific Outfit", self.addBtn )

	self.listView = vgui.Create( "DListView", self )
	self.listView:Dock( TOP )
	self.listView:DockMargin( 5, 5, 5, 5 )
	self.listView:AddColumn( "Model" )
	self.listView:AddColumn( "Outfit Created" )
	self.listView:AddColumn( "Action" )
	function self.listView.AddLine( listView, model, outfitId, action )
		--No Duplicates
		for k, v in pairs( listView:GetLines( ) ) do
			if v.Columns[1]:GetText( ) == model then
				return v.Columns[1]
			end
		end

		local line = DListView.AddLine( listView, model, outfitId, action )
		local button = vgui.Create( "DButton", line )
		button.Value = 0
		button:SetText( "Open Editor" )
		function button.DoClick( )
			local f = createHatPositioner( self, model )
			f:SetModel(model == Pointshop2.HatPersistence.ALL_CSS_MODELS and "models/player/t_guerilla.mdl" or model)
			if line.outfit then
				f:LoadOutfit( line.outfit )
			elseif self.baseOutfit then 
				f:LoadOutfit( self.baseOutfit )
			else
				f:NewEmptyOutfit()
			end
		end
		line.Columns[3] = button
		return line
	end

	function self.listView:PerformLayout( )
		DListView.PerformLayout( self )
		self:SetTall( math.Clamp( 100, 50, #self:GetLines( ) * 20 + 20 ) )
	end

	local creator = self
	function self.listView:OnRowRightClick( id, line )
		local menu = DermaMenu( self )
		menu:SetSkin( Pointshop2.Config.DermaSkin )

		menu:AddOption( "Remove", function( )
			self:RemoveLine( id )
			creator.outfitsChanged = true
		end )

		menu:Open()
	end


	self:addSectionTitle( "Item Icon" )

	local iconSheet = vgui.Create( "DPropertySheet", self )
	iconSheet:Dock( TOP )
	iconSheet:SetTall( 200 )
	iconSheet.tabScroller:SetTall( 40 )
	iconSheet:DockMargin( 5, 5, 5, 5 )
	iconSheet.Paint = function( s, w, h )
	end

	self.shopIconEditor = vgui.Create( "DHatIconEditor", iconSheet )
	self.shopIconEditor:SetIconSize( KInventory.Items.base_hat.GetPointshopIconDimensions( ) )

	local shopIconSheet = iconSheet:AddSheet( "Shop Icon", self.shopIconEditor )
	derma.SkinHook( "Layout", "InlineSheetSheet", self, shopIconSheet )

	self.invIconEditor = vgui.Create( "DHatIconEditor", iconSheet )
	self.invIconEditor:SetIconSize( 64, 64 )

	local invIconSheet = iconSheet:AddSheet( "Inventory Icon", self.invIconEditor )
	derma.SkinHook( "Layout", "InlineSheetSheet", self, invIconSheet )
	invIconSheet.Tab:SetFont( self:GetSkin( ).TextFont )

	self:addSectionTitle( "Slots" )

	local lbl = vgui.Create( "DLabel", self )
	lbl:Dock( TOP )
	lbl:SetText( "Select the slots that this item can be equipped in" )
	lbl:SizeToContents( )
	lbl:DockMargin( 5, 0, 5, 5 )

	self.slotLayout = vgui.Create( "DIconLayout", self )
	self.slotLayout:Dock( TOP )
	self.slotLayout:DockMargin( 5, 5, 5, 5 )
	self.slotLayout:SetSpaceX( 10 )
	self.slotLayout:SetSpaceY( 5 )
	local old = self.slotLayout.PerformLayout
	function self.slotLayout:PerformLayout( )
		old( self )
	end

	self.checkBoxes = {}
	for _, name in pairs( Pointshop2.ValidHatSlots ) do
		local chkBox = vgui.Create( "DCheckBoxLabel", self.slotLayout )
		chkBox:SetText( name )
		chkBox:SizeToContents( )
		self.checkBoxes[name] = chkBox
	end

end

function PANEL:IconViewInfoSaved( viewInfo )
	self.shopIconEditor:SetViewInfo( viewInfo )
	self.invIconEditor:SetViewInfo( viewInfo )
end

function PANEL:OutfitSaved( outfit, model )
	pace.Backup( outfit, os.time( ) .. model ) --Just to be save
	self.outfitsChanged = true

	if model == Pointshop2.HatPersistence.ALL_MODELS then
		self.baseOutfit = outfit
		self.shopIconEditor:SetPacOutfit( outfit )
		self.invIconEditor:SetPacOutfit( outfit )
		self.addBtn:SetDisabled( false )
	else
		for k, v in pairs( self.listView:GetLines( ) ) do
			if v.Columns[1]:GetText( ) == model then
				v.Columns[2]:SetText( "Yes" )
				v.outfit = outfit
			end
		end
	end

	return true
end

function PANEL:Validate( saveTable )
	if table.Count( saveTable.outfits ) == 0 then
		return false, "Please create at least one outfit"
	end

	if not saveTable.outfits[Pointshop2.HatPersistence.ALL_MODELS] then
		return false, "Please add a base outfit"
	end

	local shopIcon, invIcon = saveTable.iconInfo.shop, saveTable.iconInfo.inv

	if shopIcon.useMaterialIcon and #shopIcon.iconMaterial == 0 then
		return false, "Please supply a material path"
	end

	if shopIcon.useMaterialIcon and Material(shopIcon.iconMaterial):GetName() == '___error' then
		return false, "Material " .. tostring(shopIcon.iconMaterial) .. " was not found. Please use e.g. pointshop2/small43.png (not materials/pointshop2/small43.png)"
	end

	if table.Count( saveTable.validSlots ) == 0 then
		return false, "Please select one or more slots"
	end

	return true
end

function PANEL:SaveItem( saveTable )
	saveTable.outfits = { }
	saveTable.outfits[Pointshop2.HatPersistence.ALL_MODELS] = self.baseOutfit

	for k, line in pairs( self.listView:GetLines( ) ) do
		if line.outfit then
			local model = line.Columns[1]:GetText( )
			saveTable.outfits[model] = line.outfit
		end
	end

	saveTable.iconInfo = {
		shop = self.shopIconEditor:GetIconInfo( ),
		inv = self.invIconEditor:GetIconInfo( ),
	}

	saveTable.outfitsChanged = self.outfitsChanged

	saveTable.validSlots = {}
	for slotName, checkBox in pairs( self.checkBoxes ) do
		if checkBox:GetChecked( ) then
			table.insert( saveTable.validSlots, slotName )
		end
	end
end

function PANEL:EditItem( persistence, itemClass )
	self.baseOutfit = itemClass.getBaseOutfit( )

	for model, outfitId in pairs( itemClass.outfitIds ) do
		--Don't add the base item to the list
		if model == Pointshop2.HatPersistence.ALL_MODELS then
			continue
		end

		local line = self.listView:AddLine( model, "Yes", "" )
		line.outfit = Pointshop2.Outfits[outfitId]
	end
	self.addBtn:SetDisabled( false )

	for k, slotName in pairs( itemClass.validSlots ) do
		if self.checkBoxes[slotName] then
			self.checkBoxes[slotName]:SetChecked( true )
		end
	end

	self.shopIconEditor:SetIconInfo( itemClass.iconInfo.shop )
	self.invIconEditor:SetIconInfo( itemClass.iconInfo.inv )

	self.shopIconEditor:SetPacOutfit( self.baseOutfit )
	self.invIconEditor:SetPacOutfit( self.baseOutfit )
end

vgui.Register( "DItemCreator_HatStage", PANEL, "DItemCreator_Stage" )
