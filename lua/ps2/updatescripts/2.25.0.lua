local DB = LibK.getDatabaseConnection( LibK.SQL, "Update" )

local function performUpdate()
    -- Fix: make sure that itempersistence_id field matches the classname filed
    if DB.CONNECTED_TO_MYSQL then
        return DB.DoQuery([[
            UPDATE kinv_items SET itempersistence_id = IF(CAST(SUBSTRING(itemclass, 18) AS SIGNED) = 0, NULL, CAST(SUBSTRING(itemclass, 18) AS SIGNED))
            WHERE itemclass REGEXP "^KInventory\\.Items\\.[0-9]+$"
        ]])
    else
        return DB.DoQuery([[
            UPDATE kinv_items SET itempersistence_id = CASE WHEN CAST(substr(itemclass, 18) AS NUMERIC) = 0 THEN NULL ELSE CAST(substr(itemclass, 18) AS NUMERIC) END
        ]])
    end
end

return DB.ConnectionPromise:Then( function( )
    return DB.TableExists('kinv_items')
end )
:Then( function( shouldUpdate )
    KLogf( 2, "[INFO] We are on %s and %s to update", DB.CONNECTED_TO_MYSQL and "MySQL" or "SQLite", shouldUpdate and "need" or "don't need" )
    if not shouldUpdate then
        return
    end

    return DB.DisableForeignKeyChecks( true ):Then( function()
        return performUpdate()
    end )
end )
:Then( function()
    return DB.DisableForeignKeyChecks( false )
end, function( errid, err )
    KLogf( 2, "[ERROR] Error during update: %i, %s.", errid, err )
    return Promise.Reject( errid, err )
end )

