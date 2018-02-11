local function sqliteUseAutoincrement( DB )
    local res = sql.Query([[
        PRAGMA foreign_keys = OFF;
        BEGIN;
        DROP TABLE IF EXISTS new_kinv_items;
        CREATE TABLE `new_kinv_items` (
            `itemclass` VARCHAR(255) NOT NULL, 
            `data` MEDIUMTEXT, 
            `inventory_id` INT(11), 
            `id` INTEGER PRIMARY KEY AUTOINCREMENT,
            `itempersistence_id` INT(11),
            CONSTRAINT `FK_428461545`
                FOREIGN KEY (`inventory_id`) 
                REFERENCES `inventories` (`id`) 
                ON DELETE SET NULL 
                ON UPDATE SET NULL,
            CONSTRAINT `FK_3675580661`
                FOREIGN KEY (`itempersistence_id`) 
                REFERENCES `ps2_itempersistence` (`id`) 
                ON DELETE CASCADE 
                ON UPDATE SET NULL
        );
        INSERT INTO new_kinv_items SELECT `itemclass`, `data`, `inventory_id`, `id`, `itempersistence_id` FROM kinv_items;
        DROP TABLE kinv_items;
        ALTER TABLE new_kinv_items RENAME TO kinv_items;
        COMMIT;
        PRAGMA foreign_keys = ON;
    ]])

    if res == false then
        local res = Promise.Reject(0, sql.LastError())
        sql.Query("ROLLBACK")
        return res
    end
    return Promise.Resolve()
end

local DB = LibK.getDatabaseConnection( LibK.SQL, "Update" )

return DB.ConnectionPromise:Then( function( )
    return DB.TableExists('kinv_items')
end )
:Then( function( shouldUpdate )
    KLogf( 2, "[INFO] We are on %s and %s to update", DB.CONNECTED_TO_MYSQL and "MySQL" or "SQLite", shouldUpdate and "need" or "don't need" )
    if not shouldUpdate then
        return
    end

    if DB.CONNECTED_TO_MYSQL then
        return
    else
        return sqliteUseAutoincrement( DB )
    end
end )
:Then( function() end, function( errid, err )
    KLogf( 2, "[ERROR] Error during update: %i, %s.", errid, err )
    return Promise.Reject( errid, err )
end )