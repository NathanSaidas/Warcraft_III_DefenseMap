// DECLARE_TYPE(MonitorUnitLifeComponent, 1000, 1000)
globals
    constant integer MonitorUnitLifeComponent_mDeathTimer = Component_MAX_MEMBER + 0
    constant integer MonitorUnitLifeComponent_MAX_MEMBER = Component_MAX_MEMBER + 1

    code MonitorUnitLifeComponent_gDestroyFunc = null
    code MonitorUnitLifeComponent_gUpdateFunc = null
endglobals

function MonitorUnitLifeComponent_Create takes nothing returns integer
    local integer self = Object_Allocate(TYPE_ID_MONITOR_UNIT_LIFE_COMPONENT, MonitorUnitLifeComponent_MAX_MEMBER)
    if IsNull(self) then
        return self
    endif

    call Component_Derive(self, MonitorUnitLifeComponent_gDestroyFunc, MonitorUnitLifeComponent_gUpdateFunc)
    call SaveTimerHandle(gObject, self, MonitorUnitLifeComponent_mDeathTimer, null)
    return self
endfunction

function MonitorUnitLifeComponent_Destroy takes nothing returns nothing
    local integer self = Component_gDestructorArg_Self
    local timer mDeathTimer = LoadTimerHandle(gObject, self, MonitorUnitLifeComponent_mDeathTimer)
    call DestroyTimer(mDeathTimer)
    call RemoveSavedHandle(gObject, self, MonitorUnitLifeComponent_mDeathTimer)
    call Object_Free(self)
    set mDeathTimer = null
endfunction

function MonitorUnitLifeComponent_Update takes nothing returns nothing
    local integer self = Component_gUpdateArg_Self
    local integer mUnitData = LoadInteger(gObject, self, Component_mParent)
    local unit mUnit = LoadUnitHandle(gObject, mUnitData, UnitData_mHandle)
    local timer mDeathTimer = LoadTimerHandle(gObject, self, MonitorUnitLifeComponent_mDeathTimer)

    if IsUnitDeadBJ(mUnit) then
        if mDeathTimer == null then
            set mDeathTimer = CreateTimer()
            call TimerStart(mDeathTimer, 2.0, false, null)
            call SaveTimerHandle(gObject, self, MonitorUnitLifeComponent_mDeathTimer, mDeathTimer)
        elseif TimerGetRemaining(mDeathTimer) <= 0.0 then
            call UnitData_QueueDestroy(mUnitData)
        endif
    endif
    set mUnit = null
    set mDeathTimer = null
endfunction