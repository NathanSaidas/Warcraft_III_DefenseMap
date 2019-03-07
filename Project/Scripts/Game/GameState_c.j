function GameState_PreInit takes nothing returns nothing
    call DebugLog(LOG_INFO, "GameState_PreInit")

    call PlayerMgr_PreInit()
    call UnitMgr_PreInit()
    call GameDirector_PreInit()
    call Component_PreInit()

    call GameState_HeroPick_PreInit()
    call GameState_Playing_PreInit()
endfunction

function GameState_Init takes nothing returns nothing
    call DebugLog(LOG_INFO, "GameState_Init")

    call GameState_HeroPick_Init()

    call Thread_RegisterDriver("Game_Update", function Game_Update)
    call Thread_StartDriver("Game_Update")
endfunction