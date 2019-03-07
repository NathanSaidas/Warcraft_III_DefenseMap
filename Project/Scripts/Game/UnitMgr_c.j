function UnitMgr_RegisterUnitType takes integer typeId, string id returns integer
    local integer unitTypeData = UnitTypeData_Create(id, typeId)
    local integer idx = List_GetSize(UnitMgr_gTypes)
    set UnitMgr_gIndexNames[idx] = id
    set UnitMgr_gIndexIds[idx] = typeId
    call List_AddObject(UnitMgr_gTypes, unitTypeData)
    return unitTypeData
endfunction

function UnitMgr_FindUnitTypeByString takes string id returns integer
    local integer i = 0
    loop
        exitwhen i >= UnitMgr_gTypes_mSize
        if UnitMgr_gIndexNames[i] == id then
            return List_GetObject(UnitMgr_gTypes, i)
        endif
        set i = i + 1
    endloop
    return INVALID
endfunction

function UnitMgr_FindUnitTypeById takes integer id returns integer
    local integer i = 0
    loop
        exitwhen i >= UnitMgr_gTypes_mSize
        if UnitMgr_gIndexIds[i] == id then
            return List_GetObject(UnitMgr_gTypes, i)
        endif
        set i = i + 1
    endloop
    return INVALID
endfunction

function UnitMgr_CreateUnit takes integer typeData, integer playerOwner, real x, real y returns integer
    local integer unitTypeId = LoadInteger(gObject, typeData, UnitTypeData_mTypeId)
    local integer unitData = INVALID
    local unit unitHandle = null
    
    if IsNull(typeData) or IsNull(playerOwner) then
        return INVALID
    endif

    set unitData = UnitData_Create()
    if IsNull(unitData) then
        return INVALID
    endif

    set unitHandle = CreateUnit(Player(LoadInteger(gObject, playerOwner, PlayerData_mPlayerId)), unitTypeId, x, y, 0)
    if unitHandle == null then
        call UnitData_Destroy(unitData)
        return INVALID
    endif

    // Link Unit
    call SaveUnitHandle(gObject, unitData, UnitData_mHandle, unitHandle)
    call SaveInteger(gObject, unitData, UnitData_mTypeData, typeData)
    call SaveInteger(gObject, unitData, UnitData_mPlayerData, playerOwner)
    call SetUnitId(unitHandle, unitData)
    set unitHandle = null

    // Link Player
    call List_AddObject(LoadInteger(gObject, playerOwner, PlayerData_mControlledUnits), unitData)

    // Call Custom Init Func
    call UnitTypeData_Init(typeData, unitData)
    return unitData
endfunction

function UnitMgr_DestroyUnit takes integer unitData returns nothing
    local integer mPlayerData = INVALID
    local integer mControlledUnits = INVALID
    local integer unitIdx = -1
    if IsNull(unitData) then
        return
    endif
    
    // Disconnect Player Link
    set mPlayerData = LoadInteger(gObject, unitData, UnitData_mPlayerData)
    if not IsNull(mPlayerData) then
        set mControlledUnits = LoadInteger(gObject, mPlayerData, PlayerData_mControlledUnits)
        set unitIdx = List_FindObject(mControlledUnits, unitData)
        if unitIdx >= 0 then
            call List_RemoveObject(mControlledUnits, unitIdx)
        endif
    endif
    
    // Destroy Unit Data (and unit handle)
    call UnitData_Destroy(unitData)
endfunction
