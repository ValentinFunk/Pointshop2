Pointshop2.StoredOutfit = class( "Pointshop2.StoredOutfit" )
local StoredOutfit = Pointshop2.StoredOutfit 

StoredOutfit.static.DB = "Pointshop2"

StoredOutfit.static.model = {
	tableName = "ps2_outfits",
	fields = {
		outfitData = "luadata", --contains lua data encoded outfits that are decoded on the client
		updatedAt = "updatedTime"
	}
}

StoredOutfit:include( DatabaseModel )

function StoredOutfit.static.getVersionHash( )
	return DATABASES[StoredOutfit.DB].DoQuery( "SELECT MAX( updatedAt ) AS updatedAt FROM " .. StoredOutfit.model.tableName )
	:Then( function( rows )
		if rows[1].updatedAt == "NULL" then
			rows[1].updatedAt = nil
		end
		local versionHash = rows[1].updatedAt and tostring( rows[1].updatedAt ) or "-1"
		return util.CRC( versionHash )
	end )
end