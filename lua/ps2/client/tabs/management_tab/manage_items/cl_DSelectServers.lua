local PANEL = {}

function PANEL:Init( )
	self:SetSize( 600, 400 )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self:SetTitle( "Item Server Restrictions" )
	
	self.infoPanel = vgui.Create( "DInfoPanel", self )
	self.infoPanel:Dock( TOP )
	self.infoPanel:SetInfo( "Server Restriction", 
[[This can be used to restrict items to certain servers. Items are only equiped for the servers they are restricted to.

Tick the servers that you want ro restrict the item(s) to. If the item has no restriction (no boxes ticked) it can be used on all servers.]] )
	self.infoPanel:DockMargin( 5, 5, 5, 5 )

	self.scroll = vgui.Create( "DScrollPanel", self )
	self.scroll:Dock( FILL )
	self.scroll:DockMargin( 5, 5, 5, 5 )
	
	Derma_Hook( self.scroll, "Paint", "Paint", "InnerPanel" )
	
	self.serversLayout = vgui.Create( "DIconLayout", self.scroll )
	self.serversLayout:Dock( TOP )
	self.serversLayout:DockMargin( 5, 5, 5, 5 )
	self.serversLayout:SetSpaceX( 10 )
	self.serversLayout:SetSpaceY( 5 )
	
	self.checkBoxes = {}

	self.serverSelectPromise = Pointshop2View:getInstance( ):getServers( )
	:Done( function( servers ) 
		for k, server in pairs( servers ) do
			local chkBox = vgui.Create( "DCheckBoxLabel", self.serversLayout )
			chkBox:SetText( server.name )
			chkBox:SizeToContents( )
			chkBox.OwnLine = true
			self.checkBoxes[server.id] = chkBox
		end
	end )
	
	self.buttons = vgui.Create( "DPanel", self )
	self.buttons:Dock( BOTTOM )
	self.buttons:SetTall( 30 )
	self.buttons.Paint = function( ) end
	self.buttons:DockMargin( 5, 5, 5, 5 )

	self.save = vgui.Create( "DButton", self.buttons )
	self.save:SetText( "Save" )
	self.save:SetImage( "pointshop2/floppy1.png" )
	self.save:SetWide( 180 )
	self.save.m_Image:SetSize( 16, 16 )
	self.save:Dock( RIGHT )
	function self.save.DoClick( )
		self:OnSave( )
		self:Close( )
	end
end

function PANEL:GetSelectedIds( )
	local ids = {}
	for id, box in pairs(self.checkBoxes) do
		if box:GetChecked( ) then
			table.insert( ids, id )
		end
	end
	return ids
end

function PANEL:SetSelectedServers( serverIds )
	self.serverSelectPromise:Done( function( )
		for k, id in pairs( serverIds ) do
			self.checkBoxes[id]:SetValue( true )
		end
	end )
end

function PANEL:OnSave( )
	--for override
end

vgui.Register( "DSelectServers", PANEL, "DFrame" )