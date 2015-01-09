LibK.InitializeAddon{
    addonName = "Pointshop2",             --Name of the addon
    author = "Kamshak",                   --Name of the author
    luaroot = "ps2",                      --Folder that contains the client/shared/server structure relative to the lua folder,
	loadAfterGamemode = false,
	version = "2.1.4",
	requires = { "KInventory" }	
}

LibK.addReloadFile( "autorun/pointshop2_init.lua" )
print( "Pointshop2 Version %s : %s loaded", "{{ script_id }}", "{{ user_id }}" )