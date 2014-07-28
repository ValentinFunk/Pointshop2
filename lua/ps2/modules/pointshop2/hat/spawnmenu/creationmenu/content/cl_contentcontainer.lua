local PANEL = {}

DEFINE_BASECLASS( "DScrollPanel" );

AccessorFunc( PANEL, "m_pControllerPanel", 				"ControllerPanel" )
AccessorFunc( PANEL, "m_strCategoryName", 				"CategoryName" )
AccessorFunc( PANEL, "m_bTriggerSpawnlistChange", 		"TriggerSpawnlistChange" )

--[[---------------------------------------------------------
   Name: Init
-----------------------------------------------------------]]
function PANEL:Init()

	self:SetPaintBackground( false )
	
	self.IconList = vgui.Create( "DTileLayout", self:GetCanvas() )
	self.IconList:SetBaseSize( 16 )
	self.IconList:MakeDroppable( "SandboxContentPanel", true )
	self.IconList:SetSelectionCanvas( true )
	--self.IconList:SetUseLiveDrag( true )
	self.IconList:Dock( TOP )
	self.IconList.OnModified = function() self:OnModified() end
	
end

function PANEL:Add( pnl )

	self.IconList:Add( pnl )
	
	if ( pnl.InstallMenu ) then
		pnl:InstallMenu( self )
	end

	self:Layout()

end

function PANEL:Layout()

	self.IconList:Layout()
	self:InvalidateLayout()
	
end

function PANEL:PerformLayout()

	BaseClass.PerformLayout( self )
	self.IconList:SetMinHeight( self:GetTall() - 16 )

end

--[[---------------------------------------------------------
   Name: RebuildAll
-----------------------------------------------------------]]
function PANEL:RebuildAll( proppanel )

	local items = self.IconList:GetChildren()
	
	for k, v in pairs( items ) do
	
		v:RebuildSpawnIcon()
	
	end
	
end

--[[---------------------------------------------------------
   Name: GetCount
-----------------------------------------------------------]]
function PANEL:GetCount()

	local items = self.IconList:GetChildren()
	return #items
	
end


function PANEL:Clear()

	self.IconList:Clear( true )

end

function PANEL:ContentsToTable( contentpanel )

	local tab = {}
	
	local items = self.IconList:GetChildren()
	
	for k, v in pairs( items ) do
	
		v:ToTable( tab )
	
	end
	
	return tab

end

function PANEL:Copy()

	local copy = vgui.Create( "PS2_ContentContainer", self:GetParent() )
	copy:CopyBase( self )
	
	copy.IconList:CopyContents( self.IconList )
	
	return copy	

end

vgui.Register( "PS2_ContentContainer", PANEL, "DScrollPanel" )