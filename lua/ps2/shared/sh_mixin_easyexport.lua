--Easy export mixin
--It would be possible to do more automagic by detecting libk joins etc through the models
--this is not done to give the user more control and avoid complex solutions

Pointshop2.EasyExport = {}
local EasyExport = Pointshop2.EasyExport

local function generateExportTable( class )
	return class.getDbEntries( "WHERE 1" )
	:Then( function( instances ) 
		local exportTable = {}
		
		for _, instance in pairs( instances ) do
			local export = instance:generateInstanceExportTable( )
			table.insert( exportTable, export )
		end
		
		return exportTable
	end )
end

local copyModelFields = LibK.copyModelFields
local function importDataFromTable( class, exportTable )
	local promises = {}
	
	for _, instanceExport in pairs( exportTable ) do
		local itemPersistence = Pointshop2.ItemPersistence:new( )
		copyModelFields( itemPersistence, instanceExport.ItemPersistence, Pointshop2.ItemPersistence.model )
		itemPersistence.uuid = LibK.GetUUID()

		local promise = itemPersistence:save( )
		:Then( function( itemPersistence )
			local actualPersistence = class:new( )
			copyModelFields( actualPersistence, instanceExport, class.model )
			actualPersistence.itemPersistenceId = itemPersistence.id
			return actualPersistence:save( )
		end )
		table.insert( promises, promise )
	end
	
	return WhenAllFinished( promises )
end

function EasyExport:included( class )
	--Bind generateExportTable to class
	class.generateExportTable = function( )
		return generateExportTable( class )
	end
	
	class.importDataFromTable = function( exportTable )
		return importDataFromTable( class, exportTable )
	end
end

--This one works only for simple classes with only one ItemPersistence relationship!
function EasyExport:generateInstanceExportTable( )
	--Serialize all info but remove id and class fields
	local cleanTable = generateNetTable( self )
	cleanTable.id = nil
	cleanTable.itemPersistenceId = nil
	cleanTable._classname = nil
	
	cleanTable.ItemPersistence = self.ItemPersistence:generateInstanceExportTable( )
	
	return cleanTable
end