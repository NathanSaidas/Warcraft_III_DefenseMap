function SiegeRacer_OnLoadingDone takes nothing returns nothing
    call SetDestructableInvulnerableBJ( udg_SC_GateBack, true )
    call SetDestructableInvulnerableBJ( udg_SC_GateFront, true )
    call ModifyGateBJ( bj_GATEOPERATION_CLOSE, udg_SC_GateBack )
    call ModifyGateBJ( bj_GATEOPERATION_CLOSE, udg_SC_GateFront )
endfunction

function SiegeRacer_TransitionOut takes nothing returns nothing
    if gGameState == GS_LOADING then
        call SiegeRacer_OnLoadingDone()
        call GameState_Loading_TransitionOut()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_LOADING->TransitionOut()")
        endif
    elseif gGameState == GS_HERO_PICK then
        call GameState_HeroPick_TransitionOut()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_HERO_PICK->TransitionOut()")
        endif
    endif
endfunction

function SiegeRacer_TransitionIn takes nothing returns nothing
    if gNextGameState == GS_LOADING then
        call GameState_Loading_TransitionIn()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_LOADING->TransitionIn()")
        endif
    elseif gNextGameState == GS_HERO_PICK then
        call GameState_HeroPick_TransitionIn()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_HERO_PICK->TransitionIn()")
        endif
    endif
endfunction

function SiegeRacer_UpdateState takes nothing returns nothing
    local integer mUpdateThread = Thread_GetDriver("SiegeRacer_UpdateState")

    loop
        call Thread_UpdateTick(mUpdateThread)

        // Process State Changes:
        if gGameState != gNextGameState then
            call SiegeRacer_TransitionOut()
            call SiegeRacer_TransitionIn()
            set gGameState = gNextGameState
        endif
        if gGameState == GS_LOADING then
            call GameState_Loading_Update()
        elseif gGameState == GS_HERO_PICK then
            call GameState_HeroPick_Update()
        endif

        call Sleep(GAME_DELTA)
    endloop
endfunction

function SiegeRacer_Update takes nothing returns nothing
    local integer mUpdateThread = Thread_GetDriver("SiegeRacer_Update")
    local integer mStateThread = INVALID

    call Thread_RegisterDriver("SiegeRacer_UpdateState", function SiegeRacer_UpdateState)
    set mStateThread = Thread_GetDriver("SiegeRacer_UpdateState")

    loop
        call Thread_UpdateTick(mUpdateThread)

        if not Thread_IsRunning(mStateThread) then
            call Thread_StartDriver("SiegeRacer_UpdateState")
        endif

        call Sleep(GAME_DELTA)
    endloop
endfunction