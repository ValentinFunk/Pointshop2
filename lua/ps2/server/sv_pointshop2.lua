-- UNCOMMENT TO USE FastDL
--LibK.addContentFolder( "materials/pointshop2" )
--LibK.addContentFolder( "materials/trails" )
resource.AddWorkshop( "439856500" )

CreateConVar("pointshop2_salt", "{{ user_id | 69 }}", {FCVAR_NOTIFY})

function Pointshop2.ResetDatabase( )
	local models = {}
	local function add( tbl )
		for k, v in pairs( tbl ) do
			if istable( v ) and v.dropTable then
				table.insert( models, v )
			end
		end
	end
	add( Pointshop2 )
	add( KInventory )

	LibK.SetBlocking( true )
	Pointshop2.DB.DisableForeignKeyChecks( true )
	local promises = {}
	for k, v in pairs( models ) do
		local promise = v.dropTable( )
		:Done( function( )
			KLogf( 5, "Dropped table %s", v.name )
		end )
		table.insert( promises, promise )
	end

	LibK.ResetTableCache( )

	for k, v in pairs( models ) do
		local promise = v:initializeTable( )
		:Done( function( )
			KLogf( 5, "Reset Table %s", v.name )
		end )
		table.insert( promises, promise )
	end
	Pointshop2.DB.DisableForeignKeyChecks( false )
	LibK.SetBlocking( false )

	return WhenAllFinished( promises )
end

