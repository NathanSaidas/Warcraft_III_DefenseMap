function GameState_PreInit takes nothing returns nothing
    call DebugLog(LOG_INFO, "GameState_PreInit")

    call PlayerMgr_PreInit()
    call UnitMgr_PreInit()
    if CONFIG_DEFENSE_MAP then
        call GameDirector_PreInit()
    endif
    call Component_PreInit()

    if CONFIG_DEFENSE_MAP then
        call GameState_HeroPick_PreInit()
        call GameState_Playing_PreInit()
    endif

    if CONFIG_SIEGE_RACER_MAP then
        call GameState_HeroPick_PreInit()
    endif
endfunction

function GameState_Init takes nothing returns nothing
    call DebugLog(LOG_INFO, "GameState_Init")

    if CONFIG_DEFENSE_MAP then
        call GameState_HeroPick_Init()

        call Thread_RegisterDriver("Game_Update", function Game_Update)
        call Thread_StartDriver("Game_Update")
    endif

    if CONFIG_SIEGE_RACER_MAP then
        call GameState_HeroPick_Init()

        call Thread_RegisterDriver("SiegeRacer_Update", function SiegeRacer_Update)
        call Thread_StartDriver("SiegeRacer_Update")
    endif
endfunction