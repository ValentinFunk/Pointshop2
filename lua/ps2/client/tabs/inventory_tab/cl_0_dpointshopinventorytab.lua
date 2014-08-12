Pointshop2.InventoryPanels = { }
function Pointshop2:AddInventoryPanel( label, icon, controlName, shouldShow )
	table.insert( Pointshop2.InventoryPanels, { label = label, icon = icon, controlName = controlName, shouldShow = shouldShow } )
end


local PANEL = {}

function PANEL:Init( )
	for k, btnInfo in pairs( Pointshop2.InventoryPanels ) do
		if btnInfo.shouldShow and not btnInfo.shouldShow() then
			continue
		end
		
		local panel = vgui.Create( btnInfo.controlName )
		self:addMenuEntry( btnInfo.label, btnInfo.icon, panel )
	end
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopInventoryTab" )
derma.DefineControl( "DPointshopInventoryTab", "", PANEL, "DPointshopMenuedTab" )

Pointshop2:AddTab( "Inventory", "DPointshopInventoryTab" )
