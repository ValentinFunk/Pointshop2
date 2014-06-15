local PANEL = {}

local function createHatPositioner( parentPanel )
	local f = vgui.Create( "DHatPositioner" )
	function f.OnSave( _self, outfit )
		return parentPanel:OutfitSaved( outfit )
	end
	function f.OnSaveIconViewInfo( _self, viewInfo )
		return parentPanel:IconViewInfoSaved( viewInfo )
	end
	f:Center( )
	return f
end

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self:addSectionTitle( "Model and Positioning" )
	
	local openBtn = vgui.Create( "DButton", self )
	openBtn:SetText( "Open Editor" )
	openBtn:SetWide( 120 )
	openBtn:SetImage( "pointshop2/pencil54.png" )
	openBtn.m_Image:SetSize( 16, 16 )
	function openBtn.DoClick( )
		self.currentModel = Pointshop2.HatPersistence.ALL_MODELS
		
		local menu = DermaMenu( )
		menu:SetSkin( Pointshop2.Config.DermaSkin )
		if self.baseOutfit then
			menu:AddOption( "Edit Outfit", function( )
				local f = createHatPositioner( self )
				f:LoadOutfit( self.baseOutfit )
			end )
			menu:AddSpacer( )
		end
		
		menu:AddOption( "Create new Outfit", function( )
			local f = createHatPositioner( self )
			f:NewEmptyOutfit( )
		end )
		menu:AddOption( "Import existing PAC Outfit", function( )
			local f = createHatPositioner( self )
			f:ImportPacOutfit( )
		end )
		menu:Open( )
		menu:MakePopup( )
	end
	
	local desc = vgui.Create( "DLabel", self )
	desc:SetText( "The Base outfit is applied to every Playermodel.\nUse Model Specific Outfits to adjust your item for special Player Models" )
	desc:Dock( TOP )
	desc:SizeToContents( )
	desc:DockMargin( 5, 5, 5, 5 )
	
	self:addFormItem( "Base Outfit", openBtn )
	
	self.addBtn = vgui.Create( "DButton", self )
	self.addBtn:SetText( "Add" )
	self.addBtn:SetWide( 120 )
	self.addBtn:SetImage( "pointshop2/plus24.png" )
	self.addBtn.m_Image:SetSize( 16, 16 )
	self.addBtn:Dock( LEFT )
	self.addBtn:SetDisabled( true )
	function self.addBtn.DoClick( )	
		local menu = DermaMenu( )
		menu:SetSkin( Pointshop2.Config.DermaSkin )
		
		local function requestModel( clone, overrideMdlPath )
			local modelPath = overrideMdlPath
			local function openEditor( )
				self.currentModel = modelPath
				local line = self.listView:AddLine( modelPath, "No", "" )
				local f = createHatPositioner( self )
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
		
		menu:Open( )
		menu:MakePopup( )
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
				return 
			end
		end
		
		local line = DListView.AddLine( listView, model, outfitId, action )
		local button = vgui.Create( "DButton", line )
		button.Value = 0
		button:SetText( "Open Editor" )
		function button.DoClick( )
			local f = vgui.Create( "DHatPositioner" )
			f:Center( )
			function f.OnSave( _self, outfit )
				return self:OutfitSaved( outfit )
			end
			if modelPath == Pointshop2.HatPersistence.ALL_CSS_MODELS then
				line.model = "models/player/t_guerilla.mdl"
			elseif modelPath == Pointshop2.HatPersistence.ALL_MODELS then
				line.model = "models/player/kliener.mdl"
			else
				line.model = modelPath
			end
			self.currentModel = line.modelPath
			f:SetModel( line.model )
			if line.outfit then
				f:LoadOutfit( line.outfit )
			else
				f:NewEmptyOutfit( )
			end
		end
		line.Columns[3] = button
		return line
	end
	
	function self.listView:PerformLayout( )
		DListView.PerformLayout( self )
		self:SetTall( math.Clamp( 100, 50, #self:GetLines( ) * 20 + 20 ) )
	end
	
	
	self:addSectionTitle( "Item Icon" )
	
	local iconBox = vgui.Create( "DPanel", self )
	iconBox:Dock( TOP )
	iconBox:SetTall( 175 )
	function iconBox:Paint( ) end
	
	self.choice = vgui.Create( "DRadioChoice", iconBox )
	self.choice:Dock( FILL )
	local snapshotChoice = self.choice:AddOption( "Use Snapshot" )
	local container = vgui.Create( "DPanel", snapshotChoice )
	container:Dock( TOP )
	container:DockMargin( 100, 0, 0, 0 )
	container:SetTall( 128 )
	function container:Paint( ) end
	snapshotChoice:SetTall( 128 )
	
	self.snapshotPreview = vgui.Create( "DPreRenderedModelPanel", container )
	self.snapshotPreview:SetSize( 128, 128 )
	self.snapshotPreview:SetModel( "models/player/kleiner.mdl" )
	
	local materialChoice = self.choice:AddOption( "Use Material" )
	local materialInputBox = vgui.Create( "DTextEntry", materialChoice )
	materialInputBox:Dock( LEFT )
	materialInputBox:DockMargin( 100, 0, 0, 0 )
	materialInputBox:SetWide( 250 )
	materialInputBox:SetTall( 30 )
	self.materialInputBox = materialInputBox
	
	self.choice:DockMargin( 5, 5, 5, 5 )
	function self.choice.OnChange( )
		if materialChoice:GetChecked( ) then
			materialInputBox:SetDisabled( false )
		else
			materialInputBox:SetDisabled( true )
		end
		self.useCustomMaterial = materialChoice:GetChecked( )
	end
	self.choice:OnChange( )
end

function PANEL:IconViewInfoSaved( viewInfo )
	self.iconViewInfo = viewInfo
	self.snapshotPreview:SetViewInfo( viewInfo )
end

function PANEL:OutfitSaved( outfit )
	pace.Backup( outfit, os.time( ) .. self.currentModel ) --Just to be save
	
	if self.currentModel == Pointshop2.HatPersistence.ALL_MODELS then
		self.baseOutfit = outfit
		self.snapshotPreview:SetPacOutfit( self.baseOutfit )
		self.addBtn:SetDisabled( false )
	else
		for k, v in pairs( self.listView:GetLines( ) ) do
			if v.Columns[1]:GetText( ) == self.currentModel then
				v.Columns[2]:SetText( "Yes" )
				v.outfit = outfit
			end
		end
	end
	
	return true
end

function PANEL:Validate( )
	self.BaseClass.Validate( self )
	
end

function PANEL:SaveItem( saveTable )
	self.BaseClass.SaveItem( self, saveTable )
	saveTable.outfits = { }
	saveTable.outfits[Pointshop2.HatPersistence.ALL_MODELS] = self.baseOutfit
	
	for k, line in pairs( self.listView:GetLines( ) ) do
		if line.outfit then
			local model = line.Columns[1]:GetText( )
			saveTable.outfits[model] = line.outfit 
		end
	end
	
	if self.useCustomMaterial then
		saveTable.useMaterialIcon = true
		saveTable.iconMaterial = materialInputBox:GetText( )
	else
		saveTable.useMaterialIcon = false
		saveTable.iconMaterial = ""
		saveTable.iconViewInfo = self.iconViewInfo
	end
end

vgui.Register( "DHatCreator", PANEL, "DItemCreator" )
