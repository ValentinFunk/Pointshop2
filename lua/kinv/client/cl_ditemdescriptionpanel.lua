local PANEL = {}
function PANEL:Init( )
	self:SetSkin( KInventory.Config.DermaSkin )
	self:DockPadding( 5, 10, 5, 5 )
	
	self.descriptionLabel = vgui.Create( "DPointshopItemDescription", self )
	self.descriptionLabel._control = "DPointshopItemDescription"
	self.descriptionLabel:DockMargin( 0, 5, 0, 5 )
	self.descriptionLabel:Dock( FILL )
	self.descriptionLabel.Paint = function() end
	self.descriptionLabel.description.Paint = function(p, w, h) surface.SetDrawColor(68, 68, 68 , 240) 	surface.DrawRect(0, 0, w, h ) end

	derma.SkinHook( "Layout", "ItemDescriptionPanel", self )
end

function PANEL:Think( )
	self.descriptionLabel:SetToFullHeight( )
	self.descriptionLabel:SetTall( self.descriptionLabel:GetTall( ) + 10 )
	self:SetTall( 10 + self.descriptionLabel:GetTall( ) )
	self:SizeToContents( )
end

function PANEL:SetTargetPanel( pnl )
	self.targetPanel = pnl
end

function PANEL:SetItem( item )
	local control = item.class.GetPointshopDescriptionControl()
	if self.descriptionLabel._control == control then
		self.descriptionLabel:SetItem( item, true )
		self.descriptionLabel:SizeToContents( )
	else
		self.descriptionLabel:Remove()
		self.descriptionLabel = vgui.Create( control, self )
		self.descriptionLabel._control = control
		self.descriptionLabel:DockMargin( 0, 5, 0, 5 )
		self.descriptionLabel:Dock( FILL )
		self.descriptionLabel.Paint = function() end
		self.descriptionLabel.description.Paint = function(p, w, h) surface.SetDrawColor(68, 68, 68 , 240) 	surface.DrawRect(0, 0, w, h ) end
		self.descriptionLabel:SetItem( item, true )
	end
end
	
-- only for indexed tables!
function table.reverse ( tab )
	local size = #tab
	local newTable = {}
 
	for i,v in ipairs ( tab ) do
		newTable[size-i] = v
	end
 
	return newTable
end

Derma_Hook( PANEL, "Paint", "Paint", "ItemDescriptionPanel" )
vgui.Register( "DItemDescriptionPanel", PANEL, "DPanel" )