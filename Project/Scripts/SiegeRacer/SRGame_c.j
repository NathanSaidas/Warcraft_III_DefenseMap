function SiegeRacer_OnLoadingDone takes nothing returns nothing
    call SetDestructableInvulnerableBJ( udg_SC_GateBack, true )
    call SetDestructableInvulnerableBJ( udg_SC_GateFront, true )
    call ModifyGateBJ( bj_GATEOPERATION_CLOSE, udg_SC_GateBack )
    call ModifyGateBJ( bj_GATEOPERATION_CLOSE, udg_SC_GateFront )
endfunction

function SiegeRacer_OnGameStart takes nothing returns nothing
    call ModifyGateBJ( bj_GATEOPERATION_OPEN, udg_SC_GateBack )
    call ModifyGateBJ( bj_GATEOPERATION_OPEN, udg_SC_GateFront )
    call SRGameDirector_SpawnAIPlayerUnits()
endfunction

function SiegeRacer_TransitionOut takes nothing returns nothing
    if gGameState == GS_LOADING then
        call SiegeRacer_OnLoadingDone()
        call GameState_Loading_TransitionOut()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "SRGame_c: GS_LOADING->TransitionOut()")
        endif
    elseif gGameState == GS_HERO_PICK then
        call GameState_HeroPick_TransitionOut()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "SRGame_c: GS_HERO_PICK->TransitionOut()")
        endif
    elseif gNextGameState == GS_PLAYING then
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "SRGame_c: GS_PLAYING->TransitionOut()")
        endif
    endif
endfunction

function SiegeRacer_TransitionIn takes nothing returns nothing
    if gNextGameState == GS_LOADING then
        call GameState_Loading_TransitionIn()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "SRGame_c: GS_LOADING->TransitionIn()")
        endif
    elseif gNextGameState == GS_HERO_PICK then
        call GameState_HeroPick_TransitionIn()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "SRGame_c: GS_HERO_PICK->TransitionIn()")
        endif
    elseif gNextGameState == GS_PLAYING then
        call SiegeRacer_OnGameStart()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "SRGame_c: GS_PLAYING->TransitionIn()")
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
        elseif gGameState == GS_PLAYING then

        endif

        call Sleep(GAME_DELTA)
    endloop
endfunction

function SiegeRacer_UpdateScoreboardPlayer takes integer row, integer playerData returns nothing
    local integer component = INVALID

    if IsNull(playerData) or not PlayerData_IsHumanPlaying(playerData) then
        call DisplayBoard_SetTextItem(MULTIBOARD_GAME, 0, row + 1, 15.0, "None", MULTIBOARD_COLOR_WHITE)
        call DisplayBoard_SetTextItem(MULTIBOARD_GAME, 1, row + 1, 4.0, "--", MULTIBOARD_COLOR_WHITE)
        call DisplayBoard_SetTextItem(MULTIBOARD_GAME, 2, row + 1, 6.0, "--", MULTIBOARD_COLOR_WHITE) 
    else
        set component = PlayerData_GetComponent(playerData, TYPE_ID_SRPLAYER_COMPONENT)

        call DisplayBoard_SetTextItem(MULTIBOARD_GAME, 0, row + 1, 15.0, PlayerData_GetName(playerData), MULTIBOARD_COLOR_WHITE)
        if not IsNull(component) then
            call DisplayBoard_SetTextItem(MULTIBOARD_GAME, 1, row + 1, 4.0, I2S(LoadInteger(gObject, component, SRPlayerComponent_mLapsComplete)), MULTIBOARD_COLOR_WHITE)
            call DisplayBoard_SetTextItem(MULTIBOARD_GAME, 2, row + 1, 6.0, I2S(LoadInteger(gObject, component, SRPlayerComponent_mCheckPointIndex)), MULTIBOARD_COLOR_WHITE) 
        else
            call DisplayBoard_SetTextItem(MULTIBOARD_GAME, 1, row + 1, 4.0, "-NULL-", MULTIBOARD_COLOR_WHITE)
            call DisplayBoard_SetTextItem(MULTIBOARD_GAME, 2, row + 1, 6.0, "-NULL-", MULTIBOARD_COLOR_WHITE) 
        endif
    endif
