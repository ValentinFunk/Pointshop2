local DB = LibK.getDatabaseConnection( LibK.SQL, "Update" )

local function generateUpdateQuery(dataObjects) 
    local query = "UPDATE kinv_items SET data = CASE id "
	local affectedIds = {}
	local parts = {}
	for id, json in pairs( dataObjects ) do
        table.insert( affectedIds, tonumber( id ) )
		table.insert( parts, Format( 'WHEN "%i" THEN %s', id, DB.SQLStr(json) ) )
	end
	query = query .. table.concat( parts, " " )
	query = query .. ' ELSE data END WHERE id IN (' .. table.concat( affectedIds, ', ' ) .. ')'
    return query
end

--[[
    There was a bug in previous versions where Inventory and ItemPersistence would be serialized
    because saveFields was not set. This is quite bad for performance as items become pretty big.
    This fixes it.
]]
return DB.ConnectionPromise:Then( function( )
    return DB.TableExists('kinv_items')
end )
:Then( function( shouldUpdate )
    KLogf( 2, "[INFO] We are on %s and %s to update", DB.CONNECTED_TO_MYSQL and "MySQL" or "SQLite", shouldUpdate and "need" or "don't need" )
    if not shouldUpdate then
        return
    end

    return DB.DoQuery("SELECT id, data FROM kinv_items")
        :Then( function(data)
            if not data or #data == 0 then
                return
            end
            
            -- Update data in chunks of 50 items
            local splitted = LibK.splitTable( data, 50 )
            local promises = { }
            for k, chunk in pairs(splitted) do
                local dataObjects = {}
                for _, item in pairs(chunk) do
                    local decoded = util.JSONToTable(item.data) or {}
                    if decoded['ItemPersistence'] or decoded['Inventory'] then
                        decoded['ItemPersistence'] = nil
                        decoded['Inventory'] = nil
                        dataObjects[item.id] = util.TableToJSON(decoded)
                    end
                end
                
                if table.Count(dataObjects) > 0 then
                    local query = generateUpdateQuery(dataObjects)
                    table.insert(promises, DB.DoQuery(query))
                end
            end

            return WhenAllFinished(promises, { noUnpack = true })
        end )
end )
:Then( function() end, function( errid, err )
    KLogf( 2, "[ERROR] Error during update: %i, %s.", errid, err )
    return Promise.Reject( errid, err )
end )