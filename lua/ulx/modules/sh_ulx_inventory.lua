local function giveItem( calling_ply, target_ply, itemName, amount )
	KInventory.Inventory.findByOwnerId( target_ply.kPlayerId )
	:Then( function( inv )
		if not inv then
			ULib.tsayError( calling_ply, target_ply:Nick( ) .. " does not have a valid inventory!" )
			return
		end
		
		local itemClass = KInventory.Items[itemName]
		if not itemClass then
			ULib.tsayError( calling_ply, "Item " .. item .. " does not exist!" )
			return
		end
		
		--Chain, TODO: Look for a better way to do this, add something to model for multiple inserts
		--Make sure to check weight and stuff beforehand
		local itemsGiven = 0
		local item = itemClass:new( )
		local promise = inv:addItem( item ):Then( function( ) itemsGiven = itemsGiven + 1 end )
		for i =2, amount do
			local item = itemClass:new( )
			promise = promise:Then( function( )
				inv:addItem( item )
			end )
			:Then( function( )
				itemsGiven = itemsGiven + 1
			end )
		end
		
		promise:Then( function( )
			local str = "#A gave #T #i #s"
			ulx.fancyLogAdmin( calling_ply, str, target_ply, amount, itemName )
		end, 
		function( errid, err )
			if errid > 0 then
				ULib.tsayError( calling_ply, "There was an error giving the items: " .. err ..", " .. itemsGiven .. " items were given to the player" )
			else
				ULib.tsayError( calling_ply, "There was an internal giving the items: " .. errid )
				error( "Error giving items (ulx command): " .. errid .. ", " .. err )
			end
		end )
	end )
end
local giveItemCmd = ulx.command( "Inventory", "inv giveitem", giveItem, "!give" )
giveItemCmd:defaultAccess( ULib.ACCESS_ADMIN )
giveItemCmd:addParam{ type=ULib.cmds.PlayerArg }
giveItemCmd:addParam{ type=ULib.cmds.StringArg, hint="Item" }
giveItemCmd:addParam{ type=ULib.cmds.NumArg, min=1, default=1, hint="Amount", ULib.cmds.optional }
giveItemCmd:help( "Give an item to a player" )