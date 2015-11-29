local PANEL = {}

function PANEL:Init( )
	self:SetTitle( "Add an Item Type" )
	
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self:SetSize( 800, math.Clamp( ScrH( ), 0, 768 ) )
	
	self.steps = vgui.Create( "DStepPanel", self )
	self.steps:Dock( FILL )
	
	self.bottomPnl = vgui.Create( "DPanel", self )
	self.bottomPnl:Dock( BOTTOM )
	Derma_Hook( self.bottomPnl, "Paint", "Paint", "InnerPanel" ) 
	self.bottomPnl:SetTall( 40 )
	self.bottomPnl:DockPadding( 5, 5, 5, 5 )
	
	self.finishBtn = vgui.Create( "DButton", self.bottomPnl )
	self.finishBtn:SetText( "Finish" )
	self.finishBtn:Dock( RIGHT )
	self.finishBtn:DockMargin( 5, 0, 0, 0 )
	self.finishBtn:SetDisabled( true )
	function self.finishBtn.DoClick( )
		self:OnFinish( self.selectedFactory, self.configurator:GetSettingsForSave( ) )
	end
	
	self.backBtn = vgui.Create( "DButton", self.bottomPnl )
	self.backBtn:SetText( "Back" )
	self.backBtn:Dock( RIGHT )
	self.backBtn:SetDisabled( true )
	function self.backBtn.DoClick( )
		self.steps:PopStep( )
	end
	
	self.picker = vgui.Create( "DItemFactoryPicker", self )
	self.steps:AddStep( "Pick a creator", self.picker )
	function self.picker.OnChange( )
		self.selectedFactory = self.picker.selectedFactory
		
		self.configurator = vgui.Create( self.selectedFactory.GetConfiguratorControl( ) )
		self.steps:AddStep( "Configuration", self.configurator )
		
		self.steps:NextStep( )
		self.backBtn:SetDisabled( false )
	end
	
	function self.steps.OnStepChanged( )
		if self.steps.currentStep == 1 then
			self.backBtn:SetDisabled( true )
			self.finishBtn:SetDisabled( true )
		elseif self.steps.currentStep == 2 then
			self.finishBtn:SetDisabled( false )
		end
	end
end

function PANEL:OnFinish( settings )
end

vgui.Register( "DItemFactoryConfigurationFrame", PANEL, "DFrame" )