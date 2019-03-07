// DECLARE_TYPE(SpawnWaveData,100,100)
globals
    constant integer SpawnWaveData_mSpawnCount = 0
    constant integer SpawnWaveData_mSpawnDelay = 1
    constant integer SpawnWaveData_mUnitType = 2
    constant integer SpawnWaveData_mIsBoss = 3

    constant integer SpawnWaveData_MAX_MEMBER = 4
endglobals

function SpawnWaveData_Create takes nothing returns integer
    local integer self = Object_Allocate(TYPE_ID_SPAWN_WAVE_DATA, SpawnWaveData_MAX_MEMBER)
    if IsNull(self) then
        return self
    endif

    call SaveInteger(gObject, self, SpawnWaveData_mSpawnCount, 0)
    call SaveReal(gObject, self, SpawnWaveData_mSpawnDelay, 1.75)
    call SaveInteger(gObject, self, SpawnWaveData_mUnitType, INVALID)
    call SaveBoolean(gObject, self, SpawnWaveData_mIsBoss, false)
    return self
endfunction