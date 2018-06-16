-- This updatescript fixes an issue with the SQLite -> MySQL converter.
-- In some cases MySQL created MyISAM tables instead of InnoDB so that the
-- relationships did not work. This detects if that issue happened and 
-- fixes it by changing all tables to InnoDB, then adding the FK constraints

local function generateConstraintsQuery( class )
    local model = class.model

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

        local constraintName = "FK_" .. util.CRC( class.name .. "_" .. name .. "_" .. info.class )
        local createQuery = Format( "ALTER TABLE `%s` ADD CONSTRAINT `%s` FOREIGN KEY (`%s`) REFERENCES `%s` (`%s`) ON DELETE %s ON UPDATE %s",
            model.tableName,
            constraintName,
            info.foreignKey,
            foreignClass.model.tableName,
            foreignClass.model.overrideKey or "id",
            onDelete,
            onUpdate
        )
    
        table.insert( queries, { 
            query = createQuery,
            name = constraintName
        } )
    end

    if #queries == 0 then
        return {}
    else
        return queries
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

function FixSqliteError_2_25_0( force ) 
    local DB

    local function hasConstraint(name)
        return DB.DoQuery(Format([[
            SELECT * FROM information_schema.TABLE_CONSTRAINTS 
            WHERE information_schema.TABLE_CONSTRAINTS.CONSTRAINT_TYPE = 'FOREIGN KEY'
            AND `TABLE_SCHEMA` = %s
            AND CONSTRAINT_NAME= '%s'
        ]], DB.SQLStr( LibK.SQL.Database ), name)):Then(function( result )
            return result and result[1] and result[1].CONSTRAINT_NAME
        end)
    end

    return Pointshop2.DatabaseConnectedPromise:Then( function( )
        DB = Pointshop2.DB

        if not DB.CONNECTED_TO_MYSQL and not force then
            KLogf(4, "Don't need to fix constraints, database is SQLite")
            return Promise.Reject('No need to fix - on SQLite')
        end
    
        return hasConstraint('FK_789478012')
    end ):Then(function( hasItemPersistenceConstraint )
        if hasItemPersistenceConstraint and not force then
           return Promise.Reject('No need to fix - constraint exists')
        end

        return DB.TableExists( 'kinv_items' )
    end ):Then( function( hasTable )
        if not hasTable then 
            return Promise.Reject('No need to fix - no database yet')
        end

        if not force then
            MsgC( Color( 255, 0, 0 ), "[Pointshop2 - 2.25.0 Update] There is an issue with your database. Fixing it and changing map!\n" )
        end
        local persistenceModels = Promise.Filter( getPs2Models( ), function( class )
            return class.model.belongsTo and class.model.belongsTo.ItemPersistence and DB.TableExists( class.model.tableName )
        end )
        return persistenceModels
    end ):Map( function( class )
        -- Delete stray child persistences (hat, booster etc)
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
        return WhenAllFinished{
            -- Delete stray items from equipment slots
            Pointshop2.DB.DoQuery( [[ DELETE s FROM `ps2_equipmentslot` s JOIN (SELECT s2.id FROM ps2_equipmentslot s2 LEFT JOIN kinv_items i ON i.id = s2.itemId WHERE i.id IS NULL) toDelete ON s.id = toDelete.id; ]] ),
            -- Delete stray outfithatpersistencemappings
            Pointshop2.DB.DoQuery( [[ DELETE s FROM `ps2_OutfitHatPersistenceMapping` s JOIN (SELECT s2.id FROM ps2_OutfitHatPersistenceMapping s2 LEFT JOIN ps2_outfits i ON i.id = s2.outfitId WHERE i.id IS NULL) toDelete ON s.id = toDelete.id; ]] ),
            Pointshop2.DB.DoQuery( [[ DELETE s FROM `ps2_OutfitHatPersistenceMapping` s JOIN (SELECT s2.id FROM ps2_OutfitHatPersistenceMapping s2 LEFT JOIN ps2_HatPersistence i ON i.id = s2.hatPersistenceId WHERE i.id IS NULL) toDelete ON s.id = toDelete.id ]] )
        }
    end ):Then( function( )
        -- This part converts to InnoDB and adds constraints. Not needed on SQLite
        if not Pointshop2.DB.CONNECTED_TO_MYSQL then
            return
        end

        local modelsWithTable = Promise.Filter( getPs2Models( ), function( class )
            return DB.TableExists( class.model.tableName )
        end )

        -- Convert all tables to InnoDB then create constraints
        return modelsWithTable:Map(function( class )
            return Pointshop2.DB.DoQuery( Format( 'ALTER TABLE %s ENGINE=InnoDB;', class.model.tableName ) )
        end ):Then(function()
            -- Create constraints info for each model
            return modelsWithTable:Map( function( class ) 
                local queries = generateConstraintsQuery( class )

                -- Only create constraints that do not exist yet
                return Promise.Filter( queries, function( queryInfo ) 
                    return hasConstraint( queryInfo.name ):Then( function( hasConstraint ) 
                        return not hasConstraint 
                    end )
                end ):Map( function( queryInfo )
                    return Pointshop2.DB.DoQuery( queryInfo.query )
                end )
            end )
        end)
    end )
end
FixSqliteError_2_25_0( ):Then( function( )
        MsgC( Color( 255, 0, 0 ), "[Pointshop2 - 2.25.0 Update] Patched the SQLite -> MySQL error! Update to 2.25.0 done, reloading map\n" )
        RunConsoleCommand( "changelevel", game.GetMap() )
end, function( err )
    if string.find( err, 'No need to fix' ) then
        KLogf( 4, "[Pointshop2 - 2.25.0 Update] Don't need to fix: %s", err )
        return Promise.Resolve( )
    end

    return Promise.Reject( err ) 
end )