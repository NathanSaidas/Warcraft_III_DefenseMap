// This file contains members and public accessors for GameRules
// See GameRules for initialization/private update stuff



function GameRules_FindUnitTypeByName takes string name returns integer 
    local integer i = 0
    local integer size = 0
    local integer mUnitTypes = INVALID
    local integer current = INVALID
    if not SelfCheck(gGameRules, TYPE_ID_GAME_RULES, "GameRules_FindUnitTypeByName") then
        return INVALID
    endif

    set mUnitTypes = LoadInteger(gObject, gGameRules, GameRules_mUnitTypes)
    set size = List_GetSize(mUnitTypes)
    loop
        exitwhen i >= size
        set current = List_GetObject(mUnitTypes, i)
        if LoadStr(gObject, current, UnitTypeData_mName) == name then
            return current
        endif
        set i = i + 1
    endloop
    return INVALID
endfunction

function GameRules_FindUnitTypeById takes integer id returns integer
    local integer i = 0
    local integer size = 0
    local integer mUnitTypes = INVALID
    local integer current = INVALID
    if not SelfCheck(gGameRules, TYPE_ID_GAME_RULES, "GameRules_FindUnitTypeById") then
        return INVALID
    endif

    set mUnitTypes = LoadInteger(gObject, gGameRules, GameRules_mUnitTypes)
    set size = List_GetSize(mUnitTypes)
    loop
        exitwhen i >= size
        set current = List_GetObject(mUnitTypes, i)
        if LoadInteger(gObject, current, UnitTypeData_mTypeId) == id then
            return current
        endif
        set i = i + 1
    endloop
    return INVALID
endfunction

function GameRules_FindPlayerById takes integer id returns integer
    local integer i = 0
    local integer size = 0
    local integer mPlayers = INVALID
    if not SelfCheck(gGameRules, TYPE_ID_GAME_RULES, "GameRules_FindUnitTypeById") then
        return INVALID
    endif

    set mPlayers = LoadInteger(gObject, gGameRules, GameRules_mPlayers)
    set size = List_GetSize(mPlayers)
    loop
        exitwhen i >= size
        if LoadInteger(gObject, List_GetObject(mPlayers, i), PlayerData_mId) == id then
            return List_GetObject(mPlayers, i)
        endif
        set i = i + 1
    endloop
    return INVALID
endfunction

function GameRules_CreateNpc takes integer unitTypeData, real x, real y returns integer
    local integer unitTypeId = LoadInteger(gObject, unitTypeData, UnitTypeData_mTypeId)
    local unit unitSpawned = CreateUnit(Player(gGameRules_NpcPlayer), unitTypeId, x, y, 0)
    local integer mPendingSpawns = LoadInteger(gObject, gGameRules, GameRules_mPendingSpawns)
    local integer unitData = UnitData_Create(unitSpawned, unitTypeData)

    if IsNull(unitData) then
        call RemoveUnit(unitSpawned)
        set unitSpawned = null
        return INVALID
    endif

    call List_AddObject(mPendingSpawns, unitData)
    set unitSpawned = null
    return unitData
endfunction

function GameRules_CreateUnit takes integer unitTypeData, integer playerId, real x, real y returns integer
    local integer unitTypeId = LoadInteger(gObject, unitTypeData, UnitTypeData_mTypeId)
    local unit unitSpawned = CreateUnit(Player(playerId), unitTypeId, x, y, 0)
    local integer unitData = UnitData_Create(unitSpawned, unitTypeData)
    local integer playerData = GameRules_FindPlayerById(playerId)

    if IsNull(unitData) then
        call RemoveUnit(unitSpawned)
        set unitSpawned = null
        return INVALID
    endif

    call UnitData_SetPlayerData(unitData, playerData)
    set unitSpawned = null
    return unitData
endfunction

function GameRules_DestroyUnit takes integer unitData returns nothing
    local integer idx = -1
    local integer mUnits = LoadInteger(gObject, gGameRules, GameRules_mUnits)
    if IsNull(unitData) then
        return
    endif
    if UnitData_IsWaveUnit(unitData) then
        set idx = List_FindObject(mUnits, unitData)
        if idx > 0 then
            call List_RemoveObject(mUnits, idx)
        endif
    endif
    call UnitData_Destroy(unitData)
endfunction