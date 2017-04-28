local PANEL = {}

function PANEL:OnSelected( )
	hook.Run( "PACItemSelected", self.itemClass )
end

function PANEL:OnDeselected( )
	hook.Run( "PACItemDeSelected", self.itemClass )
end

derma.DefineControl( "DPointshopSimpleHatIcon", "", PANEL, "DPointshopSimpleItemIcon" )