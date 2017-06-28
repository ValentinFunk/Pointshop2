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
        return DB.DoQuery([[
            UPDATE kinv_items SET itempersistence_id = IF(CAST(SUBSTRING(itemclass, 18) AS SIGNED) = 0, NULL, CAST(SUBSTRING(itemclass, 18) AS SIGNED))
            WHERE itemclass REGEXP "^KInventory\\.Items\\.[0-9]+$"
        ]])
    end
end )
:Then( function() end, function( errid, err )
    KLogf( 2, "[ERROR] Error during update: %i, %s.", errid, err )
    return Promise.Reject( errid, err )
end )