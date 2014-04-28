local PANEL = {}

function PANEL:Init( )
	self.selectPlayerElem = vgui.Create( "DPanel" )
	self.selectPlayerElem:SetTall( 64 )
	self.selectPlayerElem:SetWide( self:GetWide( ) )
	function self.selectPlayerElem:Paint( ) end
	
	self.materialPanel = vgui.Create( "DImage", self.selectPlayerElem )
	self.materialPanel:SetSize( 64, 64 )
	self.materialPanel:Dock( LEFT )
	self.materialPanel:SetTooltip( "Click to Select" )
	local frame = self
	function self.materialPanel:DoClick( )
		--Open model selector
		local window = vgui.Create( "DMaterialSelector" )
		window:Center( )
		window:MakePopup( )
		function window:OnChange( )
			frame.manualEntry:SetText( window.selectedMaterial )
			frame.materialPanel:SetMaterial( window.selectedMaterial )
		end
	end
	
	local rightPnl = vgui.Create( "DPanel", self.selectPlayerElem )
	rightPnl:Dock( FILL )
	function rightPnl:Paint( )
	end

	self.manualEntry = vgui.Create( "DTextEntry", rightPnl )
	self.manualEntry:Dock( TOP )
	self.manualEntry:DockMargin( 5, 0, 5, 5 )
	self.manualEntry:SetTooltip( "Click on the icon or manually enter the material path here and press enter" )
	function self.manualEntry:OnEnter( )
		frame.materialPanel:SetModel( self:GetText( ) )
	end
	
	local cont = self:addFormItem( "Model", self.selectPlayerElem )
	cont:SetTall( 64 )
end

function PANEL:SaveItem( saveTable )
	self.BaseClass.SaveItem( self, saveTable )
	saveTable.material = self.manualEntry:GetText( )
end

vgui.Register( "DPlayerModelCreator", PANEL, "DItemCreator" )
