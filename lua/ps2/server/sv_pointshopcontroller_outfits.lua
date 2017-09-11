function Pointshop2Controller:loadOutfits( )
	return WhenAllFinished{ Pointshop2.StoredOutfit.getAll( ) }
	:Then( function( outfits )

		local outfitsAssoc = {}
		for k, v in pairs( outfits ) do
			outfitsAssoc[v.id] = v.outfitData
		end
		Pointshop2.Outfits = outfitsAssoc

		local data = util.TableToJSON( { outfitsAssoc } )
		local resource = LibK.GLib.Resources.RegisterData( "Pointshop2", "outfits", data )
		resource:GetCompressedData( ) --Force compression now
		local versionHash = resource:GetVersionHash( )
		KLogf( 4, "[Pointshop2] Outfit package loaded, version " .. versionHash .. " " .. #outfitsAssoc .. " outfits." )
	end )
end

function Pointshop2Controller:SendInitialOutfitPackage( ply )
	local resource = LibK.GLib.Resources.Resources["Pointshop2/outfits"]
	if not resource then
		KLogf( 4, "[Pointshop2] Outfit package not loaded yet, trying again later" )
	end

	Pointshop2.OutfitsLoadedPromise:Then( function( resource )
		self:startView( "Pointshop2View", "loadOutfits", ply, resource:GetVersionHash( ) )
	end )
end

--Player notifies us that he has loaded and decoded all PAC outfits
function Pointshop2Controller:outfitsReceived( ply )
	KLogf( 5, "Received outfits from %s", ply:Name( ) )
	if ply.outfitsReceivedPromise._promise._state == "pending" then
		ply.outfitsReceivedPromise:Resolve( )
	end
end
