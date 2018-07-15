-- Fix for a concurrency bug
local DB = LibK.getDatabaseConnection( LibK.SQL, "Update" )

return DB.ConnectionPromise:Then( function( )
    return DB.TableExists('ps2_wallet')
end )
:Then( function( shouldUpdate )
    KLogf( 2, "[INFO] We are on %s and %s to update", DB.CONNECTED_TO_MYSQL and "MySQL" or "SQLite", shouldUpdate and "need" or "don't need" )
    if not shouldUpdate then
        return
    end

    return Promise.Resolve():Then(function()
        if DB.CONNECTED_TO_MYSQL then
            return DB.DoQuery("UPDATE ps2_wallet SET points = GREATEST(points, 0), premiumPoints = GREATEST(premiumPoints, 0)")
        else
            return DB.DoQuery("UPDATE ps2_wallet SET points = MAX(points, 0), premiumPoints = MAX(premiumPoints, 0)")
        end
    end):Then(function()
        -- Since SQLite is single threaded this bug only happens in mysql
        if DB.CONNECTED_TO_MYSQL then
            return DB.DoQuery([[
                ALTER TABLE ps2_wallet MODIFY COLUMN points INT(11) UNSIGNED NOT NULL AFTER ownerId;
                ALTER TABLE ps2_wallet MODIFY COLUMN premiumPoints INT(11) UNSIGNED NOT NULL AFTER ownerId;
            ]])
        end
    end)
end )
:Fail( function( errid, err )
    KLogf( 2, "[ERROR] Error during update: %i, %s.", errid, err )
    return Promise.Reject( errid, err )
end )

