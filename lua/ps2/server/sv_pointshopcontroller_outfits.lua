function Pointshop2Controller:loadOutfits( )
	return WhenAllFinished{ Pointshop2.StoredOutfit.getAll( ), Pointshop2.StoredOutfit.getVersionHash( ) }
	:Then( function( outfits, versionHash )
		
		local outfitsAssoc = {}
		for k, v in pairs( outfits ) do
			outfitsAssoc[v.id] = v.outfitData
		end
		Pointshop2.Outfits = outfitsAssoc
		
		local data = LibK.von.serialize( { outfitsAssoc } )
		local resource = LibK.GLib.Resources.RegisterData( "Pointshop2", "outfits", data )
		resource:SetVersionHash( tostring( versionHash ) )
		resource:GetCompressedData( ) --Force compression now
		KLogf( 4, "[Pointshop2] Outfit package loaded, version " .. versionHash .. " " .. #outfitsAssoc .. " outfits." )
		
		self:startView( "Pointshop2View", "loadOutfits", player.GetAll( ), versionHash )
	end )
end
Pointshop2.DatabaseConnectedPromise:Done( function( )
	Pointshop2Controller:getInstance( ):loadOutfits( )
end )

function Pointshop2Controller:SendInitialOutfitPackage( ply )
	local resource = LibK.GLib.Resources.Resources["Pointshop2/outfits"]
	if not resource then
		KLogf( 4, "[Pointshop2] Outfit package not loaded yet, trying again later" )
		timer.Simple( 1, function( ) self:SendInitialOutfitPackage( ply ) end )
		return
	end
	self:startView( "Pointshop2View", "loadOutfits", ply, resource:GetVersionHash( ) )
end
hook.Add( "LibK_PlayerInitialSpawn", "InitialRequestOutfits", function( ply )
	timer.Simple( 1, function( )
		Pointshop2Controller:getInstance( ):SendInitialOutfitPackage( ply )
	end )
end )
hook.Add( "OnReloaded", "InitialRequestOutfitsR", function( )
	for k, ply in pairs( player.GetAll( ) ) do
		timer.Simple( 1, function( )
			Pointshop2Controller:getInstance( ):SendInitialOutfitPackage( ply )
		end )
	end
end )

--Player notifies us that he has loaded and decoded all PAC outfits
function Pointshop2Controller:outfitsReceived( ply )
	KLogf( 5, "Received outfits from %s", ply:Name( ) )
	if ply.outfitsReceivedPromise._promise._state == "pending" then
		ply.outfitsReceivedPromise:Resolve( )
	end
end