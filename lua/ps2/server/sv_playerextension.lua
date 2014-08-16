local Player = FindMetaTable( "Player" )

function Player:PS2_AddStandardPoints( points, message, small )
	if points == 0 then return end
	
	hook.Run( "PS2_PointsAwarded", self, points )
	
	Pointshop2Controller:getInstance( ):addToPlayerWallet( self, "points", points )
	if message then
		Pointshop2Controller:getInstance( ):addToPointFeed( self, message, points, small )
	end
end

function Player:PS2_AddPremiumPoints( points)
	if points == 0 then return end		
	
	hook.Run( "PS2_PointsAwarded", self, points )
	
	Pointshop2Controller:getInstance( ):addToPlayerWallet( self, "premiumPoints", points )
end