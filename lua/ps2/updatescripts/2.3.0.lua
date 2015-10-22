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

    if not DB.CONNECTED_TO_MYSQL then
        def:Resolve()
    end

	if name != "Update" then
		return
	end

	for k, v in pairs( tables ) do
        DB.TableExists( v )
        :Then( function( exists )
            if exists then
                DB.DoQuery("ALTER TABLE " .. v .. " ENGINE=InnoDB;")
                KLogf(4, "Converted to InnoDB: %s", v)
            end
        end )
    end
end )

DB = LibK.getDatabaseConnection( LibK.SQL, "Update" )

return def:Promise( )
