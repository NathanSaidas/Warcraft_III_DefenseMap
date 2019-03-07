
function GameDirector_EnrageWaveUnit takes nothing returns nothing
    // todo: 
    call DebugLog(LOG_INFO, "GameDirector_c: TODO: EnrageWaveUnit")
endfunction

function GameDirector_SpawnWaveUnit takes integer spawnIndex returns nothing
    local integer playerData = PlayerMgr_gEnemyForcePlayer
    local integer unitTypeData = GameDirector_gCurrentUnitType
    local real x = GameDirector_gSpawnX[spawnIndex]
    local real y = GameDirector_gSpawnY[spawnIndex]
    local integer index = 0
    local integer component = INVALID
    loop
        exitwhen index >= GameDirector_gMaxUnit
        if IsNull(GameDirector_gWaveUnits[index]) then
            set GameDirector_gWaveUnits[index] = UnitMgr_CreateUnit(unitTypeData, playerData, x, y)

            set component = RunToCityComponent_Create()
            if not IsNull(component) then
                call UnitData_AddComponent(GameDirector_gWaveUnits[index], component)
            else
                call DebugLog(LOG_ERROR, "GameDirector_c: Failed to create RunToCityComponent")
            endif

            set component = MonitorUnitLifeComponent_Create()
            if not IsNull(component) then
                call UnitData_AddComponent(GameDirector_gWaveUnits[index], component)
            else
                call DebugLog(LOG_ERROR, "GameDirector_c: Failed to create MonitorUnitLifeComponent")
            endif

            set GameDirector_gWaveUnits_mSize = GameDirector_gWaveUnits_mSize + 1
            return
        endif
        set index = index + 1
    endloop

endfunction

function GameDirector_SpawnWaveUnits takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= GameDirector_gSpawnPointCount
        if GameDirector_gWaveUnits_mSize >= GameDirector_gMaxUnit then
            call GameDirector_EnrageWaveUnit()
        else
            call GameDirector_SpawnWaveUnit(i)
        endif

        set i = i + 1
    endloop
endfunction

function GameDirector_BeginWaveSpawn takes nothing returns nothing
    local integer mSpawnWaveData = GameDirector_gSpawnWaveData[GameDirector_gCurrentSpawnWave]
    set GameDirector_gCurrentSpawnCount = LoadInteger(gObject, mSpawnWaveData, SpawnWaveData_mSpawnCount)
    set GameDirector_gCurrentSpawnDelay = LoadReal(gObject, mSpawnWaveData, SpawnWaveData_mSpawnDelay)
    set GameDirector_gCurrentUnitType = LoadInteger(gObject, mSpawnWaveData, SpawnWaveData_mUnitType)
    set GameDirector_gCurrentBossWave = LoadBoolean(gObject, mSpawnWaveData, SpawnWaveData_mIsBoss)

    if GameDirector_gSpawnTimer == null then
        set GameDirector_gSpawnTimer = CreateTimer()
    endif
    call TimerStart(GameDirector_gSpawnTimer, GameDirector_gCurrentSpawnDelay, false, null)
endfunction

function GameDirector_QueueWave takes nothing returns nothing
    if GameDirector_gWaveTimer == null then
        set GameDirector_gWaveTimer = CreateTimer()
    endif
    if GameDirector_gWaveTimerDialog == null then
        set GameDirector_gWaveTimerDialog = CreateTimerDialog(GameDirector_gWaveTimer)
    endif

    call TimerStart(GameDirector_gWaveTimer, 15.0, false, null)
    call TimerDialogSetTitle(GameDirector_gWaveTimerDialog, "Next Wave:")
    call TimerDialogDisplay(GameDirector_gWaveTimerDialog, true)
endfunction

function GameDirector_SetWaveIndex takes integer index returns nothing
    set GameDirector_gCurrentSpawnWave = MinI(index, GameDirector_gSpawnWaveData_mSize - 1)
endfunction

function GameDirector_GetWaveIndex takes nothing returns integer
    return GameDirector_gCurrentSpawnWave
endfunction

function GameDirector_Start takes nothing returns nothing
    if GameDirector_gWaveUnits_mSize > 0 then
        call DebugLog(LOG_ERROR, "GameDirector_c: GameDirector_Start called too early! Leaking units...")
    endif

    set GameDirector_gRunning = true
    call GameDirector_SetWaveIndex(0)
    call GameDirector_QueueWave()
    call GameDirector_BeginWaveSpawn()
endfunction

function GameDirector_Stop takes nothing returns nothing
    set GameDirector_gRunning = false
endfunction

function GameDirector_Update takes nothing returns nothing
    local integer i = 0
    if not GameDirector_gRunning then
        loop
            exitwhen i >= GameDirector_gMaxUnit
            exitwhen GameDirector_gWaveUnits_mSize == 0

            if not IsNull(GameDirector_gWaveUnits[i]) then
                call UnitMgr_DestroyUnit(GameDirector_gWaveUnits[i])
                set GameDirector_gWaveUnits_mSize = GameDirector_gWaveUnits_mSize - 1
            endif
            set GameDirector_gWaveUnits[i] = INVALID
            set i = i + 1
        endloop

        if GameDirector_gWaveTimerDialog != null then
            call DestroyTimerDialog(GameDirector_gWaveTimerDialog)
            set GameDirector_gWaveTimerDialog = null
        endif

        if GameDirector_gWaveTimer != null then
            call DestroyTimer(GameDirector_gWaveTimer)
            set GameDirector_gWaveTimer = null
        endif

        return
    endif

    if GameDirector_gWaveTimer == null or GameDirector_gSpawnTimer == null then
        call DebugLog(LOG_ERROR, "GameDirector_c: GameDirector_Update failed, missing timer variables.")
        return
    endif

    if TimerGetRemaining(GameDirector_gWaveTimer) <= 0.0 then
        call DebugLog(LOG_INFO, "GameDirector_c: QueueWave")

        call GameDirector_SetWaveIndex(GameDirector_GetWaveIndex() + 1)
        call GameDirector_QueueWave()
        call GameDirector_BeginWaveSpawn()
    endif

    if TimerGetRemaining(GameDirector_gSpawnTimer) <= 0.0 then
        if GameDirector_gCurrentSpawnCount > 0 then
            call DebugLog(LOG_INFO, "GameDirector_c: SpawnWaveUnits")
            call GameDirector_SpawnWaveUnits()
            set GameDirector_gCurrentSpawnCount = GameDirector_gCurrentSpawnCount - 1
            call TimerStart(GameDirector_gSpawnTimer, GameDirector_gCurrentSpawnDelay, false, null)
        endif
    endif
endfunction

function GameDirector_UpdateUnits takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= GameDirector_gMaxUnit
        if not IsNull(GameDirector_gWaveUnits[i]) then
            if LoadBoolean(gObject, GameDirector_gWaveUnits[i], UnitData_mQueueDestroy) then
                call DebugLog(LOG_INFO, "DestroyWaveUnit")
                call UnitMgr_DestroyUnit(GameDirector_gWaveUnits[i])
                set GameDirector_gWaveUnits_mSize = GameDirector_gWaveUnits_mSize - 1
                set GameDirector_gWaveUnits[i] = INVALID
            else
                call UnitData_Update(GameDirector_gWaveUnits[i])
            endif
        endif
        set i = i + 1
    endloop
endfunction