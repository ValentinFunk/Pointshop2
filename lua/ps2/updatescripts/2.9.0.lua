local DB = LibK.getDatabaseConnection( LibK.SQL, "Update" )

local function forceValidUuids()
	return DB.DoQuery('SELECT id FROM ps2_itempersistence WHERE uuid IS NULL')
	:Then(function(rows)
		if not rows then 
			return 
		end

		local query = "UPDATE ps2_itempersistence SET uuid = CASE id "
		local ids = LibK._.pluck(rows, 'id')
		local parts = {}
		for _, id in pairs( ids ) do
			table.insert( parts, Format( 'WHEN "%i" THEN "%s"', id, LibK.GetUUID() ) )
		end
		query = query .. table.concat( parts, " " )
		query = query .. ' ELSE uuid END WHERE id IN (' .. table.concat( ids, ', ' ) .. ')'
		return DB.DoQuery(query)
	end)
end

local function addUuidField( )
	return DB.FieldExistsInTable( "ps2_itempersistence", "uuid" )
	:Then( function( exists )
		if not exists then
			return DB.DoQuery( "ALTER TABLE `ps2_itempersistence` ADD `uuid` VARCHAR(255) NOT NULL DEFAULT \"NOTSET\"" )
            :Then(function()
                return DB.DoQuery( "SELECT id FROM `ps2_itempersistence`" )
            end)
            :Then(function(rows)
				if not rows then 
					return 
				end

                local query = "UPDATE ps2_itempersistence SET uuid = CASE id "
                local ids = LibK._.pluck(rows, 'id')
                local parts = {}
                for _, id in pairs( ids ) do
                    table.insert( parts, Format( 'WHEN "%i" THEN "%s"', id, LibK.GetUUID() ) )
                end
                query = query .. table.concat( parts, " " )
                query = query .. ' ELSE uuid END WHERE id IN (' .. table.concat( ids, ', ' ) .. ')'
				return DB.DoQuery(query)
            end)
		end
	end )
	:Then( function( )
		print( "\t Added column uuid to ps2_itempersistence" )
	end )
end

return DB.ConnectionPromise
:Then( function( )
	return DB.TableExists('ps2_itempersistence')
end )
:Then( function( shouldUpdate )
	KLogf( 2, "[INFO] We are on %s and %s to update", DB.CONNECTED_TO_MYSQL and "MySQL" or "SQLite", shouldUpdate and "need" or "not need" )
	if shouldUpdate then
		return addUuidField()
		:Then(function() 
			return forceValidUuids()
		end)
	end
end )
:Then( function() end, function( errid, err )
    KLogf( 2, "[ERROR] Error during update: %i, %s.", errid, err )
    return Promise.Reject( errid, err )
end )