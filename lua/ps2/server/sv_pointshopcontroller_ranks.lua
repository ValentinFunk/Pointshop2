-- Update the base ps2_itempsersistences table ranks and reload the item class.
function Pointshop2Controller:updateRankRestrictions( ply, itemClassNames, ranks )
  local saveTbl = {}
	for k, v in pairs( itemClassNames ) do
		saveTbl[k]= tonumber(v)
	end
	local saveStr = table.concat( saveTbl, "," )

	local dbEntries = Pointshop2.ItemPersistence.getDbEntries( "WHERE id IN (" .. saveStr .. ")" )
	:Then( function( itemPersistences )
		return Promise.Map( itemPersistences, function( persistence )
			-- Update the ranks
			persistence.ranks = ranks
			return persistence:save ()
		end )
	end )
	:Then( function( persistences )
		PrintTable(persistences)
		local persistenceIds = LibK._.map( persistences, function( p ) return tostring( p.id ) end )
		self:notifyItemsChanged( persistenceIds )
	end )
end
