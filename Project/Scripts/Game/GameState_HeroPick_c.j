function GameState_HeroPick_RegisterHeroPicker takes rect area, code callback returns nothing
    local trigger mTrigger = CreateTrigger()
    call TriggerRegisterEnterRectSimple(mTrigger, area)
    call TriggerAddAction(mTrigger, callback)

    set GameState_HeroPick_gTriggers[GameState_HeroPick_gCount] = mTrigger
    set GameState_HeroPick_gCount = GameState_HeroPick_gCount + 1
endfunction

function GameState_HeroPick_SelectHero takes string typeName, unit enteringUnit returns nothing
    local integer playerData = INVALID
    local integer unitData = INVALID
    local integer unitTypeData = INVALID
    local integer mHero = INVALID
    local integer mPlayerId = INVALID

    set unitTypeData = UnitMgr_FindUnitTypeByString(typeName)
    if IsNull(unitTypeData) then
        call DebugLog(LOG_ERROR, "GameState_HeroPick_c: Bad Hero pick, typeName=" + typeName)
        return
    endif

    set unitData = GetUnitId(enteringUnit)
    if IsNull(unitData) then
        call DebugLog(LOG_ERROR, "GameState_HeroPick_c: Bad Hero pick, entering unit has no UnitData")
        return
    endif

    set playerData = LoadInteger(gObject, unitData, UnitData_mPlayerData)
    if IsNull(playerData) then
        call DebugLog(LOG_ERROR, "GameState_HeroPick_c: Bad Hero pick, UnitData has no PlayerData")
        return
    endif

    if not IsNull(LoadInteger(gObject, playerData, PlayerData_mHero)) then
        call DebugLog(LOG_ERROR, "GameState_HeroPick_c: Bad Hero pick, player already has a hero!")
        return
    endif

    if unitData != LoadInteger(gObject, playerData, PlayerData_mHeroPicker) then
        call DebugLog(LOG_ERROR, "GameState_HeroPick_c: Bad Hero pick, unit type is not HeroPicker!")
        return
    endif

    set mHero = UnitMgr_CreateUnit(unitTypeData, playerData, GameState_HeroPick_gHeroSpawnX, GameState_HeroPick_gHeroSpawnY)
    call SaveInteger(gObject, playerData, PlayerData_mHero, mHero)

    call UnitMgr_DestroyUnit(LoadInteger(gObject, playerData, PlayerData_mHeroPicker))
    call SaveInteger(gObject, playerData, PlayerData_mHeroPicker, INVALID)

    set mPlayerId = LoadInteger(gObject, playerData, PlayerData_mPlayerId)
    call SetPlayerStateBJ(Player(mPlayerId), PLAYER_STATE_RESOURCE_GOLD, 500)
    call SetPlayerStateBJ(Player(mPlayerId), PLAYER_STATE_RESOURCE_LUMBER, 0)

endfunction

function GameState_HeroPick_CreateHeroPicker takes integer playerData returns nothing
    local integer mHeroPicker = LoadInteger(gObject, playerData, PlayerData_mHeroPicker)
    if not IsNull(mHeroPicker) then
        return
    endif
    set mHeroPicker = UnitMgr_CreateUnit(GameState_HeroPick_gHeroPickerType, playerData, GameState_HeroPick_gHeroPickerSpawnX, GameState_HeroPick_gHeroPickerSpawnY)
    if IsNull(mHeroPicker) then
        call DebugLog(LOG_ERROR, "GameState_HeroPick_c: Failed to make hero picker!")
        return
    endif
    call SaveInteger(gObject, playerData, PlayerData_mHeroPicker, mHeroPicker)
endfunction

