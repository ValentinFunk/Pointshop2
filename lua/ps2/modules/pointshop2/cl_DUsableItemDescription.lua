local PANEL = {}

function PANEL:Init( )
	local itemDesc = self
	function self.buttonsPanel:AddUseButton( )
		self.useButton = vgui.Create( "DButton", self )
		self.useButton:SetText( "Use" )
		self.useButton:DockMargin( 0, 5, 0, 0 )
		self.useButton:Dock( TOP )
		function self.useButton:DoClick( )
			if itemDesc.item:UseButtonClicked( ) then
				self:SetDisabled( true )
			end
		end
		function self.useButton:Think( )
			local canBeUsed, hint = itemDesc.item:CanBeUsed( )
			if not canBeUsed then
				self:SetDisabled( true )
				self:SetTooltip( hint )
			else
				self:SetDisabled( false )
			end
		end
	end
end

function PANEL:AddSingleUseInfo( )
	if IsValid( self.singleUsePanel ) then
		self.singleUsePanel:Remove( )
	end
	
	self.singleUsePanel = vgui.Create( "DPanel", self )
	self.singleUsePanel:Dock( TOP )
	self.singleUsePanel:DockMargin( 0, 8, 0, 0 )
	Derma_Hook( self.singleUsePanel, "Paint", "Paint", "InnerPanelBright" )
	self.singleUsePanel:SetTall( 50 )
	self.singleUsePanel:DockPadding( 5, 5, 5, 5 )
	function self.singleUsePanel:PerformLayout( )
		self:SizeToChildren( false, true )
	end
	
	local label = vgui.Create( "DLabel", self.singleUsePanel )
	label:SetText( "This item is a single-use item" )
	label:Dock( TOP )
	label:SizeToContents( )
end

function PANEL:SetItem( item, noButtons )
	self.BaseClass.SetItem( self, item, noButtons )
	self:AddSingleUseInfo( )
	if not noButtons then
		self.buttonsPanel:AddUseButton( )
	end
end

function PANEL:SetItemClass( itemClass )
	self.BaseClass.SetItemClass( self, itemClass )
	self:AddSingleUseInfo( )
end

function PANEL:SelectionReset( )
	self.BaseClass.SelectionReset( self )
	if self.singleUsePanel then
		self.singleUsePanel:Remove( )
	end
end

derma.DefineControl( "DUsableItemDescription", "", PANEL, "DPointshopItemDescription" )