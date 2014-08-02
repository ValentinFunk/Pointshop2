local PANEL = {}

function PANEL:Init( )
	self:SetSize( 225, 125 )
	
	self:SetTitle( "Points Over Time Rank" )
	
	local panel = vgui.Create( "DPanel", self )
	panel:Dock( TOP )
	panel:DockMargin( 5, 0, 5, 5 )
	panel.Paint = function( ) end
	
	panel.label = vgui.Create( "DLabel", panel )
	panel.label:SetText( "Rank" )
	panel.label:Dock( LEFT )
	panel.label:SetWide( 110 )
	
	panel.control = vgui.Create( "DComboBox", panel )
	panel.control:Dock( LEFT )
	panel.control:SetColor( color_black )
	panel.control:SetWide( 100 )
	function panel.control.OnSelect( _self, index, value, data )
		self.selectedRank = data 
	end
	for k, v in pairs( PermissionInterface.getRanks( ) ) do
		local choice = panel.control:AddChoice( v.title, v )
		if k == 1 then
			panel.control:ChooseOptionID( 1 )
		end
	end
	
	self.rankPanel = panel
	
	local panel = vgui.Create( "DPanel", self )
	panel:Dock( TOP )
	panel:DockMargin( 5, 0, 5, 5 )
	panel.Paint = function( ) end
	
	panel.label = vgui.Create( "DLabel", panel )
	panel.label:SetText( "Point Multiplier" )
	panel.label:Dock( LEFT )
	panel.label:SetWide( 110 )
	
	panel.control = vgui.Create( "DNumberWang", panel )
	panel.control:Dock( LEFT )
	panel.control:SetMin( 1 )
	panel.control:SetMax( 10000 )
	panel.control:SetWide( 100 )
	panel.control:SetValue( 1.2 )
	function panel.control.OnKeyCodeTyped( pnl, code )
		if code == KEY_ENTER then
			if not self.save:GetDisabled( ) then
				self.save:DoClick( )
			end
		end
	end
	
	self.pointsPanel = panel
	
	self.buttons = vgui.Create( "DPanel", self )
	self.buttons:Dock( BOTTOM )
	self.buttons:SetTall( 30 )
	self.buttons.Paint = function( ) end
	--self.buttons:DockPadding( 5, 5, 5, 5 )
	--Derma_Hook( self.buttons, "Paint", "Paint", "InnerPanel" )
	
	self.save = vgui.Create( "DButton", self.buttons )
	self.save:SetText( "Save" )
	self.save:SetImage( "pointshop2/floppy1.png" )
	self.save:SetWide( 100 )
	self.save.m_Image:SetSize( 16, 16 )
	self.save:Dock( RIGHT )
	function self.save.DoClick( )
		self:OnSaved( self.selectedRank, self.pointsPanel.control:GetValue( ) )
	end
end

function PANEL:ApplySchemeSettings( )
	self.rankPanel.label:SetFont( self:GetSkin( ).fontName or "DermaDefault" )
	self.pointsPanel.label:SetFont( self:GetSkin( ).fontName or "DermaDefault" )
	self.save:SetFont( self:GetSkin( ).fontName )
end

function PANEL:EditRank( rank, multiplier )
	self.rankPanel.control:SetDisabled( true )
	self.rankPanel.control:SetText( rank.title )
	self.pointsPanel.control:SetValue( multiplier )
	self.pointsPanel.control:RequestFocus( )
end

function PANEL:OnSaved( rank, multiplier )
	--for overwrites
end

vgui.Register( "DPointsOverTimeConfigurator_AddRank", PANEL, "DFrame" )