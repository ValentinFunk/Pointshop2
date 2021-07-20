sam.permissions.add("pointshop2 manageitems", "Pointshop 2", "superadmin")
sam.permissions.add("pointshop2 createitems", "Pointshop 2", "superadmin")
sam.permissions.add("pointshop2 manageusers", "Pointshop 2", "superadmin")
sam.permissions.add("pointshop2 managemodules", "Pointshop 2", "superadmin")
sam.permissions.add("pointshop2 exportimport", "Pointshop 2", "superadmin")
sam.permissions.add("pointshop2 manageservers", "Pointshop 2", "superadmin")
sam.permissions.add("pointshop2 reset", "Pointshop 2", "superadmin")
sam.permissions.add("pointshop2 usepac", "Pointshop 2", "superadmin")

sam.command.set_category("Pointshop 2") -- any new command will be in that category unless the command uses :SetCategory function
 
sam.command.new("ps2_addpoints_steamid")
    :SetPermission("pointshop2 addpoints_steamid")
 
	--Help message for when using in the menu of SAM
    :Help("Give Pointshop 2 points to a player by SteamID")
 
    --Only allowing SteamID's as PS2 only uses SteamID32
	:AddArg("steamid", {allow_higher_target = true})
 
    --Adding a textbox to determine what points you are giving and checking to see its the correct points
	:AddArg("text", {
        -- I have no idea if completion system exists in SAM, so I am leaving it as hint
        hint = "Currency Type (points/premiumPoints)",
        default = "points",
        check = function(input, ply)
            return input == "points" or input == "premiumPoints"
        end, -- this gets called to see if the input of this argument is valid
    })
 
    --Adding input for amount of points you want to give
	:AddArg("number", {
        hint = "Amount",
        min = 1,
        round = true
    })
 
    :OnExecute(function(calling_ply, steamId, currencyType, amount)
 
        Pointshop2Controller:getInstance( ):addPointsBySteamId( steamId, currencyType, amount )
        :Fail( function( errid, err )
            KLogf( 2, "[Pointshop 2] ERROR: Couldn't give %i %s to %s, %i - %s", amount, currencyType, steamId, errid, err )
        end )
        :Done( function( )
            KLogf( 4, "[Pointshop 2] %s gave %i %s to %s", "CONSOLE", amount, currencyType, steamId )

            sam.player.send_message(calling_ply, "{A} gave {V} {S} to {T}", {
                A = calling_ply, V = amount, S = currencyType, T = steamId
            })
        end )
    end)
:End()

sam.command.new("ps2_addpoints")
    :SetPermission("pointshop2 addpoints")
 
	--Help message for when using in the menu of SAM
    :Help("Give Pointshop 2 points to a player")

	:AddArg("player", {allow_higher_target = true})
 
    --Adding a textbox to determine what points you are giving and checking to see its the correct points
	:AddArg("text", {
        -- I have no idea if completion system exists in SAM, so I am leaving it as hint
        hint = "Currency Type (points/premiumPoints)",
        default = "points",
        check = function(input, ply)
            return input == "points" or input == "premiumPoints"
        end, -- this gets called to see if the input of this argument is valid
    })
 
    --Adding input for amount of points you want to give
	:AddArg("number", {
        hint = "Amount",
        min = 1,
        round = true
    })
 
    :OnExecute(function(calling_ply, targets, currencyType, amount)

        -- I guess there is better way to do this? Maybe prepare big db query? To-do.
        for i = 1, #targets do
            local steamId = targets[i]:SteamID()
            Pointshop2Controller:getInstance( ):addPointsBySteamId( steamId, currencyType, amount )
            :Fail( function( errid, err )
                KLogf( 2, "[Pointshop 2] ERROR: Couldn't give %i %s to %s, %i - %s", amount, currencyType, steamId, errid, err )
            end )
            :Done( function( )     
                KLogf( 4, "[Pointshop 2] %s gave %i %s to %s", "CONSOLE", amount, currencyType, steamId )
                if targets[i] ~= calling_ply then
                    sam.player.send_message(targets[i], "{A} gave {T} {V} {S}", {
                        A = calling_ply, V = amount, S = currencyType, T = targets
                    })
                end
            end )
            
        end
        sam.player.send_message(calling_ply, "{A} gave {V} {S} to {T}", {
            A = calling_ply, V = amount, S = currencyType, T = targets
        })
    end)
:End()