local Player = FindMetaTable( "Player" )

function Player:PS2_AddStandardPoints( points, message, small, suppressEvent )
	if points == 0 then return end

	if suppressEvent == nil  then 
		suppressEvent = points < 0
	end

	if not suppressEvent then
		hook.Run( "PS2_PointsAwarded", self, points, "points" )
	end

	if Pointshop2.StandardPointsBatch:isInProgress( ) then
		Pointshop2.StandardPointsBatch:addPoints( self, points )
	else
		Pointshop2Controller:getInstance( ):addToPlayerWallet( self, "points", points )
	end

	if message then
		Pointshop2Controller:getInstance( ):addToPointFeed( self, message, points, small )
	end
end

function Player:PS2_AddPremiumPoints( points)
	if points == 0 then return end

	hook.Run( "PS2_PointsAwarded", self, points, "premiumPoints" )

	if Pointshop2.PremiumPointsBatch:isInProgress( ) then
		Pointshop2.PremiumPointsBatch:addPoints( self, points )
	else
		Pointshop2Controller:getInstance( ):addToPlayerWallet( self, "premiumPoints", points )
	end
end

function Player:PS2_EasyAddItem( itemClassName, purchaseData, suppressNotify )
	if not self:PS2_HasInventorySpace( 1 ) then
		return Promise.Reject( 1, "No space in Inventory" )
	end
	return Pointshop2Controller:getInstance():easyAddItem( self, itemClassName, purchaseData, suppressNotify )
end

function Player:PS2_DisplayInformation( text, time )
	Pointshop2Controller:getInstance( ):startView( "Pointshop2View", "displayInformation", self, text, time )
end

function Player:PS2_DisplayError( text, time )
	if isstring( time ) then
		time = nil
	end
	Pointshop2Controller:getInstance( ):startView( "Pointshop2View", "displayError", self, text, time )
end
