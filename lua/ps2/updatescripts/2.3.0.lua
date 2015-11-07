local tables = {
    "ps2_trailpersistence",
    "ps2_settings",
    "ps2_wallet",
    "ps2_itempersistence",
    "ps2_categories",
    "ps2_outfits",
    "ps2_equipmentslot",
    "ps2_itemmapping",
    "ps2_weaponpersistence",
    "ps2_instatswitchweaponpersistence",
    "ps2_weaponpersistence",
    "ps2_playermodelpersistence",
    "ps2_OutfitHatPersistenceMapping",
    "ps2_HatPersistence",
    "ps2_servers",
    "inventories",
    "kinv_items",
    "libk_player"
}

local DB

local def = Deferred( )

hook.Add( "LibK_DatabaseInitialized", "Initialized", function( dbObj, name )
	DB = dbObj

    if name != "Update" then
		return
	end

    if not DB.CONNECTED_TO_MYSQL then
        return def:Resolve()
    end

	if name != "Update" then
		return
	end

    local promises = {}
	for k, v in pairs( tables ) do
        table.insert( promises, DB.TableExists( v )
        :Then( function( exists )
            if exists then
                DB.DoQuery("ALTER TABLE " .. v .. " ENGINE=InnoDB;")
                KLogf(4, "Converted to InnoDB: %s", v)
            end
        end ) )
    end
    WhenAllFinished(promises):Done(function()
        def:Resolve()
    end)
end )

DB = LibK.getDatabaseConnection( LibK.SQL, "Update" )

return def:Promise( )
