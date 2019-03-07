// This file contains private data for GameRules see GameRulesBase for public interface/members


function GameRules_Create takes nothing returns integer
    local integer self = Object_Allocate(TYPE_ID_GAME_RULES, GameRules_MAX_MEMBER)
    local trigger test = null
    if IsNull(self) then
        return INVALID
    endif
    call SaveInteger(gObject, self, GameRules_mPendingSpawns, List_Create(TYPE_ID_UNIT_DATA))
    call SaveInteger(gObject, self, GameRules_mUnitTypes, List_Create(TYPE_ID_UNIT_TYPE_DATA))
    call SaveInteger(gObject, self, GameRules_mWaveId, 0)
    call SaveInteger(gObject, self, GameRules_mWaveTypes, List_Create(TYPE_ID_UNIT_TYPE_DATA))
    call SaveInteger(gObject, self, GameRules_mSpawnPortals, List_Create(TYPE_ID_SPAWN_PORTAL))
    call SaveTimerHandle(gObject, self, GameRules_mSpawnTimer, CreateTimer())
    call SaveInteger(gObject, self, GameRules_mSpawnsRemaining, 0)
    call SaveTimerHandle(gObject, self, GameRules_mWaveTimer, CreateTimer())
    call SaveTimerDialogHandle(gObject, self, GameRules_mWaveTimerDialog, CreateTimerDialog(LoadTimerHandle(gObject, self, GameRules_mWaveTimer)))
    call SaveInteger(gObject, self, GameRules_mLives, GameRules_LIVES)
    call SaveBoolean(gObject, self, GameRules_mSpawnsEnabled, false)
    call SaveTriggerHandle(gObject, self, GameRules_mLifeTrigger, CreateTrigger())
    call SaveInteger(gObject, self, GameRules_mUnits, List_Create(TYPE_ID_UNIT_DATA))
    call SaveTimerHandle(gObject, self, GameRules_mModeTimer, null)
    call SaveInteger(gObject, self, GameRules_mPlayers, List_Create(TYPE_ID_PLAYER_DATA))

    call TimerDialogDisplay(LoadTimerDialogHandle(gObject, self, GameRules_mWaveTimerDialog), false)

    return self
endfunction

// Spawns 1 unit at each of the spawn points. The unit type is based on the current wave
function GameRules_SpawnWaveUnit takes nothing returns nothing
    local integer mWaveTypes = LoadInteger(gObject, gGameRules, GameRules_mWaveTypes)
    local integer mWaveId = LoadInteger(gObject, gGameRules, GameRules_mWaveId)
    local integer mSpawnPortals = LoadInteger(gObject, gGameRules, GameRules_mSpawnPortals)
    local integer size = List_GetSize(mWaveTypes)
    local integer waveType = List_GetObject(mWaveTypes, MinI(size-1, mWaveId))
    local integer numPortals = List_GetSize(mSpawnPortals)
    local integer i = 0
    local integer mSpawnsRemaining = LoadInteger(gObject, gGameRules, GameRules_mSpawnsRemaining)
    local integer mUnits = LoadInteger(gObject, gGameRules, GameRules_mUnits)
    local integer spawnedUnit = INVALID

    loop
        exitwhen i >= numPortals
        if List_GetSize(mUnits) < GameRules_MAX_WAVE_UNIT then
            set spawnedUnit = SpawnPortal_CreateNpc(List_GetObject(mSpawnPortals, i), waveType)
            call List_AddObject(mUnits, spawnedUnit)
            call DebugLog(LOG_INFO, "Created unit " + I2S(spawnedUnit) + ", SetWaveUnit")
            call UnitData_SetWaveUnit(spawnedUnit, true)
        else
            call DebugLog(LOG_INFO, "TODO: Buff unit with 'enrage'")
        endif

        set i = i + 1
    endloop
    call SaveInteger(gObject, gGameRules, GameRules_mSpawnsRemaining, mSpawnsRemaining - 1)
endfunction

function GameRules_QueueSpawn takes nothing returns nothing
    local integer mSpawnsRemaining = LoadInteger(gObject, gGameRules, GameRules_mSpawnsRemaining)
    call DebugLog(LOG_INFO, "GameRules_QueueSpawn: ")
    if mSpawnsRemaining > 0 then
        call TimerStart(LoadTimerHandle(gObject, gGameRules, GameRules_mSpawnTimer), GameRules_SPAWN_INTERVAL, false, null)
    endif
