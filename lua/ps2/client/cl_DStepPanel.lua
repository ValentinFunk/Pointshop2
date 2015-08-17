local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self.steps = {}
	self.currentStep = 0
	
	self.title = vgui.Create( "DLabel", self )
	self.title:Dock( TOP )
	self.title:SetFont( self:GetSkin( ).TabFont )
	self.title:SetColor( color_white )
	self.title:DockMargin( 0, 0, 0, 5 )
	
	self.panels = vgui.Create( "DPanel", self )
	self.panels:Dock( FILL )
	
	self.panels:DockMargin( 5, 5, 5, 5 )
	self.panels.Paint = function( ) end
	function self.panels:PerformLayout( )
		self:SizeToChildren( false, true )
	end
end

-- Size to step panels
function PANEL:SetAdaptiveSize( bAutoSize )
	if bAutoSize then
		self.panels:Dock( TOP )
		self.autoSize = true
	else
		self.panels:Dock( FILL )
		self.autoSize = false
	end
end

function PANEL:PerformLayout( )
	if self.autoSize then
		self:SizeToChildren( false, true )
	end
end

function PANEL:AddStep( name, panel )
	table.insert( self.steps, {
		name = name,
		panel = panel
	} )
	local index = #self.steps
	
	panel:SetParent( self.panels )
	panel:SetVisible( false)
	panel:SetZPos( -100 )
	if self.autoSize then
		panel:Dock( TOP )
	else
		panel:Dock( FILL )
	end
		
	if self.currentStep == 0 then
		self:NextStep( )
	end
	
	self:InvalidateLayout( )
	
	return index, self.steps[index]
end

function PANEL:PopStep( )
	local old = self.currentStep
	self:PreviousStep( )
	self:RemoveStep( old )
end

function PANEL:RemoveStep( index )
	if index <= self.currentStep then
		error( "Can't remove current/completed steps" )
	end
	
	table.remove( self.steps, index )
end

function PANEL:PreviousStep( )
	if self.currentStep == 1 then
		error( "Can't go to previous step, no more steps left", 1 )
	end
	
	self:GoToStep( self.currentStep - 1 )
end

function PANEL:NextStep( )
	if #self.steps <= self.currentStep then
		return self:OnCompleted( )
	end
	
	self:GoToStep( self.currentStep + 1 )
end

function PANEL:GoToStep( stepNumber )
	if stepNumber < 1 or stepNumber > #self.steps then
		error( "Invalid step number given to DStepPanel:GoToStep()", 1 )
	end
	
	self.currentStep = stepNumber
	self:Update( )
	self:OnStepChanged( )
end

function PANEL:Update( )
	for k, v in pairs( self.steps ) do
		if k != self.currentStep then
			v.panel:SetVisible( false )
			v.panel:SetZPos( -100 )
		else
			v.panel:SetVisible( true )
			v.panel:SetZPos( 1 )
			self.title:SetText( v.name )
			self.title:SizeToContents( )
		end
	end
end

function PANEL:OnCompleted( )

end

function PANEL:OnStepChanged( )
end
 
function PANEL:Paint( w, h )

end

vgui.Register( "DStepPanel", PANEL, "DPanel" )