endfunction

function SiegeRacer_UpdateScoreboard takes nothing returns nothing
    local integer mUpdateThread = Thread_GetDriver("SiegeRacer_UpdateScoreboard")
    local integer numPlayers = 0
    local integer currentPlayer = INVALID
    local integer i = 0

    // <player> <lap> <check point>

    call DisplayBoard_Create(MULTIBOARD_GAME, 1, 3, "Scoreboard")

    call DisplayBoard_SetRowCount(MULTIBOARD_GAME, 1)
    call DisplayBoard_SetTextItem(MULTIBOARD_GAME, 0, 0, 15.0, "Player", MULTIBOARD_COLOR_TITLE_YELLOW)
    call DisplayBoard_SetTextItem(MULTIBOARD_GAME, 1, 0, 4.0, "Lap", MULTIBOARD_COLOR_TITLE_YELLOW)
    call DisplayBoard_SetTextItem(MULTIBOARD_GAME, 2, 0, 6.0, "Checkpoint", MULTIBOARD_COLOR_TITLE_YELLOW)

    call DisplayBoard_Show(MULTIBOARD_GAME, true)
    call DisplayBoard_Refresh()

    loop
        call Thread_UpdateTick(mUpdateThread)

        if DisplayBoard_GetCurrent() == MULTIBOARD_GAME then
            set numPlayers = PlayerMgr_gPlayers_mSize
            set i = 0
            call DisplayBoard_SetRowCount(MULTIBOARD_GAME, 1 + numPlayers)

            loop
                exitwhen i >= numPlayers
                call SiegeRacer_UpdateScoreboardPlayer(i, PlayerMgr_FindPlayerData(i))
                set i = i + 1
            endloop
            call DisplayBoard_Refresh()
        endif

        call Sleep(GAME_DELTA)
    endloop
endfunction

function SiegeRacer_UpdateDirector takes nothing returns nothing
    local integer mUpdateThread = Thread_GetDriver("SiegeRacer_UpdateDirector")

    loop
        call Thread_UpdateTick(mUpdateThread)
        call SRGameDirector_UpdateAIPlayerUnits()
        call Sleep(GAME_DELTA)
    endloop
endfunction

function SiegeRacer_OnCheckpointEnter takes unit u, integer index returns nothing
    local integer unitData = GetUnitId(u)
    local integer playerData = INVALID
    local integer component = INVALID
    call DebugLog(LOG_INFO, "SRGame_c: OnCheckpointEnter: UnitData=" + I2S(unitData) + " -- Index=" + I2S(index))

    if IsNull(unitData) then
        call DebugLog(LOG_ERROR, "SRGame_c: Failed to update checkpoint for unit, missing UnitData.")
        return
    endif

    set playerData = LoadInteger(gObject, unitData, UnitData_mPlayerData)
    if IsNull(playerData) then
        return
    endif

    set component = PlayerData_GetComponent(playerData, TYPE_ID_SRPLAYER_COMPONENT)
    if IsNull(component) then
        return
    endif

    call SRPlayerComponent_OnCheckpointEnter(component, index)
endfunction

function SiegeRacer_OnCheckpoint0 takes nothing returns nothing
    call SiegeRacer_OnCheckpointEnter(GetEnteringUnit(), 0)
endfunction
function SiegeRacer_OnCheckpoint1 takes nothing returns nothing
    call SiegeRacer_OnCheckpointEnter(GetEnteringUnit(), 1)
endfunction
function SiegeRacer_OnCheckpoint2 takes nothing returns nothing
    call SiegeRacer_OnCheckpointEnter(GetEnteringUnit(), 2)
endfunction
function SiegeRacer_OnCheckpoint3 takes nothing returns nothing
    call SiegeRacer_OnCheckpointEnter(GetEnteringUnit(), 3)
