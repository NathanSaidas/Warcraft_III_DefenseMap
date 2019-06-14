
function SRGameDirector_SpawnAIPlayerUnits takes nothing returns nothing
    local integer i = 0
    local integer typeData = INVALID
    local integer playerData = INVALID
    local integer unitData = INVALID

    call Breakpoint("SRGameDirector_c.SpawnAIPlayerUnits ")
    set typeData = UnitMgr_FindUnitTypeByString("SiegeRacer_Tank")
    loop
        exitwhen i >= PlayerMgr_gPlayers_mSize
        set playerData = PlayerMgr_gPlayers[i]
        if not PlayerData_IsHumanPlaying(playerData) then
            set unitData = UnitMgr_CreateUnit(typeData, playerData, SRGameDirector_gPlayerSpawnX, SRGameDirector_gPlayerSpawnY)
            set SRGameDirector_gPlayerUnits[SRGameDirector_gPlayerUnits_mSize] = unitData
            set SRGameDirector_gPlayerUnits_mSize = SRGameDirector_gPlayerUnits_mSize + 1

            call SaveInteger(gObject, playerData, PlayerData_mHero, unitData)
            call UnitData_AddComponent(unitData, RaceAIBehavior_Create())
        endif
        set i = i + 1
    endloop
endfunction
function SRGameDirector_RemoveAIPlayerUnits takes nothing returns nothing

endfunction
function SRGameDirector_UpdateAIPlayerUnits takes nothing returns nothing
    local integer i = 0
    local integer unitData = INVALID
    local integer component = INVALID

    loop
        exitwhen i >= SRGameDirector_gPlayerUnits_mSize
        set unitData = SRGameDirector_gPlayerUnits[i]
        set component = UnitData_GetComponent(unitData, TYPE_ID_RACE_AIBEHAVIOR)
        call Component_Update(component)
        set i = i + 1
    endloop
endfunction