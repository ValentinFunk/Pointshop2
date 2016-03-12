local PANEL = {}

function PANEL:Init( )
	self:SetSize( 600, 400 )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	self:SetTitle( "Item Rank Restrictions" )

	self.infoPanel = vgui.Create( "DInfoPanel", self )
	self.infoPanel:Dock( TOP )
	self.infoPanel:SetInfo( "Rank Restriction",
[[This can be used to restrict items to certain ranks. Items can only be purchased by users that have a rank from the list.

Tick the ranks that you want ro restrict the item(s) to. If the item has no restriction (no boxes ticked) it can be bought by all ranks.]] )
	self.infoPanel:DockMargin( 5, 5, 5, 5 )

	self.scroll = vgui.Create( "DScrollPanel", self )
	self.scroll:Dock( FILL )
	self.scroll:DockMargin( 5, 5, 5, 5 )

	Derma_Hook( self.scroll, "Paint", "Paint", "InnerPanel" )

	self.ranksLayout = vgui.Create( "DIconLayout", self.scroll )
	self.ranksLayout:Dock( TOP )
	self.ranksLayout:DockMargin( 5, 5, 5, 5 )
	self.ranksLayout:SetSpaceX( 10 )
	self.ranksLayout:SetSpaceY( 5 )

	self.checkBoxes = {}

	for k, rank in pairs( PermissionInterface.getRanks( ) ) do
		local chkBox = vgui.Create( "DCheckBoxLabel", self.ranksLayout )
		chkBox:SetText( rank.title )
		chkBox:SizeToContents( )
		chkBox.OwnLine = true
		self.checkBoxes[rank.internalName] = chkBox
	end

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

function PANEL:GetSelectedRanks( )
	local rankNames = {}
	for internalName, box in pairs(self.checkBoxes) do
		if box:GetChecked( ) then
			table.insert( rankNames, internalName )
		end
	end
	return rankNames
end

function PANEL:SetSelectedRanks( rankNames )
	for k, name in pairs( rankNames ) do
    if self.checkBoxes[name] then
      self.checkBoxes[name]:SetValue( true )
    end
	end
end

function PANEL:OnSave( )
	--for override
end

vgui.Register( "DSelectRanks", PANEL, "DFrame" )
