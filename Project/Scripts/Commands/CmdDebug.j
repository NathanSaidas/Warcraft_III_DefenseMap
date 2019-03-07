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
    else
        call CmdDebug_Help()
    endif

endfunction

function CmdDebug_Init takes nothing returns nothing
    call Cmd_RegisterHandler("-debug", function CmdProc_Debug)

endfunction