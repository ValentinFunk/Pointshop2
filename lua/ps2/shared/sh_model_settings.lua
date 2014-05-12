Pointshop2.StoredSetting = class( "Pointshop2.StoredSetting" )
local StoredSetting = Pointshop2.StoredSetting 

StoredSetting.static.DB = "Pointshop2"

StoredSetting.static.model = {
	tableName = "ps2_outfits",
	fields = {
		name = "string",
		value = "luadata"
	}
}

StoredSetting:include( DatabaseModel )