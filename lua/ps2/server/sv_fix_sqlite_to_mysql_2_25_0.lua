-- This updatescript fixes an issue with the SQLite -> MySQL converter.
-- In some cases MySQL created MyISAM tables instead of InnoDB so that the
-- relationships did not work. This detects if that issue happened and 
-- fixes it by changing all tables to InnoDB, then adding the FK constraints

local function generateConstraintsQuery( class )
    local model = class.model

    print("generate for", class.model.tableName)
    local queries = {}
    for name, info in pairs( model.belongsTo or {} ) do
        local onDelete = "RESTRICT"
        if info.onDelete then
            onDelete = info.onDelete
        elseif model.fields[info.foreignKey] == "optKey" then
            onDelete = "SET NULL"
        end

        local onUpdate = "RESTRICT"
        if info.onUpdate then
            onUpdate = info.onUpdate
        elseif model.fields[info.foreignKey] == "optKey" then
            onUpdate = "SET NULL"
        end

        local foreignClass = getClass( info.class )
        if not foreignClass then
            error( "Invalid class " .. info.class .. " for model " .. class.name .. ", constraint " .. name )
        end

        table.insert( queries, Format( "ALTER TABLE `%s` ADD CONSTRAINT `%s` FOREIGN KEY (`%s`) REFERENCES `%s` (`%s`) ON DELETE %s ON UPDATE %s",
            model.tableName,
            "FK_" .. util.CRC( class.name .. "_" .. name .. "_" .. info.class ),
            info.foreignKey,
            foreignClass.model.tableName,
            foreignClass.model.overrideKey or "id",
            onDelete,
            onUpdate
        ) )
    end

    if #queries == 0 then
        return
    else
        return table.concat( queries, ";" )
    end
end

local function getPs2Models()
    local ps2Models = { }
	for name, class in pairs( Pointshop2 ) do
		if type( class ) != "table" or not class.name then
			continue
		end

		if not class.initializeTable then
			continue
		end

		table.insert( ps2Models, class )
    end
    for name, class in pairs( LibK ) do
		if type( class ) != "table" or not class.name then
			continue
		end

		if not class.initializeTable then
			continue
		end

		table.insert( ps2Models, class )
    end

    return ps2Models
end

function FixSqliteError_2_25_0( ) 
    local DB

    return Pointshop2.DatabaseConnectedPromise:Then( function( )
        DB = Pointshop2.DB

        if not DB.CONNECTED_TO_MYSQL then
            KLogf(4, "Don't need to fix constraints, database is SQLite")
            return Promise.Reject('No need to fix - on SQLite')
        end
    
        return DB.DoQuery(Format([[
            SELECT * FROM information_schema.TABLE_CONSTRAINTS 
            WHERE information_schema.TABLE_CONSTRAINTS.CONSTRAINT_TYPE = 'FOREIGN KEY'
            AND `TABLE_SCHEMA` = %s
            AND CONSTRAINT_NAME= 'FK_789478012'
        ]], DB.SQLStr( LibK.SQL.Database )))
    end ):Then(function( result )
        if result and result[1] and result[1].CONSTRAINT_NAME then
            return Promise.Reject('No need to fix - constraint exists')
        end

        return DB.TableExists( 'kinv_items' )
    end ):Then( function( hasTable )
        if not hasTable then 
            return Promise.Reject('No need to fix - no database yet')
        end

        MsgC( Color( 255, 0, 0 ), "[Pointshop2 - 2.25.0 Update] There is an issue with your database. Fixing it and changing map!\n" )
        local persistenceModels = Promise.Filter( getPs2Models( ), function( class )
            return class.model.belongsTo and class.model.belongsTo.ItemPersistence and DB.TableExists( class.model.tableName )
        end )
        return persistenceModels
    end ):Map( function( class )
        return Pointshop2.DB.DoQuery( Format( [[
            SELECT childPersistence.id FROM %s AS childPersistence
            LEFT JOIN ps2_itempersistence as parentPersistence ON childPersistence.%s = parentPersistence.id
            WHERE parentPersistence.id IS NULL
        ]], class.model.tableName, class.model.belongsTo.ItemPersistence.foreignKey ) ):Then( function( ids )
            if not ids or #ids == 0 then
                return
            end

            ids = LibK._.pluck( ids, 'id' );
            return Pointshop2.DB.DoQuery( Format( [[ DELETE FROM %s WHERE id IN (%s) ]], class.model.tableName, table.concat( ids, ',' ) ) )
        end )
    end ):Then( function() 
        return Pointshop2.DB.DoQuery( [[ DELETE s FROM `ps2_equipmentslot` s JOIN (SELECT s2.id FROM ps2_equipmentslot s2 LEFT JOIN kinv_items i ON i.id = s2.itemId WHERE i.id IS NULL) toDelete ON s.id = toDelete.id; ]] )
    end ):Then( function( )
        local modelsWithTable = Promise.Filter( getPs2Models( ), function( class )
            return DB.TableExists( class.model.tableName )
        end )

        -- Convert all tables to InnoDB then create constraints
        return modelsWithTable:Map(function( class ) 
            return Pointshop2.DB.DoQuery( Format( 'ALTER TABLE %s ENGINE=InnoDB;', class.model.tableName ) )
        end ):Then(function()
            return modelsWithTable:Map( function( class ) 
                local query = generateConstraintsQuery( class )
                return query and Pointshop2.DB.DoQuery( query )
            end )
        end)
    end ):Then( function( )
        MsgC( Color( 255, 0, 0 ), "[Pointshop2 - 2.25.0 Update] Patched the SQLite -> MySQL error! Update to 2.25.0 done, reloading map\n" )
        RunConsoleCommand( "changelevel", game.GetMap() )
    end, function( err )
        if string.find( err, 'No need to fix' ) then
            KLogf( 4, "[Pointshop2 - 2.25.0 Update] Don't need to fix: %s", err )
            return Promise.Resolve( )
        end

        return Promise.Reject( err )
    end )
end
FixSqliteError_2_25_0()