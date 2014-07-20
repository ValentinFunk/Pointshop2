local PANEL = {}

function PANEL:Init( )
	self:SetSize( 300, 300 )
	self:SetTitle( "Reset to defaults" )
	
	self.warning = vgui.Create( "DMultilineLabel", self )
	self.warning:InsertColorChange( 255, 0, 0, 255 )
	self.warning:AppendText( "WARNING: This will permanently remove all items, inventories, points, settings and categories and reset your pointshop to the default installation! Once done, this step cannot be undone! The map will be changed after the reset!" )
	self.warning:Dock( FILL )
	self.warning.PerformLayout = function( ) end
	
	self.button = vgui.Create( "DButton", self )
	self.button:Dock( BOTTOM )
	self.button:SetText( "Reset Pointshop" )
	function self.button.DoClick( )
		Pointshop2View:getInstance( ):resetToDefaults( )
	end
end

function PANEL:ApplySchemeSettings( )
	self.warning.font = self:GetSkin().SmallTitleFont
end

--interface, has to be defined
function PANEL:SetModule( )
end

function PANEL:SetData( )
end


vgui.Register( "DPointshopReset", PANEL, "DFrame" )