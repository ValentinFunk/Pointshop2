-- Returns a promise that wraps the promise given by fn
-- This is used to make sure that the global promises are available
-- befre the function is evaluated.
function wrapPromise( fn )
    local def = Deferred()

    LibK.WhenAddonsLoaded{ "Pointshop2" }
    :Then( fn )
    :Then( function( ... ) 
        return def:Resolve( ... ) 
    end, function( ... )
        def:Reject( ... )
    end )

    return def:Promise()
end

function Pointshop2.Bootstrap()
    --[[
        # Load Modules
        This includes all of the files in "lua/ps2/modules" after InitPostEntity
        and performs the module loading logic.
    ]]--
    Pointshop2.ModulesLoadedPromise = wrapPromise( function()
        return LibK.InitPostEntityPromise
            :Then( Pointshop2.LoadModules )
            :Then( function( )
                KLogf( 4, "[Pointshop 2] All modules were loaded" )
                hook.Run( "PS2_ModulesLoaded" )
            end )
    end )

    --[[
        # Connect to and initialize the database
        This initializes all LibK Models, creating tables and magic functions
        after modules have been loaded.
    ]]--
    Pointshop2.DatabaseConnectedPromise = wrapPromise( function()
        return Pointshop2.ModulesLoadedPromise
        :Then( function( ) 
            LibK.SetupDatabase( "Pointshop2", Pointshop2, nil, true )
            Pointshop2.DBInitialize( ) -- After this function Pointshop2.DB is available
            DATABASES["KInventory"] = Pointshop2.DB

            return Pointshop2.DB.ConnectionPromise
        end )
    end )
        
	Pointshop2.DatabaseConnectedPromise
        :Then( function( ) 
            KLogf( 4, "[Pointshop 2] The database is connected." )
        end, function( err )
            KLogf( 1, "[Pointshop2] The database is not set up correctly!")
        end )

    --[[
        # Load all Settings
        First determines the current server, then loads the settings
        for the server.
    ]]--
    Pointshop2.SettingsLoadedPromise = wrapPromise(function()
        return Pointshop2.DatabaseConnectedPromise
        :Then( function() 
            return Pointshop2Controller:initServer( )
        end )
        :Then( function( )
            return Pointshop2Controller:getInstance( ):loadSettings( )
        end )
        :Then( function() 
		    hook.Run( "PS2_OnSettingsUpdate" )
            return LibK.GLib.Resources.Resources["Pointshop2/settings"]
        end, function( ) 
            KLogf( 1, "[Pointshop2] Could not load settings" )
        end )
    end )

    --[[
        # Include all item bases
        This includes all item bases in kinv/items, applying base classes
        and mixins and makes them available in KInventory.Items.
    ]]--
    Pointshop2.ItemsLoadedPromise = wrapPromise( function()
        return LibK.InitPostEntityPromise
        :Then( function( )
            KInventory.loadAllItems( )
        end )
        :Then( function( )
            KLogf( 4, "[Pointshop2] All Items were loaded by KInv" )
        end, function( )
            KLogf( 1, "[Pointshop2] Could not load item bases" )
        end )
    end )

    --[[
        # Connect to and initialize database
        This initializes all LibK Models, creating tables and magic functions
        after modules have been loaded.
    ]]--
    Pointshop2.StageOneFinishedPromise = WhenAllFinished{
        Pointshop2.ModulesLoadedPromise,
        Pointshop2.SettingsLoadedPromise,
        Pointshop2.DatabaseConnectedPromise,
        Pointshop2.ItemsLoadedPromise,
    }
    Pointshop2.StageOneFinishedPromise:Done( function( ) 
        KLogf( 4, "[Pointshop 2] The initial load stage has completed.")
    end )

    --[[
        # Load all module items from the database
        This initializes all LibK Models, creating tables and magic functions
        after modules have been loaded.
    ]]--
    Pointshop2.ModuleItemsLoadedPromise = wrapPromise( function( )
        return Pointshop2.StageOneFinishedPromise
        :Then( function( )
            KLogf( 4, "[Pointshop2] Loading Module items" )
            return Pointshop2Controller:getInstance( ):loadModuleItems( )
        end )
        :Then( function( )
            KLogf( 4, "[Pointshop2] Loaded Module items from DB" )
        end, function( errid, err )
            KLogf( 2, "[Pointshop2] Couldn't load persistent items: %i - %s", errid, err )
        end )
    end )

    --[[
        # Create the dynamics resource and initialize the tree
        This creates the dynamics resource that is sent to the client.
        It also populates the Category tree.
    ]]--
    Pointshop2.DynamicsLoadedPromise = wrapPromise( function( )
        return Pointshop2.ModuleItemsLoadedPromise
        :Then( function( )
            return Pointshop2Controller:getInstance( ):loadDynamicInfo( )
        end )
    end )

    --[[
        # Create the outfits resource
        This creates the outfits resource that is sent to the client.
    ]]--
    Pointshop2.OutfitsLoadedPromise = wrapPromise( function ( )
        return Pointshop2.DatabaseConnectedPromise:Then( function( )
            return Pointshop2Controller:getInstance( ):loadOutfits( )
        end ):Then( function( )
            return LibK.GLib.Resources.Resources["Pointshop2/outfits"]
        end )
    end )

    Pointshop2.BootstrappedPromise = WhenAllFinished{
        Pointshop2.DynamicsLoadedPromise,
        Pointshop2.ModuleItemsLoadedPromise,
        Pointshop2.OutfitsLoadedPromise
    }
end

Pointshop2.Bootstrap( )