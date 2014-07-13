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
end

function PANEL:PerformLayout( )
	self.userSelection:SetWide( self:GetWide( ) / 2 )
end

function PANEL:Paint( )
end

derma.DefineControl( "DPointshopManagementTab_Users", "", PANEL, "DPanel" )

Pointshop2:AddManagementPanel( "Manage Users", "pointshop2/user48.png", "DPointshopManagementTab_Users", function( )
	return PermissionInterface.query( LocalPlayer(), "pointshop2 manageusers" )
end )