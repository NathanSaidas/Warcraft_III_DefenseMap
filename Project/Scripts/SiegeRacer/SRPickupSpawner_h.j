// DECLARE_TYPE(SRPickupSpawner, 20, 20)
globals
    constant integer SRPickupSpawner_mRefreshTime = 0
    constant integer SRPickupSpawner_mStartTime = 1
    constant integer SRPickupSpawner_mTimer = 2
    constant integer SRPickupSpawner_mSpawnX = 3
    constant integer SRPickupSpawner_mSpawnY = 4
    constant integer SRPickupSpawner_mItems = 5
    constant integer SRPickupSpawner_mItemHandle = 6
    constant integer SRPickupSpawner_mDebugTime = 7
    constant integer SRPickupSpawner_mDebugHasItem = 8

    constant integer SRPickupSpawner_MAX_MEMBER = 9
endglobals

function SRPickupSpawner_Create takes real startTime, real refreshTime, integer items, real spawnX, real spawnY returns integer
    local integer self = Object_Allocate(TYPE_ID_SRPICKUP_SPAWNER, SRPickupSpawner_MAX_MEMBER)
    local timer t = null
    if IsNull(self) then
        return self
    endif

    call SaveReal(gObject, self, SRPickupSpawner_mRefreshTime, refreshTime)
    call SaveReal(gObject, self, SRPickupSpawner_mStartTime, startTime)
    call SaveTimerHandle(gObject, self, SRPickupSpawner_mTimer, CreateTimer())
    call SaveInteger(gObject, self, SRPickupSpawner_mItems, items)
    call SaveReal(gObject, self, SRPickupSpawner_mSpawnX, spawnX)
    call SaveReal(gObject, self, SRPickupSpawner_mSpawnY, spawnY)
    call SaveItemHandle(gObject, self, SRPickupSpawner_mItemHandle, null)
    call SaveReal(gObject, self, SRPickupSpawner_mDebugTime, 0.0)
    call SaveBoolean(gObject, self, SRPickupSpawner_mDebugHasItem, false)

    set t = LoadTimerHandle(gObject, self, SRPickupSpawner_mTimer)
    call TimerStart(t, startTime, false, null)
    set t = null
    return self
endfunction

function SRPickupSpawner_ReleaseItem takes integer self returns nothing
    if not SelfCheck(self, TYPE_ID_SRPICKUP_SPAWNER, "SRPickupSpawner_ReleaseItem") then
        return
    endif
    call SetItemUserData(LoadItemHandle(gObject, self, SRPickupSpawner_mItemHandle), INVALID)
    call RemoveSavedHandle(gObject, self, SRPickupSpawner_mItemHandle)
    call SaveItemHandle(gObject, self, SRPickupSpawner_mItemHandle, null)
    call TimerStart(LoadTimerHandle(gObject, self, SRPickupSpawner_mTimer), LoadReal(gObject, self, SRPickupSpawner_mRefreshTime), false, null)
endfunction