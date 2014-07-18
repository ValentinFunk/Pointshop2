
function Pointshop2Controller:exportItems( )
	local promises = {}
	
	local exportTable = {}
	for _, persistence in pairs( Pointshop2Controller:getPersistenceModels( ) ) do
		if persistence.generateExportTable then
			local promise = persistence.generateExportTable( )
			:Done( function( persistenceExported )
				exportTable[persistence.name] = persistenceExported
			end )
			:Fail( function( err )
				error( persistence.name "Failed", err )
			end )
			table.insert( promises, promise )
		else
			KLogf( 3, "[WARN] Couldn't export persistence %s, not implemented!", persistence.name )
		end
	end
	
	WhenAllFinished( promises )
	:Done( function( )
		local filename = "ps2_export_.txt" //.. os.date( "%Y-%m-%d %H:%M" ) .. ".txt"
		print( filename )
		file.Write( filename, LibK.luadata.Encode( exportTable ) )
	end )
end