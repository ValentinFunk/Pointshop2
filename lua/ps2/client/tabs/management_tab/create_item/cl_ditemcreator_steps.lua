local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self:SetTitle( "Create a Pointshop Item" )
	self:SetSize( 410, 308 )
	
	self.loadingNotifier = vgui.Create( "DLoadingNotifier", self )
	self.loadingNotifier:Dock( TOP )
	
	self.stepsPanel = vgui.Create( "DStepPanel", self )
	self.stepsPanel:SetAdaptiveSize( true )
	self.stepsPanel:Dock( TOP )
	function self.stepsPanel:OnCompleted( )
		self:GetParent( ):OnCompleted( ) 
	end
	
	self.buttonBar = vgui.Create( "DIconLayout", self )
	self.buttonBar:SetBorder( 5 )
	self.buttonBar:SetSpaceX( 5 )
	self.buttonBar:DockMargin( 0, 0, 0, 5 )
	
	self.nextBtn = self:addFormButton( vgui.Create( "DButton", self ) )
	self.nextBtn:SetText( "Next" )
	self.nextBtn:Dock( RIGHT )
	self.nextBtn:DockMargin( 0, 0, 10, 0 )
	self.nextBtn:SetDisabled( false )
	self.nextBtn:SetSize( 80, 25 )
	function self.nextBtn.DoClick( )
		self.stepsPanel:NextStep( )
	end
	
	self.backBtn = self:addFormButton( vgui.Create( "DButton", self ) )
	self.backBtn:SetText( "Back" )
	self.backBtn:Dock( RIGHT )
	self.backBtn:SetDisabled( true )
	self.backBtn:DockMargin( 10, 0, 10, 0 )
	self.backBtn:SetSize( 80, 25 )
	function self.backBtn.DoClick( )
		self.stepsPanel:PreviousStep( )
	end
	
	self.basicSettingsPanel = vgui.Create( "DItemCreator_BasicSettings" )
	self.stepsPanel:AddStep( "Basic Information", self.basicSettingsPanel )
	
	function self.stepsPanel.OnStepChanged( )
		if self.stepsPanel.currentStep == 1 then
			self.backBtn:SetDisabled( true )
			self.nextBtn:SetText( "Next" )
		else
			self.backBtn:SetDisabled( false )
			self.nextBtn:SetText( "Next" )
		end
		if self.stepsPanel.currentStep != 1 and self.stepsPanel.currentStep == #self.stepsPanel.steps then
			self.nextBtn:SetText( "Finish" )
		end
		self:InvalidateLayout( true )
		timer.Simple( 0.01, function() 
			self:Center( )
		end )
	end
	
	self:InvalidateLayout( true )
	timer.Simple( 0.05, function() 
		self:Center( )
	end )
end

function PANEL:OnCompleted( )
	local saveTable = { }
	self:SaveItem( saveTable )
	local succ, stepNum, err = self:Validate( saveTable )
	if not succ then
		self.stepsPanel:GoToStep( stepNum )
		return Derma_Message( err, "Error" )
	end
	saveTable.targetCategoryId = self.targetCategoryId
	Pointshop2View:getInstance( ):createPointshopItem( saveTable )
	self:Close( )
	
	if not self.persistenceId and not self.targetCategoryId then
		Derma_Message( "The item has been created. To put it up for sale go to Manage Items and move it from uncategorized items into a category", "Information" )
	end
end

function PANEL:SetTargetCategoryId( categoryId )
	self.targetCategoryId = categoryId
end

function PANEL:SetItemBase( itembase )
	self.itembase = itembase
	self.basicSettingsPanel:SetItemBase( itembase )
end

function PANEL:addFormButton( btn )
	btn:SetParent( self.buttonBar )
	return btn
end

function PANEL:PerformLayout( )
	DFrame.PerformLayout( self )
	
	local maxY = 0
	for k, v in pairs( self:GetChildren( ) ) do
		local x, y = v:GetPos( )
		v:InvalidateLayout( true )
		local endPos = y + v:GetTall( )
		if endPos > maxY and v != self.buttonBar then
			maxY = endPos
		end
	end
	
	self.buttonBar:SetPos( 5, maxY + 5 )
	self.buttonBar:SetTall( 25 )
	self.buttonBar:SetWide( self:GetWide( ) - 10 )
	
	self:SetTall( maxY + self.buttonBar:GetTall( ) + 15 )
end

function PANEL:NotifyLoading( bIsLoading )
	if bIsLoading then
		self.loadingNotifier:Expand( )
		self:SetDisabled( true )
	else
		self.loadingNotifier:Collapse( )
		self:SetDisabled( false )
	end
end

/*
	Called after save table generation to validate the created
	table against errors
*/
function PANEL:Validate( saveTable )
	for k, v in ipairs( self.stepsPanel.steps ) do
		local succ, err = v.panel:Validate( saveTable )
		if not succ then
			return false, k, err
		end
	end	
	return true
end

/*
	Generate a table that is sent to the server, then passed to 
	the persistence model for saving
*/
function PANEL:SaveItem( saveTable )
	for k, v in ipairs( self.stepsPanel.steps ) do
		v.panel:SaveItem( saveTable )
	end	
end

/*
	Load a persistence model for editing. Can also access the
	item class for convenience
*/
function PANEL:EditItem( persistence, itemClass )
	self.itembase = persistence.baseClass
	self.persistenceId = persistence.id
	
	for k, v in pairs( self.stepsPanel.steps ) do
		v.panel:EditItem( persistence, itemClass )
	end
end

vgui.Register( "DItemCreator_Steps", PANEL, "DFrame" )