util.AddNetworkString( "PlayerUseItem" )

local Item = KInventory.Item

net.Receive( "PlayerUseItem", function( len, ply )
	local itemId = net.ReadInt( 32 )
	
	KInventory.Item.findById( itemId )
	:Then( function( item )
		if not item then
			return KLogf( 3, "[WARN] Player %s tried to use unknown item %i", ply:Nick( ), itemId )
		end
		
		if item:getOwner( ) == ply then
			item:use( ply )
		else
			KLogf( 3,"%s tried to use item he doesnt own(id %i, ower is %i)", ply:Nick( ), item.id, item.ownerId )
		end
	end )
end )

function Item:handleDrop( ply )
	KLogf( 4, "Item:handleDrop( " .. tostring( ply ) .. ")" )
	local tr = util.TraceLine( util.GetPlayerTrace( ply ) )
	
	local vec = ply:GetAimVector( ) * 10 + ply:GetUp( ) * 1
	if tr.Hit then
		local hit = tr.HitPos
		vec = ( hit - ply:EyePos( ) )
		vec:Normalize( )
		vec = vec * 100
	end
	
	local droppedItem = ents.Create( "spawned_item" )
	droppedItem:setItem( self )
	droppedItem:SetPos( ply:EyePos( ) + ply:GetForward( ) * 3 )
	droppedItem:Spawn()
	droppedItem:Activate()
	droppedItem:GetPhysicsObject( ):ApplyForceCenter( vec * droppedItem:GetPhysicsObject( ):GetMass( ) )
end