local PANEL = {}

function PANEL:Init( )
	self:addSectionTitle( "Model and Positioning" )
	local openBtn = vgui.Create( "DButton" )
	openBtn:SetText( "Open" )
	function openBtn.DoClick( )
		local f = vgui.Create( "DHatPositioner" )
		f:Center( )
	end
	
	self:addFormItem( "Item Editor", openBtn )
	
	self:addSectionTitle( "Item Icon" )
	
	local iconBox = vgui.Create( "DPanel", self )
	iconBox:Dock( TOP )
	iconBox:SetTall( 65 )
	function iconBox:Paint( ) end
	
	local choice = vgui.Create( "DRadioChoice", iconBox )
	choice:Dock( FILL )
	choice:AddOption( "Automatic" )
	local materialChoice = choice:AddOption( "Use Material" )
	local materialInputBox = vgui.Create( "DTextEntry", materialChoice )
	materialInputBox:Dock( LEFT )
	materialInputBox:DockMargin( 100, 0, 0, 0 )
	materialInputBox:SetWide( 250 )
	
	choice:DockMargin( 5, 5, 5, 5 )
	function choice:OnChange( )
		if materialChoice:GetChecked( ) then
			materialInputBox:SetDisabled( false )
		else
			materialInputBox:SetDisabled( true )
		end
	end
	choice:OnChange( )
end

function PANEL:SaveItem( saveTable )
	self.BaseClass.SaveItem( self, saveTable )
	saveTable.material = self.manualEntry:GetText( )
end

vgui.Register( "DHatCreator", PANEL, "DItemCreator" )
