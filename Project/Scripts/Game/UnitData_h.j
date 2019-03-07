// DECLARE_TYPE(UnitData,500,500)
globals
    constant integer UnitData_mHandle = 0
    constant integer UnitData_mTypeData = 1
    constant integer UnitData_mPlayerData = 2
    constant integer UnitData_mComponents = 3
    constant integer UnitData_mQueueDestroy = 4

    constant integer UnitData_MAX_MEMBER = 5
endglobals

function UnitData_Create takes nothing returns integer
    local integer self = Object_Allocate(TYPE_ID_UNIT_DATA, UnitData_MAX_MEMBER)
    if IsNull(self) then
        return self
    endif

    call SaveUnitHandle(gObject, self, UnitData_mHandle, null)
    call SaveInteger(gObject, self, UnitData_mTypeData, INVALID)
    call SaveInteger(gObject, self, UnitData_mPlayerData, INVALID)
    call SaveInteger(gObject, self, UnitData_mComponents, List_Create(TYPE_ID_COMPONENT))
    call SaveBoolean(gObject, self, UnitData_mQueueDestroy, false)
    return self
endfunction

function UnitData_QueueDestroy takes integer self returns nothing
    call SaveBoolean(gObject, self, UnitData_mQueueDestroy, true)
endfunction

function UnitData_Destroy takes integer self returns nothing
    local unit mHandle = null
    local integer mComponents = INVALID
    local integer mComponents_mSize = 0
    local integer i = 0
    if IsNull(self) then
        return 
    endif

    set mHandle = LoadUnitHandle(gObject, self, UnitData_mHandle)
    if mHandle != null then
        call RemoveUnit(mHandle)
    endif
    set mHandle = null

    set mComponents = LoadInteger(gObject, self, UnitData_mComponents)
    set mComponents_mSize = List_GetSize(mComponents)
    loop
        exitwhen i >= mComponents_mSize
        call Component_Destroy(List_GetObject(mComponents, i))
        set i = i + 1
    endloop
    call List_Clear(mComponents)
    call List_Destroy(mComponents)

    call RemoveSavedHandle(gObject, self, UnitData_mHandle)
    call RemoveSavedInteger(gObject, self, UnitData_mTypeData)
    call RemoveSavedInteger(gObject, self, UnitData_mPlayerData)
    call RemoveSavedInteger(gObject, self, UnitData_mComponents)
    call RemoveSavedBoolean(gObject, self, UnitData_mQueueDestroy)
    call Object_Free(self)
endfunction