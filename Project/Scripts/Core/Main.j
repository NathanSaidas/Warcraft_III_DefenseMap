globals
	
endglobals

function Main_ThreadUpdate takes nothing returns nothing
    local integer driver = Thread_GetDriver("Main_ThreadUpdate")
	call Thread_UpdateTick(driver)
	call Sleep(GAME_DELTA)
	call Thread_Update(driver)
endfunction

function Main_UpdateDebug takes nothing returns nothing
    local integer driver = Thread_GetDriver("Main_UpdateDebug")
    loop
        call Thread_UpdateTick(driver)
        call Sleep(GAME_DELTA)
        call Debug_Update()
    endloop
endfunction

function Main_PreInit takes nothing returns nothing
    call DebugLog(LOG_INFO, "Main_PreInit...")
    call Object_PreInit()
    call Debug_PreInit()
    call Cmd_PreInit()
    call Thread_PreInit()
    call Thread_RegisterDriver("Main_ThreadUpdate", function Main_ThreadUpdate)
    call Thread_StartDriver("Main_ThreadUpdate")
    call Thread_RegisterDriver("Main_UpdateDebug", function Main_UpdateDebug)
    call Thread_StartDriver("Main_UpdateDebug")
    // call UnitHook_PreInit()
    // call GameRules_PreInit()
    call GameState_PreInit()
    call DebugLog(LOG_INFO, "Main_PreInit finished.")
endfunction

function Main_Init takes nothing returns nothing
    call DebugLog(LOG_INFO, "Main_Init...")
    call GameState_Init()
    // call GameRules_Init()
    // call CmdObject_Init()
    call CmdGame_Init()
    call CmdDebug_Init()
    call DebugLog(LOG_INFO, "Main_Init finished.")

    
endfunction

function Trig_Main_Actions takes nothing returns nothing    
    call Sleep(5.0) // Wait a bit so that the logging works.
    call Main_PreInit()
    call Main_Init()

    call Object_Test()
    // call Cmd_Test()
    call DebugLog(LOG_INFO, "Initialization Complete")
endfunction

//===========================================================================
function InitTrig_Main takes nothing returns nothing
    set gg_trg_Main = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Main, function Trig_Main_Actions )
endfunction