endfunction

function GameRules_BeginWave takes nothing returns nothing
    call DebugLog(LOG_INFO, "GameRules_BeginWave " + I2S(LoadInteger(gObject, gGameRules, GameRules_mWaveId)))
    call SaveInteger(gObject, gGameRules, GameRules_mSpawnsRemaining, GameRules_WAVE_UNIT_COUNT)
    call SaveInteger(gObject, gGameRules, GameRules_mWaveId, LoadInteger(gObject, gGameRules, GameRules_mQueuedWaveId))
    call GameRules_QueueSpawn()
endfunction

function GameRules_QueueWave takes integer waveId returns nothing
    local timer mWaveTimer = LoadTimerHandle(gObject, gGameRules, GameRules_mWaveTimer)
    local integer mWaveTypes = LoadInteger(gObject, gGameRules, GameRules_mWaveTypes)
    call TimerStart(mWaveTimer, GameRules_WAVE_TIME, false, null)
    call SaveInteger(gObject, gGameRules, GameRules_mQueuedWaveId, MinI(List_GetSize(mWaveTypes) - 1, waveId))
    set mWaveTimer = null

    call DebugLog(LOG_INFO, "GameRules_QueueWave: " + I2S(waveId))
endfunction

function GameRules_HandleLoseCondition takes nothing returns nothing
    local integer mUnits = LoadInteger(gObject, gGameRules, GameRules_mUnits)
    local integer i = 0
    local integer size = List_GetSize(mUnits)
    local integer current = INVALID

    call DebugLog(LOG_INFO, "GameRules_HandleLoseCondition")
    call SaveBoolean(gObject, gGameRules, GameRules_mSpawnsEnabled, false)
    call TimerDialogDisplay(LoadTimerDialogHandle(gObject, gGameRules, GameRules_mWaveTimerDialog), false)
    set gGameState = GS_FAILED
endfunction

function GameRules_OnEnterLifeTrigger takes nothing returns nothing
    local unit enteringUnit = GetTriggerUnit()
    local integer unitData = GetUnitId(enteringUnit)
    local integer mLives = LoadInteger(gObject, gGameRules, GameRules_mLives)

    if not IsNull(unitData) and GetOwningPlayer(enteringUnit) == Player(gGameRules_NpcPlayer) then
        set mLives = mLives - 1
        call SaveInteger(gObject, gGameRules, GameRules_mLives, mLives)
        call DebugLog(LOG_INFO, "Lost one life " + I2S(mLives) + " remaining.")
        if mLives <= 0 then
            call GameRules_HandleLoseCondition()
        endif
        call DebugLog(LOG_INFO, "OnEnterLifeTrigger->DestroyUnit")
        call GameRules_DestroyUnit(unitData)
    endif

endfunction

function GameRules_CreateHeroPickers takes nothing returns nothing
    local integer mPlayers = LoadInteger(gObject, gGameRules, GameRules_mPlayers)
    local integer i = 0
    local integer size = List_GetSize(mPlayers)
    loop
        exitwhen i >= size
        call PlayerData_CreateHeroPicker(List_GetObject(mPlayers, i))
        set i = i + 1
    endloop
endfunction

function GameRules_Update takes nothing returns nothing
    local integer driver = Thread_GetDriver("GameRules_Update")
    local integer testUnitType = GameRules_FindUnitTypeByName("TestWaveUnit")
    local integer i = 0
    local integer size = 0
    local timer mWaveTimer = LoadTimerHandle(gObject, gGameRules, GameRules_mWaveTimer)
    local timer mSpawnTimer = LoadTimerHandle(gObject, gGameRules, GameRules_mSpawnTimer)
    local timer mModeTimer = null
    local integer mUnits = LoadInteger(gObject, gGameRules, GameRules_mUnits)
    local integer mPendingSpawns = LoadInteger(gObject, gGameRules, GameRules_mPendingSpawns)
    local integer spawnedUnit = INVALID

    // Auto-Start
    // if gGameState == GS_RUNNING and not IsNull(testUnitType) then
    //     call GameRules_QueueWave(0)
    //     call SaveInteger(gObject, gGameRules, GameRules_mLives, GameRules_LIVES)
    //     call SaveBoolean(gObject, gGameRules, GameRules_mSpawnsEnabled, true)
    //     call TimerDialogDisplay(LoadTimerDialogHandle(gObject, gGameRules, GameRules_mWaveTimerDialog), true)
    //     call TimerDialogSetTitle(LoadTimerDialogHandle(gObject, gGameRules, GameRules_mWaveTimerDialog), "Wave Timer:")
    // endif

    

    loop
        call Thread_UpdateTick(driver)

        // if gGameState == GS_RUNNING and LoadBoolean(gObject, gGameRules, GameRules_mSpawnsEnabled) then
        //     if TimerGetRemaining(mWaveTimer) <= 0.0 then
        //         call GameRules_BeginWave()
        //         call GameRules_QueueWave(LoadInteger(gObject, gGameRules, GameRules_mWaveId) + 1)
        //     endif    
