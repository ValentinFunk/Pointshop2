local PointsBatch = class( "PointsBatch" )

function PointsBatch:initialize( currencyType )
	if not currencyType or not table.HasValue( { "points", "premiumPoints"}, currencyType ) then
		error( "Invalid currencyType. currencyType must be points or premiumPoints" )
	end
	
	self.currencyType = currencyType
	self.pointsChanges = nil
end

function PointsBatch:isInProgress( )
	return self.pointsChanges != nil
end

function PointsBatch:addPoints( ply, amount )	
	if not self:isInProgress( ) then
		KLogf( 3, "[WARN] Adding Points to a batch before starting one" )
		if LibK.Debug then 
			debug.Trace( )
		end
		return
	end
	
	self.pointsChanges[ply] = self.pointsChanges[ply] or 0
	self.pointsChanges[ply] = self.pointsChanges[ply] + amount
end

function PointsBatch:begin( )
	if self:isInProgress( ) then
		KLogf( 3, "[WARN] Nested points batch" )
		if LibK.Debug then
			debug.Trace()
		end
		return
	end
	self.pointsChanges = {}
end

function PointsBatch:finish( )
	if not self:isInProgress( ) then
		KLogf( 3, "[WARN] Ending points batch before starting one" )
		if LibK.Debug then 
			debug.Trace( )
		end
		return
	end
	
	if table.Count( self.pointsChanges ) == 0 then
		self.pointsChanges = nil
		return
	end 
	
	local query = "UPDATE ps2_wallet SET " .. self.currencyType .. " = CASE ownerId "
	local ownerIds = {}
	local parts = {}
	for ply, points in pairs( self.pointsChanges ) do
		if not IsValid( ply ) or not ply.kPlayerId then 
			continue
		end
		
		if not table.HasValue( ownerIds, ply.kPlayerId ) then
			table.insert( ownerIds, tonumber( ply.kPlayerId ) )
		end
		table.insert( parts, Format( 'WHEN "%i" THEN %s + "%i"', ply.kPlayerId, self.currencyType, points ) )
	end
	query = query .. table.concat( parts, " " )
	query = query .. ' ELSE points END WHERE ownerId IN (' .. table.concat( ownerIds, ', ' ) .. ')'
	
	if #ownerIds == 0 then
		self.pointsChanges = nil
		return
	end
	
	Pointshop2.DB.DoQuery( query )
	:Done( function( )
		for ply, points in pairs( self.pointsChanges ) do
			if not ply.PS2_Wallet then
				continue
			end
			
			ply.PS2_Wallet[self.currencyType] = ply.PS2_Wallet[self.currencyType] + points
			Pointshop2Controller:getInstance( ):broadcastWalletChanges( ply.PS2_Wallet )
		end
	end )
	:Fail( function( id, err )
		KLogf( 1, "[Pointshop 2] Error saving points batch! Dumping " .. self.currencyType )
		for ply, points in pairs( self.pointsChanges ) do
			KLogf( 1, "%s : %i", ply:Nick( ), points )
		end
		KLogf( 1, "Done" )
	end )
	:Always( function( )
		self.pointsChanges = nil
	end )
end

Pointshop2.StandardPointsBatch = PointsBatch:new( "points" )
Pointshop2.PremiumPointsBatch = PointsBatch:new( "premiumPoints" )