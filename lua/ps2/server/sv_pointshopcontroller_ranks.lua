function Pointshop2Controller:updateRankRestrictions( ply, itemClassNames, ranks )
  local saveTbl = {}
	for k, v in pairs( itemClassNames ) do
		saveTbl[k]= tonumber(v)
	end
	local saveStr = table.concat( saveTbl, "," )

	return Pointshop2.ItemPersistence.getDbEntries( "WHERE id IN (" .. saveStr .. ")" )
	:Then( function( itemPersistences )
		local promises = {}

    -- Apply changes
		for k, itemClassName in pairs( itemClassNames ) do
      -- Find persistence object from result set
			local persistence
			for _, v in pairs( itemPersistences ) do
				if tonumber( v.id ) == tonumber( itemClassName ) then
					persistence = v
				end
			end

      -- Check that user didn't pass an invalid class name
			if not persistence then
				return Promise.Reject( "Invalid Item Class " .. itemClassName )
			end

      -- Update the ranks
			persistence.ranks = ranks
			table.insert( promises, persistence:save( ) )
		end

		return WhenAllFinished( promises )
	end )
	:Then( function( )
		return self:moduleItemsChanged( )
	end )
end