// 
        //     if TimerGetRemaining(mSpawnTimer) <= 0.0 and LoadInteger(gObject, gGameRules, GameRules_mSpawnsRemaining) > 0 then
        //         call GameRules_SpawnWaveUnit()
        //         call GameRules_QueueSpawn()
        //     endif
        // endif

        //if gGameState == GS_NONE then
        //    set mModeTimer = LoadTimerHandle(gObject, gGameRules, GameRules_mModeTimer)
        //    if mModeTimer == null then
        //        // Queue timer to start game!
        //        set mModeTimer = CreateTimer()
        //        call TimerStart(mModeTimer, GameRules_OPTIONS_WAIT_TIMER, false, null)
        //        call SaveTimerHandle(gObject, gGameRules, GameRules_mModeTimer, mModeTimer)
        //        call DebugLog(LOG_INFO, "QUEUE WAIT FOR OPTIONS!")
        //    elseif TimerGetRemaining(mModeTimer) <= 0.0 then
        //        // todo: Start game!
        //        //set gGameState = GS_FIRST_WAVE
        //        //call DestroyTimer(mModeTimer)
        //        //call SaveTimerHandle(gObject, gGameRules, GameRules_mModeTimer, null)
        //        //set mModeTimer = null
        //        //call DebugLog(LOG_INFO, "PICK OPTIONS!")

        //        //call GameRules_CreateHeroPickers()
        //    endif
    
        //endif

        set i = 0
        set size = List_GetSize(mPendingSpawns)
        loop
            exitwhen i >= size
            set spawnedUnit = List_GetObject(mPendingSpawns, i)
            if not IsNull(spawnedUnit) then
                call UnitData_BeginMonitor(spawnedUnit)
            endif
            set i = i + 1
        endloop
        call List_Clear(mPendingSpawns)

        call Sleep(GAME_DELTA)
    endloop
endfunction

function GameRules_RegisterUnit takes integer dataList, string name, integer id returns integer
    local integer typeData = UnitTypeData_Create(name, id)
    if IsNull(typeData) then
        call DebugLog(LOG_ERROR, "Failed to create type data for " + name)
        return typeData
    endif
    call List_AddObject(dataList, typeData)
    return typeData
endfunction

function GameRules_RegisterUnits takes nothing returns nothing
    local integer mUnitTypes = INVALID
    local integer current = INVALID
    if not SelfCheck(gGameRules, TYPE_ID_GAME_RULES, "GameRules_RegisterUnits") then
        return
    endif

    set mUnitTypes = LoadInteger(gObject, gGameRules, GameRules_mUnitTypes)
    set current = GameRules_RegisterUnit(mUnitTypes, "HeroPicker", 'h003')
    set current = GameRules_RegisterUnit(mUnitTypes, "DebugHero", 'H002')

    set current = GameRules_RegisterUnit(mUnitTypes, "TestWaveUnit", 'h000')
    set current = GameRules_RegisterUnit(mUnitTypes, "TestWaveUnit2", 'h001')
endfunction

function GameRules_RegisterSpawnPortals takes nothing returns nothing
    local integer mSpawnPortals = INVALID
    if not SelfCheck(gGameRules, TYPE_ID_GAME_RULES, "GameRules_RegisterSpawnPortals") then
        return
    endif

    set mSpawnPortals = LoadInteger(gObject, gGameRules, GameRules_mSpawnPortals)
    call List_AddObject(mSpawnPortals, SpawnPortal_Create(gg_rct_WaveSpawner0))
    call List_AddObject(mSpawnPortals, SpawnPortal_Create(gg_rct_WaveSpawner1))
    call List_AddObject(mSpawnPortals, SpawnPortal_Create(gg_rct_WaveSpawner2))
    call List_AddObject(mSpawnPortals, SpawnPortal_Create(gg_rct_WaveSpawner3))

    set gUnitData_TargetPointX = GetRectCenterX(gg_rct_WaveTarget)
    set gUnitData_TargetPointY = GetRectCenterY(gg_rct_WaveTarget)
