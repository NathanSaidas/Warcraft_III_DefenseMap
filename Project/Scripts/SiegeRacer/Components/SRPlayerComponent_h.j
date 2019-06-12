// DECLARE_TYPE(SRPlayerComponent, 24, 24)
globals
    integer SRPlayerComponent_gMaxCheckPoint = 0

    constant integer SRPlayerComponent_mCheckPointIndex = Component_MAX_MEMBER + 0
    constant integer SRPlayerComponent_mLapsComplete = Component_MAX_MEMBER + 1

    constant integer SRPlayerComponent_MAX_MEMBER = Component_MAX_MEMBER + 2

    code SRPlayerComponent_gDestroyFunc = null
    code SRPlayerComponent_gUpdateFunc = null
endglobals

function SRPlayerComponent_Create takes nothing returns integer
    local integer self = Object_Allocate(TYPE_ID_SRPLAYER_COMPONENT, SRPlayerComponent_MAX_MEMBER)
    if IsNull(self) then
        return self
    endif

    call Component_Derive(self, SRPlayerComponent_gDestroyFunc, SRPlayerComponent_gUpdateFunc)
    call SaveInteger(gObject, self, SRPlayerComponent_mCheckPointIndex, 0)
    call SaveInteger(gObject, self, SRPlayerComponent_mLapsComplete, 0)
    return self
endfunction


function SRPlayerComponent_OnCheckpointEnter takes integer self, integer index returns nothing
    local integer mCheckPointIndex = INVALID
    local integer mLapsComplete = INVALID

    if not SelfCheck(self, TYPE_ID_SRPLAYER_COMPONENT, "SRPlayerComponent_OnCheckpointEnter") then
        return
    endif

    call DebugLog(LOG_INFO, "SRPlayerComponent_OnCheckpointEnter")
    set mCheckPointIndex = LoadInteger(gObject, self, SRPlayerComponent_mCheckPointIndex)
    set mLapsComplete = LoadInteger(gObject, self, SRPlayerComponent_mLapsComplete)

    if mCheckPointIndex == index then
        set mCheckPointIndex = mCheckPointIndex + 1
    endif

    if mCheckPointIndex >= SRPlayerComponent_gMaxCheckPoint then
        set mCheckPointIndex = 0
        set mLapsComplete = mLapsComplete + 1
        call DebugLog(LOG_INFO, "Lap Complete!")
    endif

    call SaveInteger(gObject, self, SRPlayerComponent_mCheckPointIndex, mCheckPointIndex)
    call SaveInteger(gObject, self, SRPlayerComponent_mLapsComplete, mLapsComplete)
endfunction