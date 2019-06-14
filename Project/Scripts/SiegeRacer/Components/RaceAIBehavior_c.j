
function RaceAIBehavior_Destroy takes nothing returns nothing
    local integer self = Component_gDestructorArg_Self

    call RemoveSavedBoolean(gObject, self, RaceAIBehavior_mLogged)
    call Object_Free(self)
endfunction

function RaceAIBehavior_Update takes nothing returns nothing
    local integer self = Component_gUpdateArg_Self
    local integer unitData = LoadInteger(gObject, self, Component_mParent)
    local integer playerData = LoadInteger(gObject, unitData, UnitData_mPlayerData)
    local integer playerComp = PlayerData_GetComponent(playerData, TYPE_ID_SRPLAYER_COMPONENT)
    local integer checkPointIndex = LoadInteger(gObject, playerComp, SRPlayerComponent_mCheckPointIndex)
    local boolean logged = LoadBoolean(gObject, self, RaceAIBehavior_mLogged)
    local unit unitHandle = LoadUnitHandle(gObject, unitData, UnitData_mHandle)


    if not logged then
        call Breakpoint("RaceAIBehavior::Update")
        call DebugLog(LOG_INFO, "UnitData=" + I2S(unitData))
        call DebugLog(LOG_INFO, "PlayerData=" + I2S(playerData))
        call DebugLog(LOG_INFO, "PlayerComponent=" + I2S(playerComp))
    endif

    call IssuePointOrder(unitHandle, "move", GetRectCenterX(SRGame_gCheckpoints[checkPointIndex]), GetRectCenterY(SRGame_gCheckpoints[checkPointIndex]))
    call SaveBoolean(gObject, self, RaceAIBehavior_mLogged, true)

    set unitHandle = null
endfunction