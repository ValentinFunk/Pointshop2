local PANEL = {}

function PANEL:Init( )
	self:addSectionTitle( "Trail Selection" )
	
	self.selectPlayerElem = vgui.Create( "DPanel" )
	self.selectPlayerElem:SetTall( 64 )
	self.selectPlayerElem:SetWide( self:GetWide( ) )
	function self.selectPlayerElem:Paint( ) end
	
	self.materialPanel = vgui.Create( "DImage", self.selectPlayerElem )
	self.materialPanel:SetSize( 64, 64 )
	self.materialPanel:Dock( LEFT )
	self.materialPanel:SetMouseInputEnabled( true )
	self.materialPanel:SetTooltip( "Click to Select" )
	self.materialPanel:SetMaterial( "trails/musicalnotes" )
	local frame = self
	function self.materialPanel:OnMousePressed( )
		--Open model selector
		local window = vgui.Create( "DTrailSelector" )
		window:Center( )
		window:MakePopup( )
		window:DoModal()
		function window:OnChange( )
			frame.manualEntry:SetText( window.matName )
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
	self.manualEntry:SetText( "trails/musicalnotes" )
	self.manualEntry:SetTooltip( "Click on the icon or manually enter the material path here and press enter" )
	function self.manualEntry:OnEnter( )
		frame.materialPanel:SetMaterial( self:GetText( ) )
	end
	
	local cont = self:addFormItem( "Material", self.selectPlayerElem )
	cont:SetTall( 64 )
end

function PANEL:SaveItem( saveTable )
	self.BaseClass.SaveItem( self, saveTable )
	saveTable.material = self.manualEntry:GetText( )
end

function PANEL:EditItem( persistence, itemClass )
	self.BaseClass.EditItem( self, persistence.ItemPersistence, itemClass )
	
	self.manualEntry:SetText( persistence.material )
	self.materialPanel:SetMaterial( persistence.material )
end

vgui.Register( "DTrailCreator", PANEL, "DItemCreator" )
