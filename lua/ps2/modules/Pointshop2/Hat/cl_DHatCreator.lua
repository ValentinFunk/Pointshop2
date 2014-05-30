local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self:addSectionTitle( "Model and Positioning" )
	
	local openBtn = vgui.Create( "DButton", self )
	openBtn:SetText( "Open Editor" )
	openBtn:SetWide( 120 )
	openBtn:SetImage( "pointshop2/pencil54.png" )
	openBtn.m_Image:SetSize( 16, 16 )
	function openBtn.DoClick( )
		local menu = DermaMenu( )
		menu:SetSkin( Pointshop2.Config.DermaSkin )
		if self.outfit then
			menu:AddOption( "Edit Outfit", function( )
				local f = vgui.Create( "DHatPositioner" )
				f:Center( )
				f:NewEmptyOutfit( )
				function f.OnSave( s, outfit )
					self:OutfitSaved( outfit )
				end
			end )
			menu:AddSpacer( )
		end
		
		menu:AddOption( "Create new Outfit", function( )
			local f = vgui.Create( "DHatPositioner" )
			f:Center( )
			f:NewEmptyOutfit( )
		end )
		menu:AddOption( "Import existing PAC Outfit", function( )
			local f = vgui.Create( "DHatPositioner" )
			f:Center( )
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
	
	local addBtn = vgui.Create( "DButton", self )
	addBtn:SetText( "Add" )
	addBtn:SetWide( 120 )
	addBtn:SetImage( "pointshop2/plus24.png" )
	addBtn.m_Image:SetSize( 16, 16 )
	addBtn:Dock( LEFT )
	function addBtn.DoClick( )
		local menu = DermaMenu( )
		menu:SetSkin( Pointshop2.Config.DermaSkin )
		local sub = menu:AddSubMenu( "Specify custom Model Path" )
		sub:AddOption( "Clone Base Outfit" )
		sub:AddOption( "New Outfit" )
		
		local cssSub = menu:AddSubMenu( "All CS:S Models" )
		cssSub:AddOption( "Clone Base Outfit" )
		cssSub:AddOption( "New Outfit" )
		
		menu:Open( )
		menu:MakePopup( )
	end
	
	local pnl = self:addFormItem( "Model Specific Outfit", addBtn )
	
	self.listView = vgui.Create( "DListView", self )
	self.listView:Dock( TOP )
	self.listView:DockMargin( 5, 5, 5, 5 )
	self.listView:AddColumn( "Model" )
	self.listView:AddColumn( "OutfitID" )
	self.listView:AddColumn( "Action" )
	function self.listView.AddLine( listView, ... )
		local line = DListView.AddLine( listView, ... )
		line.Columns[3] = vgui.Create( "DButton", line )
		line.Columns[3].Value = 0
		line.Columns[3]:SetText( "Open Editor" )
	end
	function self.listView:PerformLayout( )
		DListView.PerformLayout( self )
		self:SetTall( math.Clamp( 100, 50, #self:GetLines( ) * 20 + 20 ) )
	end
	
	
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

function PANEL:OutfitSaved( outfit )

end

function PANEL:SaveItem( saveTable )
	self.BaseClass.SaveItem( self, saveTable )
	saveTable.material = self.manualEntry:GetText( )
end

vgui.Register( "DHatCreator", PANEL, "DItemCreator" )