endfunction

function GameRules_RegisterWaveUnit takes integer list, string name returns nothing
    local integer unitTypeData = GameRules_FindUnitTypeByName(name)
    if IsNull(unitTypeData) then
        call DebugLog(LOG_ERROR, "GameRules_RegisterWaveUnit failed! Missing unit type " + name)
        return
    endif
    call List_AddObject(list, unitTypeData)
endfunction

function GameRules_RegisterWaveUnits takes nothing returns nothing
    local integer mWaveTypes = INVALID
    if not SelfCheck(gGameRules, TYPE_ID_GAME_RULES, "GameRules_RegisterWaveUnits") then
        return
    endif
    set mWaveTypes = LoadInteger(gObject, gGameRules, GameRules_mWaveTypes)
    call GameRules_RegisterWaveUnit(mWaveTypes, "TestWaveUnit")
    call GameRules_RegisterWaveUnit(mWaveTypes, "TestWaveUnit2")
endfunction

function GameRules_RegisterLifeTrigger takes nothing returns nothing
    local trigger mLifeTrigger = LoadTriggerHandle(gObject, gGameRules, GameRules_mLifeTrigger)
    call TriggerRegisterEnterRectSimple( mLifeTrigger, gg_rct_WaveTarget )
    call TriggerAddAction( mLifeTrigger, function GameRules_OnEnterLifeTrigger )
endfunction

function GameRules_CreateHero takes integer triggeringUnit, string heroType returns nothing
    local integer playerData = INVALID
    local integer unitTypeData = INVALID
    local real x = 0.0
    local real y = 0.0
    local integer createdUnit = INVALID
    if IsNull(triggeringUnit) then
        return
    endif
    set playerData = UnitData_GetPlayerData(triggeringUnit)
    set unitTypeData = GameRules_FindUnitTypeByName(heroType)
    if IsNull(playerData) or IsNull(unitTypeData) then
        return
    endif

    // Bug Fix: Avoid creating multiple heros when entering 2 regions at the same time
    if IsNull(PlayerData_GetHeroPicker(playerData)) then
        return
    endif

    
    
endfunction
// 
// function Private_CreateDebugHero takes nothing returns nothing
// 
// endfunction
// 
// function GameRules_RegisterHeroPicker takes string heroTypeName, rect rct returns nothing
// 
// endfunction

function GameRules_RegisterHeroPicking takes nothing returns nothing
    
endfunction

function GameRules_RegisterPlayers takes nothing returns nothing
    local integer mPlayers = LoadInteger(gObject, gGameRules, GameRules_mPlayers)
    local integer i = 0
    local player p = null
    local integer playerData = INVALID

    set gPickerSpawnX = GetRectCenterX(gg_rct_HeroVision)
    set gPickerSpawnY = GetRectCenterY(gg_rct_HeroVision)

    loop
        exitwhen i >= bj_MAX_PLAYERS
        set p = Player(i)
        if GetPlayerController(p) == MAP_CONTROL_USER then
            set playerData = PlayerData_Create(GetPlayerId(p))
            call List_AddObject(mPlayers, playerData)
            call CreateFogModifierRectBJ(true, p, FOG_OF_WAR_VISIBLE, gg_rct_HeroVision)
        endif
        set playerData = INVALID
        set p = null
        set i = i + 1
    endloop
endfunction

function GameRules_PreInit takes nothing returns nothing
    set gGameRules = GameRules_Create()
    // call GameRules_RegisterLifeTrigger()
    // call GameRules_RegisterUnits()
    // call GameRules_RegisterSpawnPortals()
    // call GameRules_RegisterWaveUnits()
    // call GameRules_RegisterPlayers()
endfunction

function GameRules_Init takes nothing returns nothing
    call Thread_RegisterDriver("GameRules_Update", function GameRules_Update)
    // call Thread_StartDriver("GameRules_Update")
endfunction