Pointshop2.StoredSetting = class( "Pointshop2.StoredSetting" )
local StoredSetting = Pointshop2.StoredSetting 

StoredSetting.static.DB = "Pointshop2"

StoredSetting.static.model = {
	tableName = "ps2_settings",
	fields = {
		plugin = "string",
		path = "string",
		value = "json",
		serverId = "optKey"
	}
}

StoredSetting:include( DatabaseModel )