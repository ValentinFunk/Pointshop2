LibK.InitializeAddon{
    addonName = "KInventory",             --Name of the addon
    author = "Kamshak",                   --Name of the author
    luaroot = "kinv",                     --Folder that contains the client/shared/server structure relative to the lua folder,
	loadAfterGamemode = false,
}

LibK.addReloadFile( "autorun/ps2_kinv_init.lua" )