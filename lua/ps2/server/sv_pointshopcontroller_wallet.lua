--network wallets to owning players and all admins
function Pointshop2Controller:getWalletChangeSubscribers( ply )
	if Pointshop2.GetSetting( "Pointshop 2", "AdvancedSettings.BroadcastWallets" ) then
		return player.GetAll()
	else
		local receivers = { ply }
		for k, v in pairs( player.GetAll( ) ) do
			if PermissionInterface.query( v, "pointshop2 manageusers" ) then
				if v == ply then continue end
				table.insert( receivers, v )
			end
		end
		return receivers
	end
end
hook.Add( "PS2_OnSettingsUpdate", "AddOrRemoveWalletBroadcast", function( )
	if Pointshop2.GetSetting( "Pointshop 2", "AdvancedSettings.BroadcastWallets" ) then
		hook.Add( "LibK_PlayerInitialSpawn", "PS2_SendWallets", function( ply )
			timer.Simple( 2, function( )
				for k, v in pairs( player.GetAll( ) ) do
					if v.PS2_Wallet then
						Pointshop2Controller:getInstance( ):startView(  "Pointshop2View", "walletChanged", ply, v.PS2_Wallet )
					end
				end
			end )
		end )
	else
		hook.Remove( "LibK_PlayerInitialSpawn", "PS2_SendWallets" )
	end
end )

function Pointshop2Controller:broadcastWalletChanges( wallet )
	self:startView( "Pointshop2View", "walletChanged", self:getWalletChangeSubscribers( wallet:GetOwner( ) ), wallet )
end

function Pointshop2Controller:sendWallet( ply )
	return Pointshop2.Wallet.findByOwnerId( ply.kPlayerId )
	:Then( function( wallet )
		if not wallet then
			local wallet = Pointshop2.Wallet:new( )
			wallet.points = Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.DefaultWallet.Points" )
			wallet.premiumPoints = Pointshop2.GetSetting( "Pointshop 2", "BasicSettings.DefaultWallet.PremiumPoints" )
			wallet.ownerId = ply.kPlayerId
			return wallet:save( )
		end
		return wallet
	end )
	:Then( function( wallet )
		ply.PS2_Wallet = wallet
		self:startView( "Pointshop2View", "walletChanged", self:getWalletChangeSubscribers( ply ), wallet )
	end )
end

function Pointshop2Controller:addToPlayerWallet( ply, currencyType, addition )
	if not table.HasValue( { "points", "premiumPoints" }, currencyType ) then
		return Promise.Reject(-2, "Invalid currency type " .. currencyType)
	end

	if not LibK.isProperNumber( addition ) then
		return Promise.Reject( 0, "Not a proper number" )
	end

	if not ply.PS2_Wallet then
		return Promise.Reject(-2, "Player wallet not loaded")
	end

	addition = math.floor( addition )
	if addition == 0 then
		return Promise.Resolve()
	end

	local query = Format("UPDATE ps2_wallet SET %s = %s + %i WHERE id = %i", currencyType, currencyType, addition, ply.PS2_Wallet.id)
	return Pointshop2.DB.DoQuery( query )
	:Done( function( )
		ply.PS2_Wallet[currencyType] = ply.PS2_Wallet[currencyType] + addition
		self:broadcastWalletChanges( ply.PS2_Wallet )
	end )
end

function Pointshop2Controller:addToPointFeed( ply, message, points, small )
	self:startView( "Pointshop2View", "addToPointFeed", ply, message, points, small )
end
