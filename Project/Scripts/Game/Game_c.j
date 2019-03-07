
function Game_TransitionOut takes nothing returns nothing
    if gGameState == GS_LOADING then
        call GameState_Loading_TransitionOut()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_LOADING->TransitionOut()")
        endif
    elseif gGameState == GS_HERO_PICK then
        call GameState_HeroPick_TransitionOut()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_HERO_PICK->TransitionOut()")
        endif
    elseif gGameState == GS_PLAYING then
        call GameState_Playing_TransitionOut()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_PLAYING->TransitionOut()")
        endif
    elseif gGameState == GS_FAILED then
        call GameState_Failed_TransitionOut()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_FAILED->TransitionOut()")
        endif
    elseif gGameState == GS_SUCCESS then
        call GameState_Success_TransitionOut()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_SUCCESS->TransitionOut()")
        endif
    endif
endfunction

function Game_TransitionIn takes nothing returns nothing
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
    elseif gNextGameState == GS_PLAYING then
        call GameState_Playing_TransitionIn()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_PLAYING->TransitionIn()")
        endif
    elseif gNextGameState == GS_FAILED then
        call GameState_Failed_TransitionIn()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_FAILED->TransitionIn()")
        endif
    elseif gNextGameState == GS_SUCCESS then
        call GameState_Success_TransitionIn()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_SUCCESS->TransitionIn()")
        endif
    endif
endfunction

function Game_UpdateState takes nothing returns nothing
    local integer mUpdateThread = Thread_GetDriver("Game_UpdateState")

    loop
        call Thread_UpdateTick(mUpdateThread)

        // Process State Changes:
        if gGameState != gNextGameState then
            call Game_TransitionOut()
            call Game_TransitionIn()
            set gGameState = gNextGameState
        endif
        if gGameState == GS_LOADING then
            call GameState_Loading_Update()
        elseif gGameState == GS_HERO_PICK then
            call GameState_HeroPick_Update()
        elseif gGameState == GS_PLAYING then
            call GameState_Playing_Update()
        elseif gGameState == GS_FAILED then
            call GameState_Failed_Update()
        elseif gGameState == GS_SUCCESS then
            call GameState_Success_Update()
        endif
        call Sleep(GAME_DELTA)
    endloop
endfunction 

function Game_DirectorUpdate takes nothing returns nothing
    local integer mUpdateThread = Thread_GetDriver("Game_DirectorUpdate")

    loop
        call Thread_UpdateTick(mUpdateThread)
        call GameDirector_Update()
        call Sleep(GAME_DELTA)
    endloop
endfunction

function Game_DirectorUnitUpdate takes nothing returns nothing
    local integer mUpdateThread = Thread_GetDriver("Game_DirectorUnitUpdate")
    loop
        call Thread_UpdateTick(mUpdateThread)
        call GameDirector_UpdateUnits()
        call Sleep(GAME_DELTA)
    endloop
endfunction

function Game_PlayerHeroUpdate takes nothing returns nothing
    local integer mUpdateThread = Thread_GetDriver("Game_PlayerHeroUpdate")
    loop
        call Thread_UpdateTick(mUpdateThread)
        call PlayerMgr_UpdateHeroes()
        call Sleep(GAME_DELTA)
    endloop 
endfunction

function Game_Update takes nothing returns nothing
    local integer mUpdateThread = Thread_GetDriver("Game_Update")
    local integer mStateThread = INVALID
    local integer mDirectorThread = INVALID
    local integer mDirectorUnitUpdateThread = INVALID
    local integer mPlayerHeroUpdateThread = INVALID
    
    call Thread_RegisterDriver("Game_UpdateState", function Game_UpdateState)
    set mStateThread = Thread_GetDriver("Game_UpdateState")

    call Thread_RegisterDriver("Game_DirectorUpdate", function Game_DirectorUpdate)
    set mDirectorThread = Thread_GetDriver("Game_DirectorUpdate")

    call Thread_RegisterDriver("Game_DirectorUnitUpdate", function Game_DirectorUnitUpdate)
    set mDirectorUnitUpdateThread = Thread_GetDriver("Game_DirectorUnitUpdate")

    call Thread_RegisterDriver("Game_PlayerHeroUpdate", function Game_PlayerHeroUpdate)
    set mPlayerHeroUpdateThread = Thread_GetDriver("Game_PlayerHeroUpdate")

    loop
        call Thread_UpdateTick(mUpdateThread)
        
        // Try and keep threads active
        if not Thread_IsRunning(mStateThread) then
            call Thread_StartDriver("Game_UpdateState")
        endif

        if not Thread_IsRunning(mDirectorThread) then
            call Thread_StartDriver("Game_DirectorUpdate")
        endif

        if not Thread_IsRunning(mDirectorUnitUpdateThread) then
            call Thread_StartDriver("Game_DirectorUnitUpdate")
        endif

        if not Thread_IsRunning(mPlayerHeroUpdateThread) then
            call Thread_StartDriver("Game_PlayerHeroUpdate")
        endif

        call Sleep(GAME_DELTA)
    endloop
endfunction