--[[
	This function tries to find and fix database errors.
	Only use it in extreme cases and ALWAYS do a backup!
	The function doesn't consider Lua defined items and detects them as DB errors, be very careful with that!
]]--
function Pointshop2.FixDatabase( )
	Promise.Resolve( )
	-- 1: Remove itemPersistences without a valid parent base persistence
	:Then( function()
		return FixSqliteError_2_25_0( true )
	end )

	-- 1.1: Find all hats with broken settings
	:Then( function( )
		return Pointshop2.HatPersistence.getAll( 0 )
	end )
	:Then( function( persistentItems )
		local promises = {}
		for k, item in pairs( persistentItems ) do
			if not item.iconInfo.inv or not item.iconInfo.shop then
				KLogf( 2, "[PS2-FIX] Found hat persistence with invalid icon properties, id %i", item.id )
				table.insert( promises, Pointshop2.ItemPersistence.removeWhere{ id = item.ItemPersistence.id } )
			end
		end
		return WhenAllFinished( promises, { noUnpack = true } )
	end )

	-- 2: Find all items that don't have a valid class (base persistence)
	:Then( function( )
		return Promise.Resolve()
			:Then(function()
				return Pointshop2.DB.DisableForeignKeyChecks( true )
			end)
			:Then(function()
				-- Fix: make sure that itempersistence_id field matches the classname filed
				if Pointshop2.DB.CONNECTED_TO_MYSQL then
					return Pointshop2.DB.DoQuery([[
						UPDATE kinv_items SET itempersistence_id = IF(CAST(SUBSTRING(itemclass, 18) AS SIGNED) = 0, NULL, CAST(SUBSTRING(itemclass, 18) AS SIGNED))
						WHERE itemclass REGEXP "^KInventory\\.Items\\.[0-9]+$"
					]])
				else	
					return Pointshop2.DB.DoQuery([[ 
						UPDATE kinv_items SET itempersistence_id = CASE WHEN CAST(substr(itemclass, 18) AS NUMERIC) = 0 THEN NULL ELSE CAST(substr(itemclass, 18) AS NUMERIC) END
					]])
				end
			end)
			:Then( function( )
				-- Now remove items with invalid persistences
				if Pointshop2.DB.CONNECTED_TO_MYSQL then
					return Pointshop2.DB.DoQuery([[
						DELETE FROM kinv_items WHERE id IN (
							SELECT items.id
							FROM (SELECT * FROM kinv_items) items 
							LEFT JOIN ps2_itempersistence persistences ON persistences.id = CAST(SUBSTRING(items.itemclass, 18) AS SIGNED)
							WHERE items.itemclass REGEXP "^KInventory\\.Items\\.[0-9]+$" AND persistences.id IS NULL
						)
					]])
				else
					return Pointshop2.DB.DoQuery([[
						DELETE FROM kinv_items WHERE id IN (
							SELECT items.id
							FROM (SELECT * FROM kinv_items) items 
							LEFT JOIN ps2_itempersistence persistences ON persistences.id = CAST(substr(items.itemclass, 18) AS NUMERIC)
							WHERE CAST(substr(items.itemclass, 18) AS NUMERIC) != 0 AND persistences.id IS NULL
						)
					]])
				end
				return Pointshop2.DB.DisableForeignKeyChecks( false )
			end )
	end )
	
	:Then( function()
		-- Remove slots that have no valid item attached
		return Pointshop2.DB.DoQuery( [[ DELETE s FROM `ps2_equipmentslot` s JOIN (SELECT s2.id FROM ps2_equipmentslot s2 LEFT JOIN kinv_items i ON i.id = s2.itemId WHERE i.id IS NULL) toDelete ON s.id = toDelete.id; ]] )
	end )

	:Then( function() 
		-- Remove items from inventories that are lua defined, but the lua defined item doesn't exist
		return Pointshop2.DB.DoQuery(Format(
			"SELECT id, itemclass FROM kinv_items WHERE CAST(substr(itemclass, 18) AS %s) = 0",
			Pointshop2.DB.CONNECTED_TO_MYSQL and "SIGNED" or "NUMERIC"
		)):Then(function(results)
			if not results or #results == 0 then 
				return
			end

			local brokenOnes = LibK._.filter( results, function( row )
				return _G[itemclass] != nil				
			end )
			return Promise.Map( brokenOnes, function( row )
				return Pointshop2.DB.DoQuery( "DELETE FROM kinv_items WHERE id = " .. brokenOnes.id ) 
			end )
		end)
	end ):Then( function( )
		return Pointshop2Controller:getInstance():loadModuleItems()
	end )
		-- 	return KInventory.Item.getAll( 0 ) --Don't resolve relationships
		-- end )
		-- :Then( function( items )
		-- 	local promises = {}
		-- 	for k, v in pairs( items ) do
		-- 		if v._creationFailed then
		-- 			PrintTable( v )
		-- 			KLogf( 2, "[PS2-FIX] Found invalid item reference in inventory, removing item %i, class %s", v.id, v._className )
		-- 			table.insert( promises, v:remove( ) )
		-- 		end
		-- 	end
		-- 	return WhenAllFinished( promises, { noUnpack = true } )

	-- 3: Find all item mappings that don't have a valid class (base persistence)
	:Then( function( )
		return Pointshop2.ItemMapping.getAll( 0 )
	end )
	:Then( function( itemMappings )
		return Promise.Map( itemMappings, function( itemMapping ) 
			return Pointshop2.ItemPersistence.findById( itemMapping.itemClass )
				:Then( function( persistence )
					local isLuaDefined = KInventory.Items[itemMapping.itemClass] and KInventory.Items[itemMapping.itemClass].originFilePath != "Pointshop2_Generated"
					if not persistence and not isLuaDefined then
						KLogf( 2, "[PS2-FIX] Found invalid reference in mapping, class was %s", itemMapping.itemClass )
						return itemMapping:remove( )
					end
					return Promise.Resolve()
				end )
		end )
	end )

	-- 4: Remove settings wrongfully in the DB
	:Then( function( )
		return WhenAllFinished{
			Pointshop2.StoredSetting.removeWhere{ plugin = "Pointshop 2", path = "InternalSettings.Servers" },
			Pointshop2.StoredSetting.removeWhere{ plugin = "Pointshop 2", path = "InternalSettings.ServerId" }
		}
	end )

	-- 5: Remove Inventory assocs wrongfully in the DB
	:Then( function()
		return KInventory.Item.getAll( 0 )
	end )
	:Then( function(items)
		return Promise.Map(items, function( item )
			if item.Inventory then
				item.Inventory = nil
				return item:save( )
			end
		end )
	end )

	-- 6: Fix wrong persistence for instaswitch Weapons
	:Then( function()
		return Pointshop2.DB.DoQuery([[INSERT INTO ps2_instatswitchweaponpersistence (weaponClass, loadoutType, itemPersistenceId)
		    SELECT WP.weaponClass AS weaponClass, WP.loadoutType AS loadoutType, WP.itemPersistenceId AS itemPersistenceId
		    FROM `ps2_itempersistence` IP, ps2_weaponpersistence WP
		    WHERE IP.baseClass="base_weapon_instaswitch" AND WP.itemPersistenceId = IP.id]])
	end )
	:Then( function( )
		if Pointshop2.DB.CONNECTED_TO_MYSQL then
			return Pointshop2.DB.DoQuery([[DELETE w FROM ps2_weaponpersistence w
				INNER JOIN `ps2_itempersistence`
					ON ps2_itempersistence.id = w.itemPersistenceId
				WHERE ps2_itempersistence.baseClass="base_weapon_instaswitch"]])
		else
			return Pointshop2.DB.DoQuery('SELECT w.id FROM ps2_weaponpersistence w INNER JOIN ps2_itempersistence ON ps2_itempersistence.id = w.itemPersistenceId WHERE ps2_itempersistence.baseClass="base_weapon_instaswitch"')
			:Then(function(ids)
				if ids and #ids then
					return Pointshop2.DB.DoQuery('DELETE FROM ps2_weaponpersistence WHERE id IN (' .. table.concat(LibK._.pluck(ids, 'id'), ",") .. ')')
				end
			end)
		end
	end )

	-- 7: Remove slots in DB that have no lua counterpart
	:Then( function()
		local validSlotNames = LibK._(Pointshop2.EquipmentSlotLookup):chain()
			:keys()
			:map(function(key) return Pointshop2.DB.SQLStr(key) end)
			:join(',')
			:value()

		if #validSlotNames == 0 then
			-- Shouldn't happen but someone might do this?
			return
		end

		KLogf( 2, "Removing invalid slots. Valid slot names: " .. validSlotNames)
		return Pointshop2.EquipmentSlot.getDbEntries(Format("WHERE slotName NOT IN (%s)", validSlotNames), 0)
			:Then(function(invalidSlots)
				local itemsToRemove = LibK._(invalidSlots):chain()
					:filter(function(slot) return slot.itemId end)
					:map(function(slot) return slot.itemId end)
					:join(',')
					:value()
				
				
				KLogf( 2, "Removing items from invalid slots " .. itemsToRemove)
				return WhenAllFinished{
					( #itemsToRemove > 0 ) and Pointshop2.DB.DoQuery(Format([[
						UPDATE kinv_items a, ps2_equipmentslot b
							JOIN inventories c ON b.ownerId =  c.ownerId
							SET a.inventory_id = c.id, b.itemId = NULL
							WHERE b.slotName NOT IN (%s) AND b.itemId = a.id
					]], validSlotNames)) or Promise.Resolve(),
					Pointshop2.EquipmentSlot.removeDbEntries(Format("WHERE slotName NOT IN (%s)", validSlotNames))
				}
			end)
	end )

	:Done( function( )
		RunConsoleCommand( "changelevel", game.GetMap( ) )
	end )
end

function Pointshop2.PlayerOwnsItem( ply, item )
	for k, v in pairs( ply.PS2_Inventory:getItems( ) ) do
		if v.id == item.id then
			return true
		end
	end

	for k, v in pairs( ply.PS2_Slots ) do
		if v.itemId == item.id then
			return true
		end
	end

	return false
end

function Pointshop2.BroadcastInfo( text )
	for k, v in pairs( player.GetAll( ) ) do
		v:PS2_DisplayInformation( text )
	end
end

function Pointshop2.LogCacheEvent( action, source, itemId, other )
	if LibK.Debug then
		file.Append('CacheLog.txt', util.TableToJSON({ action = action, source = source, itemId = itemId, other = other}) .. '\n')
	end
end
