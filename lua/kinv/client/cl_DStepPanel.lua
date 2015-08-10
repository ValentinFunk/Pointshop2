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
	panel:Dock( FILL )
	
	if self.currentStep == 0 then
		self:NextStep( )
	end
	
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
		error( "Underflow" )
	end
	
	self.currentStep = self.currentStep - 1
	self:Update( )
	
	self:OnStepChanged( )
end

function PANEL:NextStep( )
	if #self.steps <= self.currentStep then
		self:OnCompleted( )
	end
	
	self.currentStep = self.currentStep + 1
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