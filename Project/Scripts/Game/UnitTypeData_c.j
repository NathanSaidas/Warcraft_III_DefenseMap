function UnitTypeData_GetName takes integer self returns string
    if not SelfCheck(self, TYPE_ID_UNIT_TYPE_DATA, "UnitTypeData_GetName") then
        return ""
    endif
    return LoadStr(gObject, self, UnitTypeData_mName)
endfunction

function UnitTypeData_GetId takes integer self returns integer
    if not SelfCheck(self, TYPE_ID_UNIT_TYPE_DATA, "UnitTypeData_GetId") then
        return 0
    endif
    return LoadInteger(gObject, self, UnitTypeData_mTypeId)
endfunction

function UnitTypeData_GetInitCallback takes integer self returns trigger
    if not SelfCheck(self, TYPE_ID_UNIT_TYPE_DATA, "UnitTypeData_GetInitCallback") then
        return null
    endif
    return LoadTriggerHandle(gObject, self, UnitTypeData_mInitCallback)
endfunction

function UnitTypeData_Init takes integer self, integer unitData returns nothing
    local trigger mInitCallback = null
    if not SelfCheck(self, TYPE_ID_UNIT_TYPE_DATA, "UnitTypeData_Init") then
        return
    endif 
    set UnitTypeData_gArg_Init_typeData = self
    set UnitTypeData_gArg_Init_unitData = unitData
    set mInitCallback = LoadTriggerHandle(gObject, self, UnitTypeData_mInitCallback)
    if mInitCallback != null then
        call TriggerExecute(mInitCallback)
        set mInitCallback = null
    endif
endfunction