--Interface
Pointshop2.AdminPanels = { }

function Pointshop2:AddManagementPanel( label, icon, controlName )
	table.insert( Pointshop2.AdminPanels, { label = label, icon = icon, controlName = controlName } )
end

--Tab Control
local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	for k, btnInfo in pairs( Pointshop2.AdminPanels ) do 
		local panel = vgui.Create( btnInfo.controlName )
		self:addMenuEntry( btnInfo.label, btnInfo.icon, panel )
	end
end

--Derma_Hook( PANEL, "Paint", "Paint", "PointshopManagementTab" )
derma.DefineControl( "DPointshopManagementTab", "", PANEL, "DPointshopMenuedTab" )

Pointshop2:AddTab( "Management", "DPointshopManagementTab" )