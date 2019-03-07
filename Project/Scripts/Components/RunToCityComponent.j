// DECLARE_TYPE(RunToCityComponent,1000,1000)
globals
    // Component_MAX_MEMBER
    constant integer RunToCityComponent_mPrevX = Component_MAX_MEMBER + 0
    constant integer RunToCityComponent_mPrevY = Component_MAX_MEMBER + 1
    constant integer RunToCityComponent_mTimer = Component_MAX_MEMBER + 2

    constant integer RunToCityComponent_MAX_MEMBER = Component_MAX_MEMBER + 3

    code RunToCityComponent_gDestroyFunc = null
    code RunToCityComponent_gUpdateFunc = null
endglobals


function RunToCityComponent_Create takes nothing returns integer
    local integer self = Object_Allocate(TYPE_ID_RUN_TO_CITY_COMPONENT, RunToCityComponent_MAX_MEMBER)
    if IsNull(self) then
        return self
    endif

    call Component_Derive(self, RunToCityComponent_gDestroyFunc, RunToCityComponent_gUpdateFunc)
    call SaveReal(gObject, self, RunToCityComponent_mPrevX, 0.0)
    call SaveReal(gObject, self, RunToCityComponent_mPrevY, 0.0)
    call SaveTimerHandle(gObject, self, RunToCityComponent_mTimer, CreateTimer())
    return self
endfunction

function RunToCityComponent_Destroy takes nothing returns nothing
    local integer self = Component_gDestructorArg_Self
    call DebugLog(LOG_INFO, "RunToCityComponent: Destroy " + I2S(self))

    call RemoveSavedReal(gObject, self, RunToCityComponent_mPrevX)
    call RemoveSavedReal(gObject, self, RunToCityComponent_mPrevY)
    call Object_Free(self)
endfunction

function RunToCityComponent_Update takes nothing returns nothing
    local integer self = Component_gUpdateArg_Self
    local real mPrevX = LoadReal(gObject, self, RunToCityComponent_mPrevX)
    local real mPrevY = LoadReal(gObject, self, RunToCityComponent_mPrevY)
    local integer mUnitData = LoadInteger(gObject, self, Component_mParent)
    local unit mUnit = LoadUnitHandle(gObject, mUnitData, UnitData_mHandle)
    local timer mTimer = LoadTimerHandle(gObject, self, RunToCityComponent_mTimer)

    // call DebugLog(LOG_INFO, "RunToCityComponent: Updating...")

    if TimerGetRemaining(mTimer) <= 0.0 and IsUnitInRangeXY(mUnit, mPrevX, mPrevY, 50.0) then
        call IssuePointOrder(mUnit, "attack", GameDirector_gTargetX, GameDirector_gTargetY)
        call TimerStart(mTimer, 3.0, false, null)
    endif

    call SaveReal(gObject, self, RunToCityComponent_mPrevX, GetUnitX(mUnit))
    call SaveReal(gObject, self, RunToCityComponent_mPrevY, GetUnitY(mUnit))

    set mUnit = null
    set mTimer = null
endfunction

