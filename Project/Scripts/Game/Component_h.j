// DECLARE_TYPE(Component,1000,1000)
globals
    constant integer Component_mDestructor = 0
    constant integer Component_mParent = 1
    constant integer Component_mUpdate = 2

    constant integer Component_MAX_MEMBER = 3

    integer Component_gDestructorArg_Self = INVALID
    integer Component_gUpdateArg_Self = INVALID
endglobals

function Component_Derive takes integer self, code destructor, code update returns nothing
    local trigger mDestructor = CreateTrigger()
    local trigger mUpdate = null

    call TriggerAddAction(mDestructor, destructor)
    if update != null then
        set mUpdate = CreateTrigger()
        call TriggerAddAction(mUpdate, update)
    endif

    call SaveTriggerHandle(gObject, self, Component_mDestructor, mDestructor)
    call SaveTriggerHandle(gObject, self, Component_mUpdate, mUpdate)
    call SaveInteger(gObject, self, Component_mParent, INVALID)
endfunction

function Component_Destroy takes integer self returns nothing
    local trigger mDestructor = LoadTriggerHandle(gObject, self, Component_mDestructor)

    call RemoveSavedHandle(gObject, self, Component_mDestructor)
    call RemoveSavedInteger(gObject, self, Component_mParent)
    call RemoveSavedHandle(gObject, self, Component_mUpdate)

    set Component_gDestructorArg_Self = self
    call TriggerExecute(mDestructor)
    set mDestructor = null
endfunction

function Component_Update takes integer self returns nothing
    local trigger mUpdate = LoadTriggerHandle(gObject, self, Component_mUpdate)
    set Component_gUpdateArg_Self = self
    call TriggerExecute(mUpdate)
    set mUpdate = null
endfunction

