local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	self.userSelection = vgui.Create( "DPointshopManageUser_SelectUser", self )
	self.userSelection:Dock( LEFT )
	function self.userSelection:OnUserSelected( selectedUserId )
		self:SetDisabled( true )
		self:GetParent( ).userDetails:NotifyLoading( true )
		Pointshop2View:getInstance( ):getUserDetails( selectedUserId )
		:Done( function( result )
			if not self:GetParent( ).userSelectionCollapsed then
				self:GetParent( ):CollapseUserSelection( )
			end
			self:GetParent( ).userDetails:SetPlayerData( result )
			self:GetParent( ).userDetails:NotifyLoading( false, true )
		end )
		:Fail( function( errid, err )
			Derma_Message( err, "Error loading" )
			self:GetParent( ).userDetails:NotifyLoading( false, false )
		end )
		:Always( function( )
			self:SetDisabled( false )
		end )
	end
	
	self.userDetails = vgui.Create( "DPointshopManageUser_UserDetails", self )
	self.userDetails:Dock( FILL )
	self.userDetails:DockMargin( 5, 0, 0, 0 )

	self.toggleBtn = vgui.Create( "DButton", self )
	self.toggleBtn:SetText("<")
	self.toggleBtn:SetSize( 40, 80 )
	self.toggleBtn:SetPos(self.userDetails:GetWide() + 10)
	function self.toggleBtn.DoClick()
		self:CollapseUserSelection()
	end
end

function PANEL:CollapseUserSelection( )
	if self.tweenInstance then return end

	local targetSize = self.userSelectionCollapsed and self.userSelection.normalWide or 150
	local startSize = self.userSelection:GetWide()
	local promise, tweenInstance = LibK.tween( easing.outQuart, 0.25, function( p )
		if IsValid(self.userSelection) then
			self.userSelection:SetSize( startSize + ( targetSize - startSize ) * p, self.userSelection:GetTall() )
			self.toggleBtn:SetText( self.userSelectionCollapsed and '<'or '>' )
		end
	end )
	promise:Then(function() if IsValid(self) then self.userSelectionCollapsed = not self.userSelectionCollapsed end end )
end

function PANEL:PerformLayout( )
	if not self.first then
		self.first = true
		self.userSelection.normalWide = self:GetWide( ) / 2
		self.userSelection:SetWide( self.userSelection.normalWide )
	end
	self.toggleBtn:SetPos( self.userSelection:GetWide() - self.toggleBtn:GetWide() + 10, self.userSelection:GetTall() / 2 - self.toggleBtn:GetTall() / 2 )
end

function PANEL:Paint( )
end

derma.DefineControl( "DPointshopManagementTab_Users", "", PANEL, "DPanel" )

Pointshop2:AddManagementPanel( "Manage Users", "pointshop2/user48.png", "DPointshopManagementTab_Users", function( )
	return PermissionInterface.query( LocalPlayer(), "pointshop2 manageusers" )
end )