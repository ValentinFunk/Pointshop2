local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )

	self.loadingNotifier = vgui.Create( "DLoadingNotifier", self )
	self.loadingNotifier:Dock( TOP )

	self:SetSkin( Pointshop2.Config.DermaSkin )

	self:DockPadding( 10, 0, 10, 10 )

	local label = vgui.Create( "DLabel", self )
	label:SetText( "Servers Running on your MySQL" )
	label:SetColor( color_white )
	label:SetFont( self:GetSkin( ).TabFont )
	label:SizeToContents( )
	label:Dock( TOP )

	self.serversTbl = vgui.Create( "DListView", self )
	self.serversTbl:Dock( TOP )

	local frame = self
	self.serversTbl:AddColumn( "ID" )
	self.serversTbl:AddColumn( "Name" )
	self.serversTbl:AddColumn( "IP" )
	self.serversTbl:AddColumn( "Port" )
	self.serversTbl:SetTall( 300 )
	function self.serversTbl:OnRowRightClick( id, line )
		local menu = DermaMenu()
		menu:SetSkin( Pointshop2.Config.DermaSkin )

		menu:AddOption( "Set as current (Migrate)", function( )
			frame.loadingNotifier:Expand( )
			Pointshop2View:getInstance( ):migrateServer( line.server )
			:Done( function( )
				frame:LoadServers( )
			end )
			:Fail( function( err )
				Derma_Message( err, "Error" )
			end )
			:Always( function( )
				frame.loadingNotifier:Collapse( )
			end )
		end )

		menu:AddOption( "Remove", function( )
			frame.loadingNotifier:Expand( )
			Pointshop2View:getInstance( ):removeServer( line.server )
			:Done( function( )
				frame:LoadServers( )
			end )
			:Fail( function( err )
				Derma_Message( err, "Error" )
			end )
			:Always( function( )
				frame.loadingNotifier:Collapse( )
			end )
		end )

		menu:Open( )
	end

	self.buttons = vgui.Create( "DPanel", self )
	self.buttons:Dock( TOP )
	self.buttons:SetTall( 30 )
	self.buttons.Paint = function( ) end
	self.buttons:DockMargin( 0, 5, 5, 5 )
	--Derma_Hook( self.buttons, "Paint", "Paint", "InnerPanel" )

	self.save = vgui.Create( "DButton", self.buttons )
	self.save:SetText( "Refresh" )
	self.save:SetImage( "pointshop2/actualize.png" )
	self.save:SetWide( 180 )
	self.save.m_Image:SetSize( 16, 16 )
	self.save:Dock( LEFT )
	function self.save.DoClick( )
		self:LoadServers( )
	end
	self:LoadServers()

	derma.SkinHook( "Layout", "PointshopManagementTab_Servers", self )
end

function PANEL:LoadServers( )
	self.serversTbl:SetDisabled( true )
	self.loadingNotifier:Expand( )
	Pointshop2View.getInstance( ):getServers( )
	:Done( function( servers )
		if not IsValid( self ) or not IsValid( self.serversTbl ) then
			return
		end

		self.serversTbl:Clear( )
		for k, v in pairs( servers ) do
			self.serversTbl:AddLine( v.id, v.name, v.ip, v.port ).server = v
		end
	end )
	:Fail( function( err )
		Derma_Message( err, "Error" )
	end )
	:Always( function( )
		if not IsValid( self ) or not IsValid( self.serversTbl ) then
			return
		end
		 
		self.loadingNotifier:Collapse( )
		self.serversTbl:SetDisabled( false )
	end )
end

function PANEL:Paint( )
end

derma.DefineControl( "DPointshopManagementTab_Servers", "", PANEL, "DPanel" )

Pointshop2:AddManagementPanel( "Manage Servers", "pointshop2/rack1.png", "DPointshopManagementTab_Servers", function( )
	return PermissionInterface.query( LocalPlayer(), "pointshop2 manageservers" )
end )
