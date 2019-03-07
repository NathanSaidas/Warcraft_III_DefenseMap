
// DECLARE_TYPE(SpawnPortal, 1000, 1000)
globals
    constant integer SpawnPortal_mX = 0
    constant integer SpawnPortal_mY = 1
    constant integer SpawnPortal_mRect = 2

    constant integer SpawnPortal_MAX_MEMBER = 3
endglobals

function SpawnPortal_Create takes rect spawnRect returns integer
    local integer self = Object_Allocate(TYPE_ID_SPAWN_PORTAL, SpawnPortal_MAX_MEMBER)
    if IsNull(self) then
        return self
    endif

    call SaveReal(gObject, self, SpawnPortal_mX, GetRectCenterX(spawnRect))
    call SaveReal(gObject, self, SpawnPortal_mY, GetRectCenterY(spawnRect))
    call SaveRectHandle(gObject, self, SpawnPortal_mRect, spawnRect)

    return self
endfunction

function SpawnPortal_CreateNpc takes integer self, integer unitTypeData returns integer
    local real x = 0.0
    local real y = 0.0
    local integer unitData = INVALID
    if IsNull(self) then
        call AccessViolation("SpawnPortal_CreateNpc")
        return unitData
    endif

    set x = LoadReal(gObject, self, SpawnPortal_mX)
    set y = LoadReal(gObject, self, SpawnPortal_mY)
    set unitData = GameRules_CreateNpc(unitTypeData, x, y)
    return unitData
endfunction