endfunction
function SiegeRacer_OnCheckpoint4 takes nothing returns nothing
    call SiegeRacer_OnCheckpointEnter(GetEnteringUnit(), 4)
endfunction
function SiegeRacer_OnCheckpoint5 takes nothing returns nothing
    call SiegeRacer_OnCheckpointEnter(GetEnteringUnit(), 5)
endfunction

function SiegeRacer_RegisterCheckpoint takes rect area, code callback, integer index returns nothing
    local trigger trig = CreateTrigger()
    call TriggerRegisterEnterRectSimple(trig, area)
    call TriggerAddAction(trig, callback)
    set trig = null
    set SRGame_gCheckpoints[index] = area
endfunction

function SiegeRacer_RegisterCheckpoints takes nothing returns nothing
    call SiegeRacer_RegisterCheckpoint(gg_rct_srCheckpoint0, function SiegeRacer_OnCheckpoint0, 0)
    call SiegeRacer_RegisterCheckpoint(gg_rct_srCheckpoint1, function SiegeRacer_OnCheckpoint1, 1)
    call SiegeRacer_RegisterCheckpoint(gg_rct_srCheckpoint2, function SiegeRacer_OnCheckpoint2, 2)
    call SiegeRacer_RegisterCheckpoint(gg_rct_srCheckpoint3, function SiegeRacer_OnCheckpoint3, 3)
    call SiegeRacer_RegisterCheckpoint(gg_rct_srCheckpoint4, function SiegeRacer_OnCheckpoint4, 4)
    call SiegeRacer_RegisterCheckpoint(gg_rct_srCheckpoint5, function SiegeRacer_OnCheckpoint5, 5)

    set SRPlayerComponent_gMaxCheckPoint = 6
endfunction

function SiegeRacer_RegisterPlayerComponents takes nothing returns nothing
    local integer i = 0
    local integer playerData = INVALID

    loop
        exitwhen i >= PlayerMgr_gPlayers_mSize
        set playerData = PlayerMgr_gPlayers[i]
        if not IsNull(playerData) then
            call PlayerData_AddComponent(playerData, SRPlayerComponent_Create())
        endif
        set i = i +1
    endloop
endfunction

// todo: 
//  -- We need to get a win condition (a lap is completed once all check points have been reached.)
function SiegeRacer_Update takes nothing returns nothing
    local integer mUpdateThread = Thread_GetDriver("SiegeRacer_Update")
    local integer mStateThread = INVALID
    local integer mScoreboardThread = INVALID
    local integer mUpdateDirectorThread = INVALID

    call Thread_RegisterDriver("SiegeRacer_UpdateState", function SiegeRacer_UpdateState)
    set mStateThread = Thread_GetDriver("SiegeRacer_UpdateState")

    call Thread_RegisterDriver("SiegeRacer_UpdateScoreboard", function SiegeRacer_UpdateScoreboard)
    set mScoreboardThread = Thread_GetDriver("SiegeRacer_UpdateScoreboard")

    call Thread_RegisterDriver("SiegeRacer_UpdateDirector", function SiegeRacer_UpdateDirector)
    set mUpdateDirectorThread = Thread_GetDriver("SiegeRacer_UpdateDirector")

    call SiegeRacer_RegisterCheckpoints()
    call Sleep(GAME_DELTA)
    call Thread_UpdateTick(mUpdateThread)
    call SiegeRacer_RegisterPlayerComponents()

    loop
        call Thread_UpdateTick(mUpdateThread)
        if not Thread_IsRunning(mStateThread) then
            call Thread_StartDriver("SiegeRacer_UpdateState")
        endif

        if not Thread_IsRunning(mScoreboardThread) then
            call Thread_StartDriver("SiegeRacer_UpdateScoreboard")
        endif

        if not Thread_IsRunning(mUpdateDirectorThread) then
            call Thread_StartDriver("SiegeRacer_UpdateDirector")
        endif
        call Sleep(GAME_DELTA)
    endloop
endfunction