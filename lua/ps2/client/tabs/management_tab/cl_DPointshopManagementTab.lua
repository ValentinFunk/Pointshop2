--Interface
Pointshop2.AdminPanels = { }

function Pointshop2:AddManagementPanel( label, icon, controlName, shouldShow )
	table.insert( Pointshop2.AdminPanels, { label = label, icon = icon, controlName = controlName, shouldShow = shouldShow } )
end

--Tab Control
local PANEL = {}

function PANEL:Init( )
	self:SetSkin( Pointshop2.Config.DermaSkin )
	
	for k, btnInfo in pairs( Pointshop2.AdminPanels ) do 
		if btnInfo.shouldShow and not btnInfo.shouldShow() then
			continue
		end
		
		local panel = vgui.Create( btnInfo.controlName )
		self:addMenuEntry( btnInfo.label, btnInfo.icon, panel )
	end
end

--Derma_Hook( PANEL, "Paint", "Paint", "PointshopManagementTab" )
derma.DefineControl( "DPointshopManagementTab", "", PANEL, "DPointshopMenuedTab" )

Pointshop2:AddTab( "Management", "DPointshopManagementTab", function( )
	--Only show the management tab if user has access to at least on admin panel
	for k, v in pairs( Pointshop2.AdminPanels ) do
		if v.shouldShow( ) then
			return true
		end
	end
	return false
end )