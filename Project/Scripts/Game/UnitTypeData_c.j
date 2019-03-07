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