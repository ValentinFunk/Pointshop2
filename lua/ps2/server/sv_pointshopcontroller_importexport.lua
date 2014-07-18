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
		local filename = "ps2_export_".. os.date( "%Y-%m-%d_%H-%M" ) .. ".txt"
		print( filename )
		file.Write( filename, LibK.luadata.Encode( exportTable ) )
	end )
end

function Pointshop2Controller:importItems( filename )
	local promises = {}
	
	KLogf( 4, "[Pointshop2] Starting import of %s", filename )
	
	local exportTable = LibK.luadata.ReadFile( filename )
	for persistenceClassName, exportData in pairs( exportTable ) do
		local persistenceClass = getClass( persistenceClassName )
		if not persistenceClass then
			KLogf( 3, "[WARN] Not importing %s items, persistence not installed!" )
			continue
		end
		
		if not persistenceClass.importDataFromTable then
			KLogf( 3, "[WARN] Not importing %s items, persistence not supported!" )
			continue
		end
		
		local promise = persistenceClass.importDataFromTable( exportData )
		promise:Done( function( )
			KLogf( 4, "    -> Imported %s", persistenceClassName )
		end )
		table.insert( promises, promise )
	end
	
	return WhenAllFinished( promises )
	:Then( function( )
		return self:moduleItemsChanged( )
	end )
end