function GameState_HeroPick_CmdRepick takes nothing returns nothing
    local player eventPlayer = null 
    local integer eventPlayerData = INVALID
    local integer mHero = INVALID
    if gGameState != GS_HERO_PICK then
        call DebugLog(LOG_INFO, "GameState_HeroPick_c: Cannot repick! Invalid state!")
        return
    endif

    set eventPlayer = Cmd_GetEventPlayer()
    set eventPlayerData = PlayerMgr_FindPlayerData(GetPlayerId(eventPlayer))
    set eventPlayer = null
    if IsNull(eventPlayerData) then
        call DebugLog(LOG_ERROR, "GameState_HeroPick_c: Repick failed, unknown player!")
        return
    endif

    set mHero = LoadInteger(gObject, eventPlayerData, PlayerData_mHero)
    if not IsNull(mHero) then
        call UnitMgr_DestroyUnit(mHero)
        call SaveInteger(gObject, eventPlayerData, PlayerData_mHero, INVALID)
    endif
    call GameState_HeroPick_CreateHeroPicker(eventPlayerData)
endfunction

function GameState_HeroPick_SelectDebugHero takes nothing returns nothing
    call GameState_HeroPick_SelectHero("DebugHero", GetEnteringUnit())
endfunction

function GameState_HeroPick_SelectCaster takes nothing returns nothing
    call GameState_HeroPick_SelectHero("Caster", GetEnteringUnit())
endfunction

function GameState_HeroPick_PreInit takes nothing returns nothing
    // Initialize starting locations:

    set GameState_HeroPick_gHeroPickerSpawnX = GetRectCenterX(gg_rct_HeroVision)
    set GameState_HeroPick_gHeroPickerSpawnY = GetRectCenterY(gg_rct_HeroVision)
    set GameState_HeroPick_gHeroSpawnX = GetRectCenterX(gg_rct_HeroPickSpawn)
    set GameState_HeroPick_gHeroSpawnY = GetRectCenterY(gg_rct_HeroPickSpawn)
    set GameState_HeroPick_gHeroPickerType = UnitMgr_FindUnitTypeByString("HeroPicker")
    call GameState_HeroPick_RegisterHeroPicker(gg_rct_HeroPickDebugHero, function GameState_HeroPick_SelectDebugHero)
    call GameState_HeroPick_RegisterHeroPicker(gg_rct_HeroPickCaster, function GameState_HeroPick_SelectCaster)

endfunction

function GameState_HeroPick_Init takes nothing returns nothing
    call Cmd_RegisterHandler("-repick", function GameState_HeroPick_CmdRepick)
endfunction

function GameState_HeroPick_TransitionOut takes nothing returns nothing
    // Give player's who are playing a random hero.
    call DestroyTimerDialog(GameState_HeroPick_gTimerDialog)
    call DestroyTimer(GameState_HeroPick_gTimer)
    set GameState_HeroPick_gTimer = null
    set GameState_HeroPick_gTimerDialog = null
endfunction

function GameState_HeroPick_TransitionIn takes nothing returns nothing
    // foreach Player
    //   Drop items from existing player owned units/hero's
    //   Destroy existing player owned units/hero's
    //   Reset player resources
    local integer i = 0
    local integer current = 0

    
    // CreateHeroPicker if not already created
    loop 
        exitwhen i >= PlayerMgr_gMaxPlayer
        set current = PlayerMgr_gPlayers[i]
        if PlayerData_IsHumanPlaying(current) then
            call GameState_HeroPick_CreateHeroPicker(current)
        endif
        set i = i + 1
    endloop

    set GameState_HeroPick_gTimer = CreateTimer()
    if CONFIG_GAME_FAST_START then
        call TimerStart(GameState_HeroPick_gTimer, 15.0, false, null)
    else
        call TimerStart(GameState_HeroPick_gTimer, 120.0, false, null)
    endif
    set GameState_HeroPick_gTimerDialog = CreateTimerDialog(GameState_HeroPick_gTimer)
    call TimerDialogSetTitle(GameState_HeroPick_gTimerDialog, "Hero Pick:")
    call TimerDialogDisplay(GameState_HeroPick_gTimerDialog, true)
endfunction

function GameState_HeroPick_Update takes nothing returns nothing
    // Wait a brief period then advance to GS_PLAYING and spawn waves 
    if TimerGetRemaining(GameState_HeroPick_gTimer) <= 0.0 then
        set gNextGameState = GS_PLAYING
    endif
endfunction