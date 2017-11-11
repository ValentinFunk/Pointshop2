local function migrateInventoryIdMySql( DB )
    local fkName = "FK_" .. util.CRC( "KInventory.Item_ItemPersistence_Pointshop2.ItemPersistence" )
    return DB.DoQuery(Format([[
        START TRANSACTION;
        ALTER TABLE `kinv_items` ADD `itempersistence_id` INT(11);
        ALTER TABLE `kinv_items` ADD
            CONSTRAINT `%s` 
                FOREIGN KEY (`itempersistence_id`) 
                REFERENCES `ps2_itempersistence` (`id`) 
                ON DELETE CASCADE 
                ON UPDATE SET NULL;
        COMMIT;
    ]], fkName))
end

local function migrateInventoryIdSQLite( DB )
    local res = sql.Query([[
        PRAGMA foreign_keys = OFF;
        BEGIN;
        CREATE TABLE `new_kinv_items` (
            `itemclass` VARCHAR(255) NOT NULL, 
            `data` MEDIUMTEXT, 
            `inventory_id` INT(11), 
            `id` INTEGER,
            `itempersistence_id` INT(11),
            PRIMARY KEY (`id` ASC), 
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
        INSERT INTO new_kinv_items 
            SELECT itemclass, data, inventory_id, id,
                CASE WHEN CAST(substr(itemclass, 18) AS NUMERIC) = 0 THEN NULL ELSE CAST(substr(itemclass, 18) AS NUMERIC) END AS itempersistence_id
            FROM kinv_items;
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

    return DB.FieldExistsInTable( "ps2_itempersistence", "itempersistence_id" ):Then(function(exists)
        if exists then return end

        if DB.CONNECTED_TO_MYSQL then
            if (mysqloo.VERSION != "9" || !mysqloo.MINOR_VERSION || tonumber(mysqloo.MINOR_VERSION) < 3) then
                return Promise.Reject( 400, "Please update MysqlOO to a version >= 9.3: http://bit.ly/MysqlOO")
            end
    
            return migrateInventoryIdMySql( DB )
        else
            return migrateInventoryIdSQLite( DB )
        end
    end)
end )
:Then( function() end, function( errid, err )
    KLogf( 2, "[ERROR] Error during update: %i, %s.", errid, err )
    return Promise.Reject( errid, err )
end )