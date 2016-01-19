AdventCalendarController = class( "AdventCalendarController" )
AdventCalendarController:include( BaseController )


function AdventCalendarController:canDoAction( ply, action )
	if action == "OpenDoor" then
		return Promise.Resolve( )
	end
	return Promise.Reject( )
end

function AdventCalendarController:OpenDoor( ply, door )
	local date = os.date( "*t", system.SteamTime() )
	if date.month != 12 then
		return Promise.Reject( "It's not December" )
	end

	if date.day != door then
		return Promise.Reject( "It's not day " .. date.day .. " (server time: " .. os.date( '%c', system.SteamTime() ) .. "). Please keep timezones in mind!" )
	end

	return Pointshop2.AdventCalendarUses.findWhere{ player = ply.kPlayerId, day = door }
	:Then( function( uses )
		if #uses > 0 then
			return Promise.Reject( "You have already opened today's door." )
		end

		if not ply:PS2_HasInventorySpace( 1 ) then
			return Promise.Reject( "Your inventory is full. Please free a slot" )
		end

		local factory = Pointshop2.AdventCalendar.GetTodaysFactory( )
		if not factory then
			return Promise.Reject( "Invalid Factory - has the calendar been configured?" )
		end
		return factory:CreateItem( )
	end )
	:Then( function( item )
		local price = item.class:GetBuyPrice( ply )
		item.purchaseData = {
			time = os.time( ),
			origin = "AdventCalendar"
		}
		if price.points then
			item.purchaseData.amount = price.points
			item.purchaseData.currency = "points"
		elseif price.premiumPoints then
			item.purchaseData.amount = price.points
			item.purchaseData.currency = "premiumPoints"
		else
			item.purchaseData.amount = 0
			item.purchaseData.currency = "points"
		end
		return item:save( )
	end )
	:Then( function( item )
		KInventory.ITEMS[item.id] = item
		return ply.PS2_Inventory:addItem( item )
		:Then( function( )
			KLogf( 4, "Player %s used advent calendar got item %s", ply:Nick( ), item:GetPrintName( ) or item.class.PrintName )
			item:OnPurchased( )
			Pointshop2Controller:getInstance( ):startView( "Pointshop2View", "displayItemAddedNotify", ply, item )
			return item
		end )
	end )
	:Then( function( )
		local use = Pointshop2.AdventCalendarUses:new( )
		use.player = ply.kPlayerId
		use.day = date.day
		use:save( )
	end )
	:Then( function( )
		self:SendPlayerInfo( ply )
	end )
end

function AdventCalendarController:SendPlayerInfo( ply )
	Promise.Delay( 1 )
	:Then( function( )
		return Pointshop2.AdventCalendarUses.findWhere{ player = ply.kPlayerId }
	end )
	:Then( function( uses )
		local usesMap = {}
		for k, v in pairs( uses ) do
			usesMap[v.day] = true
		end
		self:startView( "AdventCalendarView", "ReceiveUses", ply, usesMap )
	end )
end

hook.Add( "LibK_PlayerInitialSpawn", "AdventCalendar_SendInfo", function( ply )
	AdventCalendarController:getInstance( ):SendPlayerInfo( ply )
end )
