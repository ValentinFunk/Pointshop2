local Player = FindMetaTable( "Player" )

function Player:PS2_AddStandardPoints( points, message, small, suppressEvent )
	if points == 0 then return end
	
	if not suppressEvent then
		hook.Run( "PS2_PointsAwarded", self, points, "points" )
	end
	
	Pointshop2Controller:getInstance( ):addToPlayerWallet( self, "points", points )
	if message then
		Pointshop2Controller:getInstance( ):addToPointFeed( self, message, points, small )
	end
end

function Player:PS2_AddPremiumPoints( points)
	if points == 0 then return end		
	
	hook.Run( "PS2_PointsAwarded", self, points, "premiumPoints" )
	
	Pointshop2Controller:getInstance( ):addToPlayerWallet( self, "premiumPoints", points )
end

function Player:PS2_EasyAddItem( itemClass, purchaseData, supressNotify )
	if not self:PS2_HasInventorySpace( 1 ) then
		return Promise.Reject( 1, "No space in Inventory" )
	end
	return Pointshop2Controller:getInstance():easyAddItem( self, itemClass, purchaseData, supressNotify )
end