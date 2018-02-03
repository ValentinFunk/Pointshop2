hook.Add("PS2_GetPreviewModel", "ForMurder", function() 
    if GAMEMODE.Spectating then 
        return {
            model = player_manager.TranslatePlayerModel("male03"),
            bodygroups = "0",
            skin = 0
        }
    end 
end)