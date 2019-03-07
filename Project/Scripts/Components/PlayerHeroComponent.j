
// When the player dies start a timer and revive them.
//
// DECLARE_TYPE(PlayerHeroComponent,1000,1000)
globals
    constant integer PlayerHeroComponent_mTimer = Component_MAX_MEMBER + 0
    constant integer PlayerHeroComponent_mTimerDialog = Component_MAX_MEMBER + 1

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
    call SaveTimerHandle(gObject, self, PlayerHeroComponent_mTimer, null)
    call SaveTimerDialogHandle(gObject, self, PlayerHeroComponent_mTimerDialog, null)

    return self
endfunction

function PlayerHeroComponent_Destroy takes nothing returns nothing
    local integer self = Component_gDestructorArg_Self
    local timer mTimer = LoadTimerHandle(gObject, self, PlayerHeroComponent_mTimer)
    local timerdialog mTimerDialog = LoadTimerDialogHandle(gObject, self, PlayerHeroComponent_mTimerDialog)

    if mTimer != null then
        call DestroyTimer(mTimer)
        set mTimer = null
    endif

    if mTimerDialog != null then
        call DestroyTimerDialog(mTimerDialog)
        set mTimer = null
    endif

    call RemoveSavedHandle(gObject, self, PlayerHeroComponent_mTimer)
    call RemoveSavedHandle(gObject, self, PlayerHeroComponent_mTimerDialog)
    call Object_Free(self)
endfunction

function PlayerHeroComponent_GetRespawnTime takes integer self returns real
    return 5.0
endfunction

function PlayerHeroComponent_Update takes nothing returns nothing
    local integer self = Component_gUpdateArg_Self
    local integer mUnitData = LoadInteger(gObject, self, Component_mParent)
    local unit mUnit = LoadUnitHandle(gObject, mUnitData, UnitData_mHandle)
    local timer mTimer = null
    local timerdialog mTimerDialog = null

    if IsUnitDeadBJ(mUnit) then
        set mTimer = LoadTimerHandle(gObject, self, PlayerHeroComponent_mTimer)
        if mTimer == null then
            call DebugLog(LOG_INFO, "Detected hero unit death")
            set mTimer = CreateTimer()
            call TimerStart(mTimer, PlayerHeroComponent_GetRespawnTime(self), false, null)
            call SaveTimerHandle(gObject, self, PlayerHeroComponent_mTimer, mTimer)
            set mTimerDialog = CreateTimerDialog(mTimer)
            call TimerDialogSetTitle(mTimerDialog, "Hero Respawn:")
            call TimerDialogDisplay(mTimerDialog, true)
            call SaveTimerDialogHandle(gObject, self, PlayerHeroComponent_mTimerDialog, mTimerDialog)
        elseif TimerGetRemaining(mTimer) <= 0.0 then
            set mTimerDialog = LoadTimerDialogHandle(gObject, self, PlayerHeroComponent_mTimerDialog)
            call DestroyTimerDialog(mTimerDialog)
            call SaveTimerDialogHandle(gObject, self, PlayerHeroComponent_mTimerDialog, null)
            call ReviveHero(mUnit, GetRectCenterX(gg_rct_HeroRespawn) , GetRectCenterY(gg_rct_HeroRespawn), true)
            call DestroyTimer(mTimer)
            call SaveTimerHandle(gObject, self, PlayerHeroComponent_mTimer, null)
            call SetCameraPositionForPlayer(GetOwningPlayer(mUnit), GetRectCenterX(gg_rct_HeroRespawn) , GetRectCenterY(gg_rct_HeroRespawn))
        endif
    endif
    
    set mTimer = null
    set mTimerDialog = null
    set mUnit = null
endfunction
