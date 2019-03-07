
// DECLARE_TYPE(UnitData, 1000, 1000)
globals
    constant integer UnitData_mHandle = 0
    constant integer UnitData_mTypeData = 1
    constant integer UnitData_mMonitorTrigger = 2
    constant integer UnitData_mWaveUnit = 3
    constant integer UnitData_mPlayerData = 4

    constant integer UnitData_MAX_MEMBER = 5

    integer gUnitData_MonitorArg = INVALID
    real gUnitData_TargetPointX = 0.0
    real gUnitData_TargetPointY = 0.0
endglobals

function GetUnitId takes unit unitHandle returns integer
    return GetUnitUserData(unitHandle) - 1
endfunction

function SetUnitId takes unit unitHandle, integer id returns nothing
    call SetUnitUserData(unitHandle, id + 1)
endfunction

function UnitData_Create takes unit unitHandle, integer unitTypeData returns integer
    local integer self = Object_Allocate(TYPE_ID_UNIT_DATA, UnitData_MAX_MEMBER)
    if IsNull(self) then
        return self
    endif

    call SaveUnitHandle(gObject, self, UnitData_mHandle, unitHandle)
    call SaveInteger(gObject, self, UnitData_mTypeData, unitTypeData)
    call SaveTriggerHandle(gObject, self, UnitData_mMonitorTrigger, null)
    call SaveBoolean(gObject, self, UnitData_mWaveUnit, false)
    call SaveInteger(gObject, self, UnitData_mPlayerData, INVALID)
    call SetUnitId(unitHandle, self)
    return self
endfunction

function UnitData_Destroy takes integer self returns nothing
    if IsNull(self) then
        call AccessViolation("UnitData_Destroy")
        return
    endif

    call SetUnitId(LoadUnitHandle(gObject, self, UnitData_mHandle), INVALID)
    call RemoveUnit(LoadUnitHandle(gObject, self, UnitData_mHandle))
    call RemoveSavedHandle(gObject, self, UnitData_mHandle)
    call RemoveSavedInteger(gObject, self, UnitData_mTypeData)
    call DestroyTrigger(LoadTriggerHandle(gObject, self, UnitData_mMonitorTrigger))
    call RemoveSavedHandle(gObject, self, UnitData_mMonitorTrigger)
    call RemoveSavedBoolean(gObject, self, UnitData_mWaveUnit)
    call RemoveSavedInteger(gObject, self, UnitData_mPlayerData)
    call Object_Free(self)
endfunction

function UnitData_GetTypeName takes integer self returns string
    if IsNull(self) then
        call AccessViolation("UnitData_GetTypeName")
        return ""
    endif
    return LoadStr(gObject, LoadInteger(gObject, self, UnitData_mTypeData), UnitTypeData_mName)
endfunction

function UnitData_IsWaveUnit takes integer self returns boolean
    if IsNull(self) then
        call AccessViolation("UnitData_IsWaveUnit")
        return false
    endif
    return LoadBoolean(gObject, self, UnitData_mWaveUnit)
endfunction

function UnitData_SetWaveUnit takes integer self, boolean value returns nothing
    if IsNull(self) then
        call AccessViolation("UnitData_SetWaveUnit")
        return
    endif
    call SaveBoolean(gObject, self, UnitData_mWaveUnit, value)
endfunction

function UnitData_SetPlayerData takes integer self, integer playerData returns nothing
    if IsNull(self) then
        call AccessViolation("UnitData_SetPlayerData")
        return
    endif
    call SaveInteger(gObject, self, UnitData_mPlayerData, playerData)
endfunction

function UnitData_GetPlayerData takes integer self returns integer
    if IsNull(self) then
        call AccessViolation("UnitData_GetPlayerData")
        return INVALID
    endif
    return LoadInteger(gObject, self, UnitData_mPlayerData)
endfunction

function UnitData_Monitor takes nothing returns nothing
    local integer self = gUnitData_MonitorArg
    local unit u = LoadUnitHandle(gObject, self, UnitData_mHandle)
    local real x = GetUnitX(u)
    local real y = GetUnitY(u)
    local integer idx = -1
    local integer mUnits = INVALID

    loop
        if IsUnitInRangeXY(u, x, y, 50.0) then
            call DebugLog(LOG_INFO, "Order Move Attack")
            call IssuePointOrder(u, "attack", gUnitData_TargetPointX, gUnitData_TargetPointY)
        endif
        set x = GetUnitX(u)
        set y = GetUnitY(u)

        if UnitData_IsWaveUnit(self) and gGameState == GS_FAILED then
            set mUnits = LoadInteger(gObject, gGameRules, GameRules_mUnits)
            set idx = List_FindObject(mUnits, self)
            if idx > 0 then
                call List_RemoveObject(mUnits, idx)
            endif
            call UnitData_Destroy(self)
            exitwhen true
        endif

        call Sleep(3.0)
        exitwhen IsNull(self)
    endloop

endfunction

function UnitData_BeginMonitor takes integer self returns nothing
    local trigger mMonitorTrigger = null
    if IsNull(self) then
        call AccessViolation("UnitData_BeginMonitor")
        return
    endif

    set mMonitorTrigger = LoadTriggerHandle(gObject, self, UnitData_mMonitorTrigger)
    if mMonitorTrigger != null then
        call DebugLog(LOG_ERROR, "UnitData_BeginMonitor failed! Unit is already being monitored. Name=" + UnitData_GetTypeName(self))
        set mMonitorTrigger = null
        return
    endif

    set mMonitorTrigger = CreateTrigger()
    call TriggerAddAction(mMonitorTrigger, function UnitData_Monitor)
    call SaveTriggerHandle(gObject, self, UnitData_mMonitorTrigger, mMonitorTrigger)
    set gUnitData_MonitorArg = self
    call TriggerExecute(mMonitorTrigger)
    set gUnitData_MonitorArg = INVALID
    set mMonitorTrigger = null
endfunction

function UnitData_EndMonitor takes integer self returns nothing
    if IsNull(self) then
        call AccessViolation("UnitData_EndMonitor")
        return
    endif

    call DestroyTrigger(LoadTriggerHandle(gObject, self, UnitData_mMonitorTrigger))
    call SaveTriggerHandle(gObject, self, UnitData_mMonitorTrigger, null)
endfunction