LibK.addContentFolder( "materials/pointshop2" )
LibK.addContentFolder( "materials/trails" )

function Pointshop2.ResetDatabase( )
	local models = {}
	local function add( tbl ) 
		for k, v in pairs( tbl ) do
			if istable( v ) and v.dropTable then
				table.insert( models, v )
			end
		end
	end
	add( Pointshop2 )
	add( KInventory )
	
	LibK.SetBlocking( true )
	Pointshop2.DB.DisableForeignKeyChecks( true )
	local promises = {}
	for k, v in pairs( models ) do
		local promise = v.dropTable( )
		:Done( function( )
			KLogf( 5, "Dropped table %s", v.name )
		end )
		table.insert( promises, promise )
	end
	
	LibK.ResetTableCache( )
	
	for k, v in pairs( models ) do
		local promise = v:initializeTable( )
		:Done( function( )
			KLogf( 5, "Reset Table %s", v.name )
		end )
		table.insert( promises, promise )
	end
	Pointshop2.DB.DisableForeignKeyChecks( false )
	LibK.SetBlocking( false )
	
	return WhenAllFinished( promises )
end

function Pointshop2.PlayerOwnsItem( ply, item )
	for k, v in pairs( ply.PS2_Inventory:getItems( ) ) do
		if v.id == item.id then
			return true
		end
	end
	
	for k, v in pairs( ply.PS2_Slots ) do
		if v.itemId == item.id then
			return true
		end
	end
	
	return false
end
