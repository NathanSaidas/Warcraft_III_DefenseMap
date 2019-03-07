// DECLARE_TYPE(GameRules, 1, 1)
globals
    // Begin(45 second delay) -> Spawn(X Units) -> Wait(Delay)
    // constant integer GameRules_STATE_WAVE_BEGIN = 0
    // constant integer GameRules_STATE_WAVE_SPAWN = 1
    // constant integer GameRules_STATE_WAVE_WAIT = 2

    constant real GameRules_WAVE_TIME = 10.0 // Seconds
    constant integer GameRules_WAVE_UNIT_COUNT = 3 // Number of Units to spawn at each portal
    constant real GameRules_SPAWN_INTERVAL = 2.5 // Seconds
    constant integer GameRules_LIVES = 10
    constant integer GameRules_MAX_WAVE_UNIT = 15
    constant real GameRules_OPTIONS_WAIT_TIMER = 15.0
    
    integer gGameRules = INVALID
    integer gGameRules_NpcPlayer = 8 // Grey

    constant integer GameRules_mPendingSpawns = 0
    constant integer GameRules_mUnitTypes = 1
    constant integer GameRules_mWaveId = 2
    constant integer GameRules_mQueuedWaveId = 3
    constant integer GameRules_mWaveTypes = 4
    constant integer GameRules_mSpawnPortals = 5
    constant integer GameRules_mSpawnTimer = 6
    constant integer GameRules_mSpawnsRemaining = 7
    constant integer GameRules_mWaveTimer = 8
    constant integer GameRules_mWaveTimerDialog = 9

    constant integer GameRules_mLives = 10
    constant integer GameRules_mSpawnsEnabled = 11
    constant integer GameRules_mLifeTrigger = 12

    constant integer GameRules_mUnits = 13
    constant integer GameRules_mModeTimer = 14
    constant integer GameRules_mPlayers = 15

    constant integer GameRules_MAX_MEMBER = 16
endglobals