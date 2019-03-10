function GameDirector_RegisterWave takes string typeName, boolean isBossWave, integer spawnCount, real spawnDelay returns nothing
    local integer data = SpawnWaveData_Create()
    call SaveInteger(gObject, data, SpawnWaveData_mSpawnCount, spawnCount)
    call SaveReal(gObject, data, SpawnWaveData_mSpawnDelay, spawnDelay)
    call SaveInteger(gObject, data, SpawnWaveData_mUnitType, UnitMgr_FindUnitTypeByString(typeName))
    call SaveBoolean(gObject, data, SpawnWaveData_mIsBoss, isBossWave)

    set GameDirector_gSpawnWaveData[GameDirector_gSpawnWaveData_mSize] = data
    set GameDirector_gSpawnWaveData_mSize = GameDirector_gSpawnWaveData_mSize + 1

    if IsNull(LoadInteger(gObject, data, SpawnWaveData_mUnitType)) then
        call DebugLog(LOG_ERROR, "GameDirector_c: Failed to register type " + typeName)
    endif
endfunction


function GameDirector_AddSpawnPoint takes rect area returns nothing
    set GameDirector_gSpawnX[GameDirector_gSpawnPointCount] = GetRectCenterX(area)
    set GameDirector_gSpawnY[GameDirector_gSpawnPointCount] = GetRectCenterY(area)
    set GameDirector_gSpawnPointCount = GameDirector_gSpawnPointCount + 1
endfunction

function GameDirector_PreInit takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= GameDirector_gMaxUnit
        set GameDirector_gWaveUnits[i] = INVALID
        set i = i + 1
    endloop
    call GameDirector_AddSpawnPoint(gg_rct_WaveSpawner0)
    call GameDirector_AddSpawnPoint(gg_rct_WaveSpawner1)
    call GameDirector_AddSpawnPoint(gg_rct_WaveSpawner2)
    call GameDirector_AddSpawnPoint(gg_rct_WaveSpawner3)
    set GameDirector_gTargetX = GetRectCenterX(gg_rct_WaveTarget)
    set GameDirector_gTargetY = GetRectCenterY(gg_rct_WaveTarget)

    // call GameDirector_RegisterWave("TestWaveUnit", false, 3, 1.75)
    // call GameDirector_RegisterWave("TestWaveUnit2", false, 3, 1.75)

    call GameDirector_RegisterWave("Gnoll", false, 10, 1.75)
    call GameDirector_RegisterWave("Kobold", false, 10, 1.75)
    call GameDirector_RegisterWave("Troll", false, 10, 1.75)
    call GameDirector_RegisterWave("Gnoll Poacher", false, 10, 1.75)
    call GameDirector_RegisterWave("Kobold Miner", false, 10, 1.75)
    call GameDirector_RegisterWave("Troll Axe Thrower", false, 10, 1.75)



    if CONFIG_GAME_ENABLE_LOGGING then
        call DebugLog(LOG_INFO, "GameDirectorRegister: Registered " + I2S(GameDirector_gSpawnWaveData_mSize) + " waves")
    endif
endfunction