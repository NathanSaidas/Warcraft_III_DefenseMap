globals
    integer array GameDirector_gSpawnWaveData
    integer       GameDirector_gSpawnWaveData_mSize = 0

    real array    GameDirector_gSpawnX
    real array    GameDirector_gSpawnY
    integer       GameDirector_gSpawnPointCount = 0
    real          GameDirector_gTargetX = 0.0
    real          GameDirector_gTargetY = 0.0

    integer GameDirector_gCurrentSpawnCount = 0
    real    GameDirector_gCurrentSpawnDelay = 0.0
    integer GameDirector_gCurrentUnitType = INVALID
    boolean GameDirector_gCurrentBossWave = false
    integer GameDirector_gCurrentSpawnWave = 0

    timerdialog GameDirector_gWaveTimerDialog = null
    timer       GameDirector_gWaveTimer = null
    timer       GameDirector_gSpawnTimer = null

    integer array GameDirector_gWaveUnits
    integer       GameDirector_gWaveUnits_mSize = 0
    integer       GameDirector_gMaxUnit = 12

    boolean GameDirector_gRunning = false
endglobals