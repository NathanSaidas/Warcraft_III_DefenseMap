function GetUnitId takes unit unitHandle returns integer
    return GetUnitUserData(unitHandle) - 1
endfunction

function SetUnitId takes unit unitHandle, integer id returns nothing
    call SetUnitUserData(unitHandle, id + 1)
endfunction


function UnitData_GetComponent takes integer self, integer typeId returns integer
    local integer i = 0
    local integer mComponents = INVALID
    local integer mComponents_mSize = 0
    local integer current = INVALID

    if not SelfCheck(self, TYPE_ID_UNIT_DATA, "UnitData_GetComponent") then
        return INVALID
    endif

    set mComponents = LoadInteger(gObject, self, UnitData_mComponents)
    set mComponents_mSize = List_GetSize(mComponents)
    loop
        exitwhen i >= mComponents_mSize
        set current = List_GetObject(mComponents, i)
        if Object_GetTypeId(current) == typeId then
            return current
        endif
        set i = i + 1
    endloop
    return INVALID
endfunction

function UnitData_AddComponent takes integer self, integer component returns boolean
    local integer mComponents = INVALID
    if not SelfCheck(self, TYPE_ID_UNIT_DATA, "UnitData_AddComponent") then
        return false
    endif

    if IsNull(component) then
        call DebugLog(LOG_ERROR, "UnitData_c: UnitData_AddComponent failed, missing component instance.")
        return false
    endif

    if not IsNull(UnitData_GetComponent(self, Object_GetTypeId(component))) then
        call DebugLog(LOG_ERROR, "UnitData_c: UnitData_AddComponent failed, component of that type already exists. Type=" + Object_GetTypeName(Object_GetTypeId(component)))
        return false
    endif

    set mComponents = LoadInteger(gObject, self, UnitData_mComponents)
    call List_AddObject(mComponents, component)
    call SaveInteger(gObject, component, Component_mParent, self)
    return true
endfunction

function UnitData_Update takes integer self returns nothing
    local integer i = 0
    local integer mComponents = INVALID
    local integer mComponents_mSize = 0
    local integer current = INVALID

    if not SelfCheck(self, TYPE_ID_UNIT_DATA, "UnitData_Update") then
        return
    endif

    set mComponents = LoadInteger(gObject, self, UnitData_mComponents)
    set mComponents_mSize = List_GetSize(mComponents)
    loop
        exitwhen i >= mComponents_mSize
        set current = List_GetObject(mComponents, i)
        call Component_Update(current)
        set i = i + 1
    endloop
endfunction