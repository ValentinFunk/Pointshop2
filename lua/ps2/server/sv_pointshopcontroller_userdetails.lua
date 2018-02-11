function Pointshop2Controller:searchPlayers( ply, subject, attribute )
	local attributeTranslate = { ["Name"] = "name", ["Steam ID"] = "player", ["Profile ID"] = "steam64" }
	if not attributeTranslate[attribute] then
		local def = Deferred( )
		def:Reject( "Invalid attribute " .. attribute )
		return def:Promise( )
	end

	local ids = {}
	local playerNames = {}

	return LibK.Player.findPlayers( subject, attributeTranslate[attribute], 100 )
	:Then( function( players )
		for k, v in pairs( players ) do
			table.insert( ids, tonumber( v.id ) )
			table.insert( playerNames, { id = v.id, name = v.name, lastConnected = v.updated_at } )
		end

		if #ids == 0 then
			return Promise.Resolve( {} )
		end

		return Pointshop2.Wallet.getDbEntries( "WHERE ownerId IN (" .. table.concat( ids, ', ' ) .. ")" )
	end )
	:Then( function( wallets )
		for k, v in pairs( playerNames ) do
			for _, wallet in pairs( wallets ) do
				if wallet.ownerId == v.id then
					v.Wallet = wallet
				end
			end
		end
		
		return playerNames
	end, function( errid, err )
		return Promise.Reject( 1, "Error fetching wallets: " .. err )
	end )
end

local function fetchSlotsFromDatabase( kPlayerId )
	return Pointshop2.EquipmentSlot.findAllByOwnerId( kPlayerId )
		:Then( function( slotRows )
			local slots = {}
			for _, slotRow in pairs( slotRows ) do
				slots[slotRow.id] = slotRow
			end
			return slots
		end )
end

local function fetchInventoryFromDatabase( kPlayerId )
	return KInventory.Inventory.findByOwnerId( kPlayerId )
		:Then( function( inv )
			return inv:loadItems( ):Then( function( )
				return inv
			end )
		end )
end

function Pointshop2Controller:getUserDetails( adminPly, kPlayerId )
	-- Since we want to avoid overwriting the item cache we make sure to only
	-- load items/slots if they are not already loaded for a player.
	local inventoryPromise = Promise.Resolve():Then(function()
		for k, v in pairs(player.GetAll()) do
			if v.kPlayerId == kPlayerId then
				return v.fullyLoadedPromise:Then( function( )
					return v.PS2_Inventory
				end, function() 
					-- Player might disconnect before loading has finished
					return fetchInventoryFromDatabase( kPlayerId )
				end )
			end
		end
		return fetchInventoryFromDatabase( kPlayerId )
	end)

	local slotsPromise = Promise.Resolve():Then(function()
		for k, v in pairs(player.GetAll()) do
			if v.kPlayerId == kPlayerId then
				return v.fullyLoadedPromise:Then( function( )
					return v.PS2_Slots
				end, function() 
					-- Player might disconnect before loading has finished
					return fetchSlotsFromDatabase( kPlayerId )
				end )
			end
		end
		return fetchSlotsFromDatabase( kPlayerId )
	end)

	return WhenAllFinished{ 
		LibK.Player.findById( kPlayerId ),
		Pointshop2.Wallet.findByOwnerId( kPlayerId ),
		inventoryPromise,
		slotsPromise
	}:Then( function( dbPlayer, wallet, inventory, slots )
		dbPlayer.wallet = wallet
		dbPlayer.inventory = inventory
		dbPlayer.slots = slots
		if not wallet or not inventory then
			local def = Deferred( )
			def:Reject( 1, "Player is not a Pointshop2 User" )
			return def:Promise( )
		end

		return dbPlayer
	end )
end

function Pointshop2Controller:updatePlayerWallet( kPlayerId, currencyType, newValue )
	if not table.HasValue( { "points", "premiumPoints" }, currencyType ) then
		return Promise.Reject( 1, "Invalid currency type " .. currencyType )
	end

	if not LibK.isProperNumber( newValue ) then
		return Promise.Reject( 0, "Improper number passed" )
	end

	return Promise.Resolve():Then(function()
		for k, v in pairs( player.GetAll( ) ) do
			if v.kPlayerId == kPlayerId then
				if v.PS2_Wallet then
					return v.PS2_Wallet
				end
			end
		end

		return Pointshop2.Wallet.findByOwnerId( kPlayerId )
	end):Then( function( wallet )
		wallet[currencyType] = newValue
		return wallet:save( )
	end )
end

function Pointshop2Controller:adminChangeWallet( ply, kPlayerId, currencyType, newValue )
	return self:updatePlayerWallet( kPlayerId, currencyType, newValue )
	:Done( function( wallet )
		self:broadcastWalletChanges( wallet )
	end )
end

function Pointshop2Controller:addPointsBySteamId( steamId, currencyType, amount )
	-- Player is online do standard stuff
	for k, v in pairs( player.GetAll( ) ) do
		if v:SteamID( ) == steamId and v.PS2_Wallet then
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

function Pointshop2Controller:adminGiveItem( adminPly, kPlayerId, itemClassName )
	local itemClass = Pointshop2.GetItemClassByName( itemClassName )

	if not itemClass then
		return Promise.Reject( "Invalid item class " .. itemClassName )
	end

	local ply
	for k, v in pairs( player.GetAll( ) ) do
		if v.kPlayerId == kPlayerId then
			ply = v
		end
	end

	local item = itemClass:new( )
	return Promise.Resolve()
	:Then( function( )
		item.purchaseData = purchaseData or {
			time = os.time(),
			amount = 0,
			currency = "points",
			origin = "admin"
		}
		return item:save( )
	end )
	:Then( function( item )
		if IsValid( ply ) then
			return WhenAllFinished{ ply.outfitsReceivedPromise:Promise( ), ply.dynamicsReceivedPromise:Promise( ) }
			:Then( function( )
				return ply.PS2_Inventory
			end )
		else
			return KInventory.Inventory.findByOwnerId( kPlayerId )
		end
	end )
	:Then( function( inventory )
		if not inventory then
			return Promise.Reject( "The player has not used pointshop 2 yet. Could not give item." )
		end
		return inventory:addItem( item )
	end )
	:Then( function( inventory )
		if IsValid( ply ) then
			self:startView( "Pointshop2View", "displayItemAddedNotify", ply, item )
		end
		KLogf( 4, "Admin %s gave %s %s", adminPly:Nick( ), ply and ply:Nick( ) or kPlayerId, item:GetPrintName( ) )
	end )
end
