// -debug component.view
// -debug 

function CmdDebug_GetSelectedUnits takes player p returns integer
    local group selectedUnits = GetUnitsSelectedAll(p)
    local integer unitData = GetUnitId(FirstOfGroup(selectedUnits))
    call DestroyGroup(selectedUnits)
    set selectedUnits = null
    return unitData
endfunction

function CmdDebug_ComponentView takes nothing returns nothing
    local integer unitData = CmdDebug_GetSelectedUnits(Cmd_GetEventPlayer())
    local integer mComponents = INVALID
    local integer mComponents_mSize = 0
    local integer i = 0
    local integer component = INVALID
    if IsNull(unitData) then
        call DebugLog(LOG_INFO, "Missing unit data")
        return
    endif
    call DebugLog(LOG_INFO, "Showing Components for [" + I2S(unitData) + "]")
    set mComponents = UnitData_GetComponents(unitData)
    set mComponents_mSize = List_GetSize(mComponents)
    loop
        exitwhen i >= mComponents_mSize
        set component = List_GetObject(mComponents, i)
        call DebugLog(LOG_INFO, "[" + I2S(component) + "] " + Object_GetTypeName(Object_GetTypeId(component)))
        set i = i + 1
    endloop
endfunction

function CmdDebug_SetLevel takes integer level returns nothing
    local integer unitData = CmdDebug_GetSelectedUnits(Cmd_GetEventPlayer())
    local unit u = null

    if IsNull(unitData) then
        return
    endif
    
    call DebugLog(LOG_INFO, "Set Level to " + I2S(level))
    if UnitTypeData_IsHero(LoadInteger(gObject, unitData, UnitData_mTypeData)) then
        set u = LoadUnitHandle(gObject, unitData, UnitData_mHandle)
        call SetHeroLevel(u, level, true)
    endif
    set u = null
endfunction

function CmdDebug_Help takes nothing returns nothing
    call DebugLog(LOG_INFO, "Available Commands")
    call DebugLog(LOG_INFO, "-debug component.view : Shows the list of components on the selected unit.")
endfunction

function CmdDebug_AddWatch takes integer eventArgs returns nothing
    local string name = Cmd_GetString(eventArgs, 3)
    local string address = Cmd_GetString(eventArgs, 4)
    local string member = Cmd_GetString(eventArgs, 5)
    local string typeID = StringCase(Cmd_GetString(eventArgs, 6), false)

// -debug watch add <name> <address> <member> <type:integer>
//    -     1    2    3        4        5          6
    if typeID == "" then
        set typeID = "int"
    endif


    if typeID != "int" and typeID != "integer" and typeID != "real" and typeID != "string" and typeID != "object" then
        call DebugLog(LOG_INFO, "'debug watch add' expects the type to be one of the following: 'int' 'real' 'string' or 'object'")
        return
    endif

    if name == "" then
        call DebugLog(LOG_INFO, "'debug watch add' expects <name> <address> <member>, missing 'name'")
        return
    endif

    if address == "" then
        call DebugLog(LOG_INFO, "'debug watch add' expects <name> <address> <member>, missing 'address'")
        return
    endif

    if member == "" then
        call DebugLog(LOG_INFO, "'debug watch add' expects <name> <address> <member>, missing 'member'")
        return
    endif

    if typeID == "int" or typeID == "integer" then
        set typeID = Debug_GetTypeString(DEBUG_TYPE_INTEGER)
    elseif typeID == "real" then
        set typeID = Debug_GetTypeString(DEBUG_TYPE_REAL)
    elseif typeID == "string" then
        set typeID = Debug_GetTypeString(DEBUG_TYPE_STRING)
    elseif typeID == "object" then
        set typeID = Debug_GetTypeString(DEBUG_TYPE_OBJECT)
    endif

    call Debug_AddWatch(name, S2I(address), S2I(member), typeID)
endfunction

function CmdDebug_RemoveWatch takes integer eventArgs returns nothing
    local string index = Cmd_GetString(eventArgs, 3)
    if index == "" then
        call DebugLog(LOG_INFO, "debug watch remove missing argument <index>.")
        return
    endif
    call Debug_RemoveWatchAt(S2I(index))
endfunction

function CmdDebug_ClearWatch takes nothing returns nothing
    set gDebugWatchCount = 0
endfunction

function CmdProc_Debug takes nothing returns nothing
    local integer eventArgs = Cmd_GetEventArgs()
    if CmdMatch("component.view", 1, eventArgs) then
        call CmdDebug_ComponentView()
    elseif CmdMatch("setlevel", 1, eventArgs) then
        if List_GetSize(eventArgs) >= 3 then
            call CmdDebug_SetLevel(S2I(List_GetString(eventArgs, 2)))
        else
            call DebugLog(LOG_INFO, "Missing arg <level>")
        endif
    elseif CmdMatch("help", 1, eventArgs) then
        call CmdDebug_Help()
    elseif CmdMatch("fastpick", 1, eventArgs) then
        if gGameState == GS_HERO_PICK and TimerGetRemaining(GameState_HeroPick_gTimer) > 15.0 then
            call TimerStart(GameState_HeroPick_gTimer, 15.0, false, null)
        endif
    elseif CmdMatch("watch", 1, eventArgs) then
        if CmdMatch("show", 2, eventArgs) then
            call Debug_ShowWatch()
        elseif CmdMatch("hide", 2, eventArgs) then
            call Debug_HideWatch()
        elseif CmdMatch("add", 2, eventArgs) then
            call CmdDebug_AddWatch(eventArgs)
        elseif CmdMatch("remove", 2, eventArgs) then
            call CmdDebug_RemoveWatch(eventArgs)
        elseif CmdMatch("clear", 2, eventArgs) then
            call CmdDebug_ClearWatch()
        else
            call DebugLog(LOG_INFO, "Invalid argument for 'debug watch' command. Use either 'show' or 'hide'")
        endif
    elseif CmdMatch("thread", 1, eventArgs) then
        if CmdMatch("show", 2, eventArgs) then
            call Debug_ShowThreadView()
        elseif CmdMatch("hide", 2, eventArgs) then
            call Debug_HideThreadView()
        endif
    else
        call CmdDebug_Help()
    endif

endfunction

function CmdDebug_Init takes nothing returns nothing
    call Cmd_RegisterHandler("-debug", function CmdProc_Debug)

endfunction