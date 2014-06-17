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
	
	self.iconViewInfo = {
		["fov"] = 75,
		["angles"] = Angle(7.5625, 182.59375, 0),
		["origin"] = Vector(35.5625, 0.125, 69.84375),
	}
	
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
	self.snapshotPreview:SetSize( KInventory.Items.base_hat.GetPointshopIconDimensions( ) )
	self.snapshotPreview.forceRender = true
	self.snapshotPreview:SetModel( "models/player/kleiner.mdl" )
	
	local sliders = vgui.Create( "DPanel", container )
	sliders:Dock( FILL )
	sliders:DockMargin( self.snapshotPreview:GetWide( ) + 5, 0, 5, 5 )
	function sliders:Paint( w, h )
	end
	
	local params = {
		x = { function( newVal ) 
				self.iconViewInfo.origin.x = newVal
			end, 
			-1000,
			1000,
			self.iconViewInfo.origin.x
		},
		y = { function( newVal )
				self.iconViewInfo.origin.y = newVal
			end,
			-1000,
			1000,
			self.iconViewInfo.origin.y
		}, 
		z = { function( newVal ) 
				self.iconViewInfo.origin.z = newVal
			end, 
			-1000,
			1000,
			self.iconViewInfo.origin.z
		},
		pitch = { function( newVal )
				self.iconViewInfo.angles.p = newVal
			end,
			-360, 
			360,
			self.iconViewInfo.angles.p
		},
		yaw = { function( newVal ) 
				self.iconViewInfo.angles.y = newVal
			end,
			-360, 
			360,
			self.iconViewInfo.angles.y
		},
		fov = {
			function( newVal ) 
				self.iconViewInfo.fov = newVal 
			end,
			10,
			90,
			self.iconViewInfo.fov
		}
	}
	
	local label = vgui.Create( "DLabel", sliders )
	label:SetText( "Drag the grey buttons to adjust" )
	label.OwnLine = true
	label:SizeToContents( )
	label:Dock( TOP )
	
	for name, infoTbl in pairs( params ) do
		local slider = vgui.Create( "DPanel", sliders )
		slider:SetTall( 12 )
		slider:Dock( TOP )
		slider:DockMargin( 0, 5, 0, 0 )
		function slider.Paint( ) end
		
		slider.lbl = vgui.Create( "DLabel", slider )
		slider.lbl:SetText( name )
		slider.lbl:Dock( LEFT )
		slider.lbl:SizeToContents( )
		slider.lbl:SetWide( 50 )
		
		slider.scratch = vgui.Create( "DNumberScratch", slider )
		slider.scratch:SetImageVisible( false )
		slider.scratch:SetWide( 25 ) 
		slider.scratch:Dock( LEFT )
		slider.scratch.OnValueChanged = function( _self )
			infoTbl[1]( _self:GetFloatValue( ) )
			self.snapshotPreview:SetViewInfo( self.iconViewInfo )
			slider.lbl2:SetText( math.Round( _self:GetFloatValue( ), 2 ) )
		end
		slider.scratch:SetMin( infoTbl[2] )
		slider.scratch:SetMax( infoTbl[3] )
		slider.scratch:SetValue( infoTbl[1] )
		
		slider.lbl2 = vgui.Create( "DLabel", slider )
		slider.lbl2:SetText( 12 )
		slider.lbl2:Dock( LEFT )
		slider.lbl2:DockMargin( 5, 0, 0, 0 )
		
		infoTbl.slider = slider.scratch
	end
	self.params = params
	self.snapshotPreview:SetViewInfo( self.iconViewInfo )
	
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
	self.params.x.slider:SetValue( viewInfo.origin.x )
	self.params.y.slider:SetValue( viewInfo.origin.y )
	self.params.z.slider:SetValue( viewInfo.origin.z )
	self.params.fov.slider:SetValue( viewInfo.fov )
	self.params.pitch.slider:SetValue( viewInfo.angles.p )
	self.params.yaw.slider:SetValue( viewInfo.angles.y )
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
