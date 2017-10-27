local function fixPts(ply, cmd, args)
    if IsValid(ply) then
        ply:ChatPrint("Please run this command via rcon/server console")
        return
    end

    if not Pointshop2 or not Pointshop2.DB or not Pointshop2.DB.ConnectionPromise then
        MsgC(Color(255, 0, 0), "ERROR: Pointshop2 is not loaded yet. Please rerun.")
        return
    end

    print("[FIXPTS] -> Fetching minimum values")
    Pointshop2.DB.ConnectionPromise:Then(function()
        print('[FIXPTS] -> Connected to database')
        return Pointshop2.DB.DoQuery('SELECT MIN(points) as minPoints, MIN(premiumPoints) as minPrem FROM ps2_wallet;')
    end, function(e)
        MsgC(Color(255, 0, 0), "ERROR: The database connection failed. Please check your setup")
        return Promise.reject('Connection Failed')
    end ):Then(function(res)
        local minPts = res[1]

        local minPoints = math.min(minPts.minPoints, 0)
        local minPremPoints = math.min(minPts.minPrem, 0)

        print('[FIXPTS] -> Determined minimum points ', minPoints, ' premium: ', minPremPoints)
        
        local defaultPoints = Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.DefaultWallet.Points" )
        local defaultPremiumPoints = Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.DefaultWallet.PremiumPoints" )

        print('[FIXPTS] -> Determined default wallet ', defaultPoints, ' premium: ', defaultPremiumPoints)
        
        if minPoints == 0 and minPremPoints == 0 then
            print('[FIXPTS] -> Nobody has negative points, you probably aren\'t affected or this script already ran.')
            return
        end

        local correctionPoints = -minPoints + defaultPoints
        local correctionPremPoints = -minPremPoints + defaultPremiumPoints
        print('[FIXPTS] -> To correct points balances we will give everyone ', correctionPoints, ' points and ', correctionPremPoints, ' premium points.')
        return Pointshop2.DB.DoQuery(Format('UPDATE ps2_wallet SET points = points + %i, premiumPoints = premiumPoints + %i', correctionPoints, correctionPremPoints))
    end):Then(function() end)
end
concommand.Add("ps2_fixpoints", fixPts)

local function setPointsGlobal(ply, cmd, args)
    if IsValid(ply) then
        ply:ChatPrint("Please run this command via rcon/server console")
        return
    end

    if not Pointshop2 or not Pointshop2.DB or not Pointshop2.DB.ConnectionPromise then
        MsgC(Color(255, 0, 0), "ERROR: Pointshop2 is not loaded yet. Please rerun.")
        return
    end

    local currencyType, amount = args[1], args[2]
    
    if not currencyType then
        MsgC(Color(255, 0, 0), "ERROR: Invalid argument 1 (curencyType). Allowed: points, premiumPoints\n")
        print("Usage: ps2_setwallet_all [points|premiumPoints] [amount]")
        print("       Sets all wallets points or premiumPoints to the amount specified.")
        return
    end

    if not amount then
        MsgC(Color(255, 0, 0), "ERROR: Invalid argument 2 (amount).\n")
        print("Usage: ps2_setwallet_all [points|premiumPoints] [amount]")
        print("       Sets all wallets points or premiumPoints to the amount specified.")
        return
    end

    if not table.HasValue({"points", "premiumPoints"}, currencyType) then
        MsgC(Color(255, 0, 0), "ERROR: Invalid argument 1 (currencyType). Valid: points, premiumPoints. Given: " .. currencyType .. "\n")
        print("Usage: ps2_setwallet_all [points|premiumPoints] [amount]")
        print("       Sets all wallets points or premiumPoints to the amount specified.")
        return
    end
    
    print("[FIXPTS] -> Setting all wallet's " .. currencyType .. " to " .. amount)
    Pointshop2.DB.ConnectionPromise:Then(function()
        print('[FIXPTS] -> Connected to database')
        return Pointshop2.DB.DoQuery(Format('UPDATE ps2_wallet SET %s = %i', currencyType, amount))
    end)
end
concommand.Add("ps2_setwallet_all", setPointsGlobal)


local function updatePoints(ply, cmd, args)
    if IsValid(ply) then
        ply:ChatPrint("Please run this command via rcon/server console")
        return
    end
    
    if not Pointshop2 or not Pointshop2.DB or not Pointshop2.DB.ConnectionPromise then
        MsgC(Color(255, 0, 0), "ERROR: Pointshop2 is not loaded yet. Please rerun.")
        return
    end

    local currencyType, amount = args[1], args[2]
    if not currencyType or not table.HasValue({"points", "premiumPoints"}, currencyType) then
        currencyType = tostring(currencyType)
        MsgC(Color(255, 0, 0), "ERROR: Invalid argument 1 (currencyType). Valid: points, premiumPoints. Given: " .. currencyType .. "\n")
        print("Usage: ps2_updatewallet_all [points|premiumPoints] [amount]")
        print("       Adds the specified amount of points/premiumPoints to all player's wallets. Negative numbers take points away.")
        return
    end

    if not amount then
        MsgC(Color(255, 0, 0), "ERROR: Invalid argument 2 (amount).")
        print("Usage: ps2_updatewallet_all [points|premiumPoints] [amount]")
        print("       Adds the specified amount of points/premiumPoints to all player's wallets. Negative numbers take points away.")
        return
    end

    print("[FIXPTS] -> Adding " .. amount .. " " .. currencyType .. " to all wallets" )
    Pointshop2.DB.ConnectionPromise:Then(function()
        print('[FIXPTS] -> Connected to database')
        return Pointshop2.DB.DoQuery(Format('UPDATE ps2_wallet SET %s = %s + %i', currencyType, currencyType, amount))
    end)
end
concommand.Add("ps2_updatewallet_all", updatePoints)
