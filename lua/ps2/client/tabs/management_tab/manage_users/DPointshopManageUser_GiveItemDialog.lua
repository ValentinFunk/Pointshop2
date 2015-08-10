local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self:SetTitle( "Give Item" )
	self:SetSize( 800, 600 )
	
	self.loadingNotifier = vgui.Create( "DLoadingNotifier", self )
	self.loadingNotifier:Dock( TOP )

	self.contentPanel = vgui.Create( "DPointshopContentPanel", self )
	self.contentPanel:Dock( FILL )
	--self.contentPanel:EnableModify( )
	self.contentPanel:CallPopulateHook( "PS2_PopulateContent", true )
	self.contentPanel:DockMargin( -3, 10, 0, 5 )
	
	hook.Add( "PS2_ItemIconSelected", self, function( self, panel, itemClass )
		if not itemClass then 
			return
		end
		self.lbl:SetText( "Selected Item: " .. itemClass.PrintName )
		self.lbl:SizeToContents( )
		self.selectedClass = itemClass.className
		self.btn:SetDisabled( false )
	end )
	
	self.bottomPanel = vgui.Create( "DPanel", self )
	self.bottomPanel:Dock( BOTTOM )
	self.bottomPanel:DockMargin( 5, 5, 5, 5 )
	self.bottomPanel:DockPadding( 5, 5, 5, 5 )
	self.bottomPanel:SetTall( 50 )
	Derma_Hook( self.bottomPanel, "Paint", "Paint", "InnerPanel" )
	
	self.lbl = vgui.Create( "DLabel", self.bottomPanel )
	self.lbl:SetText( "Selected Item: None" )
	self.lbl:SetFont( self:GetSkin( ).SmallTitleFont )
	self.lbl:SetColor( color_white )
	self.lbl:SizeToContents( )
	self.lbl:Dock( LEFT )
	self.lbl:SetWide( 200 )
	self.lbl:DockMargin( 10, 0, 0, 0 )
	
	self.btn = vgui.Create( "DButton", self.bottomPanel )
	self.btn:SetText( "Give" )
	self.btn:SetFont( self:GetSkin( ).SmallTitleFont )
	self.btn:SetColor( color_white )
	self.btn:Dock( RIGHT )
	self.btn:SizeToContents( )
	self.btn:SetWide( 100 )
	self.btn:SetDisabled( true )
	
	function self.btn.DoClick( )
		self.loadingNotifier:Expand( )
		self.btn:SetDisabled( true )
		Pointshop2View:getInstance( ):adminGiveItem( self.kPlayer.id, self.selectedClass )
		:Fail( function( err )
			Derma_Message( err, "Error" )
		end )
		:Always( function( )
			if IsValid( self.parent ) then
				self.parent:RefreshInventory( )
			end
			self:Remove( )
		end )
	end
end

function PANEL:SetKPlayer( ply )
	self.kPlayer = ply
	self:SetTitle( "Give an item to " .. ply.name )
end

vgui.Register( "DPointshopManageUser_GiveItemDialog", PANEL, "DFrame" )