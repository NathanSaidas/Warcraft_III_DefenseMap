// DECLARE_TYPE(MonitorUnitLifeComponent, 1000, 1000)
globals
    constant integer MonitorUnitLifeComponent_MAX_MEMBER = Component_MAX_MEMBER + 0

    code MonitorUnitLifeComponent_gDestroyFunc = null
    code MonitorUnitLifeComponent_gUpdateFunc = null
endglobals

function MonitorUnitLifeComponent_Create takes nothing returns integer
    local integer self = Object_Allocate(TYPE_ID_MONITOR_UNIT_LIFE_COMPONENT, MonitorUnitLifeComponent_MAX_MEMBER)
    if IsNull(self) then
        return self
    endif

    call Component_Derive(self, MonitorUnitLifeComponent_gDestroyFunc, MonitorUnitLifeComponent_gUpdateFunc)
    return self
endfunction

function MonitorUnitLifeComponent_Destroy takes nothing returns nothing
    local integer self = Component_gDestructorArg_Self
    call Object_Free(self)
endfunction

function MonitorUnitLifeComponent_Update takes nothing returns nothing
    local integer self = Component_gUpdateArg_Self
    local integer mUnitData = LoadInteger(gObject, self, Component_mParent)
    local unit mUnit = LoadUnitHandle(gObject, mUnitData, UnitData_mHandle)

    if IsUnitDeadBJ(mUnit) then
        call UnitData_QueueDestroy(mUnitData)
    endif
    set mUnit = null
endfunction