
function SRPickupSpawner_CreatePickup takes integer self returns nothing
    local integer items = LoadInteger(gObject, self, SRPickupSpawner_mItems)
    local integer items_mSize = List_GetSize(items)
    local integer random = GetRandomInt(0, items_mSize-1)
    local integer itemId = List_GetInt(items, random)
    local item pickUp = null 

    if LoadItemHandle(gObject, self, SRPickupSpawner_mItemHandle) == null then
        set pickUp = CreateItem(itemId, LoadReal(gObject, self, SRPickupSpawner_mSpawnX), LoadReal(gObject, self, SRPickupSpawner_mSpawnY))
        call SetItemUserData(pickUp, self)
        call SaveItemHandle(gObject, self, SRPickupSpawner_mItemHandle, pickUp)
        set pickUp = null
    endif
endfunction

function SRPickupSpawner_Update takes integer self returns nothing
    local timer mTimer = LoadTimerHandle(gObject, self, SRPickupSpawner_mTimer)
    call SaveReal(gObject, self, SRPickupSpawner_mDebugTime, TimerGetRemaining(mTimer))
    call SaveBoolean(gObject, self, SRPickupSpawner_mDebugHasItem, LoadItemHandle(gObject, self, SRPickupSpawner_mItemHandle) != null)

    if TimerGetRemaining(mTimer) <= 0.0 then
        call SRPickupSpawner_CreatePickup(self)
    endif
    set mTimer = null
endfunction