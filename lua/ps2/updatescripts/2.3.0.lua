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

local DB = LibK.getDatabaseConnection( LibK.SQL, "Update" )
return DB.ConnectionPromise
:Then(function()
    if not DB.CONNECTED_TO_MYSQL then
        return
    end

    local promises = {}
	for k, v in pairs( tables ) do
        local promise = DB.TableExists( v )
        :Then( function( exists )
            if exists then
                KLogf(4, "Converted to InnoDB: %s", v)
                return DB.DoQuery("ALTER TABLE " .. v .. " ENGINE=InnoDB;")
            end
        end )

        table.insert( promises, promise )
    end

    return WhenAllFinished(promises)
end )