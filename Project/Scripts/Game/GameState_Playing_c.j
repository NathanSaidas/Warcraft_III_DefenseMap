function GameState_Playing_OnEnterLifeTrigger takes nothing returns nothing
    local unit enteringUnit = GetTriggerUnit()
    local integer unitData = GetUnitId(enteringUnit)
    
    if not IsNull(unitData) and LoadInteger(gObject, unitData, UnitData_mPlayerData) == PlayerMgr_gEnemyForcePlayer then
        set GameState_Playing_gCurrentLives = MaxI(0, GameState_Playing_gCurrentLives - 1)
        call DebugLog(LOG_INFO, "GameState_Playing_c: Remaining Lives " + I2S(GameState_Playing_gCurrentLives))

        if GameState_Playing_gCurrentLives == 0 then
            set gNextGameState = GS_FAILED
        endif

        call UnitData_QueueDestroy(unitData)
    endif

endfunction

function GameState_Playing_PreInit takes nothing returns nothing
    set GameState_Playing_gLifeTrigger = CreateTrigger()
    call TriggerRegisterEnterRectSimple(GameState_Playing_gLifeTrigger, gg_rct_WaveTarget)
    call TriggerAddAction(GameState_Playing_gLifeTrigger, function GameState_Playing_OnEnterLifeTrigger)
endfunction

function GameState_Playing_TransitionOut takes nothing returns nothing
    call DebugLog(LOG_INFO, "GameState_Playing_c: GameDirector_Stop()")
    call GameDirector_Stop()
endfunction

function GameState_Playing_TransitionIn takes nothing returns nothing
    call DebugLog(LOG_INFO, "GameState_Playing_c: GameDirector_Start()")
    set GameState_Playing_gCurrentLives = GameState_Playing_gMaxLives
    call GameDirector_Start()
endfunction

function GameState_Playing_Update takes nothing returns nothing
    // todo: check game win/lose condition
endfunction