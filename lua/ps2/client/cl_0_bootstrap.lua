--[[
    # Include all item bases
    This includes all item bases in kinv/items, applying base classes
    and mixins and makes them available in KInventory.Items.
]]--
KInventory.loadAllItems( )
hook.Add( "OnReloaded", "PS2_ReloadItems", function()
    if LibK.Debug then
        KInventory.loadAllItems()
    end
end )

--[[
    # Load Modules
    This includes all of the ps2 modules files in "lua/ps2/modules" after InitPostEntity.
]]--
LibK.InitPostEntityPromise:Then( function( ) 
    Pointshop2.LoadModules()
    hook.Run( "PS2_ModulesLoaded" )
end )
hook.Add( "OnReloaded", "PS2_ReloadModules", function()
    if LibK.Debug then
        Pointshop2.LoadModules()
        hook.Run( "PS2_ModulesLoaded" )
    end
end )