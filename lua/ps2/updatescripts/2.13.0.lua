local function addInventoryIdFK( DB )
	return DB.DoQuery([[
        ALTER TABLE `kinv_items` ADD `itempersistence_id` INT(11)
    ]])
end

local function addInventoryIdConstraint( DB )
    local fkName = "FK_" .. util.CRC( "KInventory.Item_ItemPersistence_Pointshop2.ItemPersistence" )
    local query = Format( [[
        ALTER TABLE `kinv_items` ADD
            CONSTRAINT `%s` 
                FOREIGN KEY (`itempersistence_id`) 
                REFERENCES `ps2_itempersistence` (`id`) 
                ON DELETE CASCADE 
                ON UPDATE SET NULL
    ]], fkName )
    return DB.DoQuery(query)
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

    return addInventoryIdFK(DB)
    :Then(function()
        return addInventoryIdConstraint(DB)
    end)
end )
:Then( function() end, function( errid, err )
    KLogf( 2, "[ERROR] Error during update: %i, %s.", errid, err )
    return Promise.Reject( errid, err )
end )