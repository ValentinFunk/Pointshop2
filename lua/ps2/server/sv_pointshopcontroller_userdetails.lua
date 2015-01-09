function Pointshop2Controller:searchPlayers( ply, subject, attribute )
	local attributeTranslate = { ["Name"] = "name", ["Steam ID"] = "player", ["Profile ID"] = "steam64" }
	if not attributeTranslate[attribute] then
		local def = Deferred( )
		def:Reject( "Invalid attribute " .. attribute )
		return def:Promise( )
	end
	
	
	return LibK.Player.findPlayers( subject, attributeTranslate[attribute] )
	:Then( function( players ) 
		local ids = {}
		local playerNames = {}
		for k, v in pairs( players ) do
			table.insert( ids, tonumber( v.id ) )
			table.insert( playerNames, { id = v.id, name = v.name, lastConnected = v.updated_at } )
		end
		
		local def = Deferred( )
		
		if #ids == 0 then
			def:Resolve( {} )
			return def:Promise( )
		end
		
		Pointshop2.Wallet.getDbEntries( "WHERE ownerId IN (" .. table.concat( ids, ', ' ) .. ")" )
		:Done( function( wallets )
			for k, v in pairs( playerNames ) do
				for _, wallet in pairs( wallets ) do
					if wallet.ownerId == v.id then
						v.Wallet = wallet
					end
				end
			end
			def:Resolve( playerNames )
		end )
		:Fail( function( errid, err )
			def:Fail( 1, "Error fetching wallets: " .. err )
		end	)
		
		return def:Promise( )
	end )
end

function Pointshop2Controller:getUserDetails( ply, kPlayerId )
	local def = Deferred( )
	
	WhenAllFinished{ LibK.Player.findById( kPlayerId ), 
					 Pointshop2.Wallet.findByOwnerId( kPlayerId ), 
					 KInventory.Inventory.findByOwnerId( kPlayerId )
	}:Then( function( dbPlayer, wallet, inventory )
		dbPlayer.wallet = wallet
		dbPlayer.inventory = inventory
		if not wallet or not inventory then
			local def = Deferred( )
			def:Reject( 1, "Player is not a Pointshop2 User" )
			return def:Promise( )
		end
		return inventory:loadItems( )
		:Then( function( )
			return dbPlayer
		end )
	end )
	:Done( function( plyInfo )
		def:Resolve( plyInfo )
	end )
	:Fail( function( errid, err )
		def:Reject( errid, err )
	end )
	
	return def:Promise( )
end

function Pointshop2Controller:updatePlayerWallet( kPlayerId, currencyType, newValue )
	if not table.HasValue( { "points", "premiumPoints" }, currencyType ) then
		local def = Deferred( )
		def:Reject( 0, "Invalid currency type " .. currencyType )
		return def:Promise( )
	end
	
	local walletPromise = Deferred( ) 
	local walletFound = false
	local shouldBlock = Pointshop2.GetSetting( "Pointshop 2", "AdvancedSettings.ShouldBlock" )
	for k, v in pairs( player.GetAll( ) ) do
		if v.kPlayerId == kPlayerId then
			if v.PS2_Wallet then 
				walletPromise:Resolve( v.PS2_Wallet )
				walletFound = true
			end
		end
	end
	
	if not walletFound then
		Pointshop2.Wallet.findByOwnerId( kPlayerId )
		:Done( function( wallet )
			walletPromise:Resolve( wallet )
		end )
		:Fail( function( errid, err )
			walletPromise:Reject( errid, err )
		end )
	end
	
	if walletFound and shouldBlock then --no need to block if player is offline
		Pointshop2.DB:SetBlocking( true ) --don't want player to sell/buy stuff during our update
	end
	
	newValue = tonumber( newValue )
	return walletPromise:Then( function( wallet )
		wallet[currencyType] = newValue
		return wallet:save( )
	end )
	:Always( function( )
		if walletFound and shouldBlock then
			Pointshop2.DB:SetBlocking( false )
		end
	end )
end

function Pointshop2Controller:adminChangeWallet( ply, kPlayerId, currencyType, newValue )
	return self:updatePlayerWallet( kPlayerId, currencyType, newValue )
	:Done( function( wallet )
		local walletOwner
		for k, v in pairs( player.GetAll( ) ) do 
			if v.kPlayerId == kPlayerId then
				walletOwner = v
			end
		end
		self:startView( "Pointshop2View", "walletChanged", self:getWalletChangeSubscribers( walletOwner ), wallet )
	end )
end

function Pointshop2Controller:addPointsBySteamId( steamId, currencyType, amount )
	-- Player is online do standard stuff
	for k, v in pairs( player.GetAll( ) ) do
		if v:SteamID( ) == steamId then
			return self:addToPlayerWallet( v, currencyType, amount )
		end
	end
	
	return LibK.Player.findByPlayer( steamId )
	:Then( function( ply )
		-- Player may or may not be in DB, create if not
		if not ply then
			ply = LibK.Player:new( )
			ply.name = "Unknown"
			ply.player = steamId
			ply.steam64 = util.SteamIDTo64( steamId )
			ply.uid = util.CRC( "gm_" .. steamId .. "_gm" )
			return ply:save( )
		end
		return ply
	end )
	:Then( function( ply )
		return WhenAllFinished{ Pointshop2.Wallet.findByOwnerId( ply.id ), Promise.Resolve( ply ) }
	end )
	:Then( function( wallet, kPlayer  ) 
		-- Player might not have a PS2 Wallet yet, create it if he does not
		if not wallet then
			local wallet = Pointshop2.Wallet:new( )
			wallet.points = Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.DefaultWallet.Points" )
			wallet.premiumPoints = Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.DefaultWallet.PremiumPoints" )
			wallet.ownerId = kPlayer.id
			return wallet:save( )
		end
		return wallet
	end )
	:Then( function( wallet )
		if not table.HasValue( { "points", "premiumPoints" }, currencyType ) then
			return Promise.Reject( 1, "Invalid Currency " .. tostring( currencyType ) )
		end
		
		wallet[currencyType] = wallet[currencyType] + amount
		return wallet:save( )
	end )
end