
AddCSLuaFile()

local PANEL = {}

local matOverlay_Normal = Material( "gui/ContentIcon-normal.png" )
local matOverlay_Hovered = Material( "gui/ContentIcon-hovered.png" )
local matOverlay_AdminOnly = Material( "icon16/shield.png" )

AccessorFunc( PANEL, "m_Color", 			"Color" )
AccessorFunc( PANEL, "m_Type", 				"ContentType" )

--[[---------------------------------------------------------
   Name: Paint
-----------------------------------------------------------]]
function PANEL:Init()
	self:SetDrawBackground( false )
	self.Border = 2
	self:SetSize( 128, 128 )
	self:SetText( "" )
	self:SetDoubleClickingEnabled( false )

	self.actualIcon = false
	
	self.Label = self:Add( "DLabel" )
	self.Label:Dock( BOTTOM )
	self.Label:SetContentAlignment( 5 )
	self.Label:DockMargin( 4, 0, 4, 10 )
	self.Label:SetTextColor( Color( 255, 255, 255, 255 ) )
	self.Label:SetExpensiveShadow( 1, Color( 0, 0, 0, 200 ) )

	self:DockPadding( self.Border, self.Border, self.Border, self.Border )
end

function PANEL:SetItemClass( itemClass )
	self.itemClass = itemClass
	self.actualIcon = vgui.Create( itemClass:GetPointshopIconControl( ), self )
	self.actualIcon:Dock( FILL )
	self.actualIcon:SetDragParent( self )
	local w, h = itemClass:GetPointshopIconDimensions( )
	self:SetSize( w + self.Border, h + self.Border + self.Label:GetTall( ) )
	self.Label:SetText( itemClass.PrintName )
end


function PANEL:DoRightClick()
	local pCanvas = self:GetSelectionCanvas()
	if ( IsValid( pCanvas ) && pCanvas:NumSelectedChildren() > 0 ) then
		return hook.Run( "PS2_SpawnlistOpenGenericMenu", pCanvas )
	end

	self:OpenMenu()
end

function PANEL:DoClick()
end

function PANEL:OpenMenu()
end

function PANEL:OnDepressionChanged( b )
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopContentIcon" )

function PANEL:PaintOver( w, h )
	self:DrawSelections()
end

function PANEL:Copy()
	local copy = vgui.Create( "DPointshopContentIcon", self:GetParent() )

	copy:SetContentType( self:GetContentType() )
	copy:SetSpawnName( self:GetSpawnName() )
	copy:SetName( self.m_NiceName )
	copy:CopyBase( self )
	copy.DoClick = self.DoClick
	copy.OpenMenu = self.OpenMenu

	return copy;
end

derma.DefineControl( "DPointshopContentIcon", "", PANEL, "DButton" )