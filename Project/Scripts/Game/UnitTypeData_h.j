// DECLARE_TYPE(UnitTypeData, 1000, 1000)
// @persistent
globals
    constant integer UnitTypeData_mName = 0
    constant integer UnitTypeData_mTypeId = 1
    constant integer UnitTypeData_mInitCallback = 2

    constant integer UnitTypeData_MAX_MEMBER = 3

    integer UnitTypeData_gArg_Init_typeData = INVALID
    integer UnitTypeData_gArg_Init_unitData = INVALID
endglobals

function UnitTypeData_Create takes string name, integer id returns integer
    local integer self = Object_Allocate(TYPE_ID_UNIT_TYPE_DATA, UnitTypeData_MAX_MEMBER)
    if IsNull(self) then
        return self
    endif
    call SaveStr(gObject, self, p_Object_Name, name)
    call SaveStr(gObject, self, UnitTypeData_mName, name)
    call SaveInteger(gObject, self, UnitTypeData_mTypeId, id)
    call SaveTriggerHandle(gObject, self, UnitTypeData_mInitCallback, null)
    return self
endfunction

function UnitTypeData_IsHero takes integer self returns boolean
    if not SelfCheck(self, TYPE_ID_UNIT_TYPE_DATA, "UnitTypeData_IsHero") then
        return false
    endif
    return IsUnitIdType(LoadInteger(gObject, self, UnitTypeData_mTypeId), UNIT_TYPE_HERO)
endfunction