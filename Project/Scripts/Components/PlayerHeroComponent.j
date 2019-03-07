
// When the player dies start a timer and revive them.
//
// DECLARE_TYPE(PlayerHeroComponent,1000,1000)
globals
    constant integer PlayerHeroComponent_mState = Component_MAX_MEMBER + 0
    constant integer PlayerHeroComponent_mTimer = Component_MAX_MEMBER + 1

    constant integer PlayerHeroComponent_MAX_MEMBER = Component_MAX_MEMBER + 2

    code PlayerHeroComponent_gDestroyFunc = null
    code PlayerHeroComponent_gUpdateFunc = null
endglobals

function PlayerHeroComponent_Create takes nothing returns integer
    local integer self = Object_Allocate(TYPE_ID_PLAYER_HERO_COMPONENT, PlayerHeroComponent_MAX_MEMBER)
    if IsNull(self) then
        return self
    endif

    call Component_Derive(self, PlayerHeroComponent_gDestroyFunc, PlayerHeroComponent_gUpdateFunc)
    call SaveBoolean(gObject, self, PlayerHeroComponent_mState, false)
    call SaveTimerHandle(gObject, self, PlayerHeroComponent_mTimer, null)

    return self
endfunction

function PlayerHeroComponent_Destroy takes nothing returns nothing
    local integer self = Component_gDestructorArg_Self
    local timer mTimer = LoadTimerHandle(gObject, self, PlayerHeroComponent_mTimer)

    if mTimer != null then
        call DestroyTimer(mTimer)
        set mTimer = null
    endif

    call RemoveSavedBoolean(gObject, self, PlayerHeroComponent_mState)
    call RemoveSavedHandle(gObject, self, PlayerHeroComponent_mTimer)
    call Object_Free(self)
endfunction

function PlayerHeroComponent_Update takes nothing returns nothing
    local integer self = Component_gUpdateArg_Self
    local integer mUnitData = LoadInteger(gObject, self, Component_mParent)
    local unit mUnit = LoadUnitHandle(gObject, mUnitData, UnitData_mHandle)
    local timer mTimer = null

    // todo: Detect unit death:
    // IsUnitDeadBJ
    if IsUnitDeadBJ(mUnit) and not LoadBoolean(gObject, self, PlayerHeroComponent_mState) then
        call SaveBoolean(gObject, self, PlayerHeroComponent_mState, true)
        set mTimer = CreateTimer()
        call TimerStart(mTimer, 5.0, false, null)
        call SaveTimerHandle(gObject, self, PlayerHeroComponent_mTimer, mTimer)
        call DebugLog(LOG_INFO, "Detected hero unit death")
    endif

    if not IsUnitDeadBJ(mUnit) and LoadBoolean(gObject, self, PlayerHeroComponent_mState) then
        call SaveBoolean(gObject, self, PlayerHeroComponent_mState, false)
        set mTimer = LoadTimerHandle(gObject, self, PlayerHeroComponent_mTimer)
        call DestroyTimer(mTimer)
        set mTimer = null
        call SaveTimerHandle(gObject, self, PlayerHeroComponent_mTimer, null)
        call DebugLog(LOG_INFO, "Detected hero alive")
    endif

endfunction
