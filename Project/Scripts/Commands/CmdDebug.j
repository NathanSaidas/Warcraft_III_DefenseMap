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

function CmdDebug_Help takes nothing returns nothing
    call DebugLog(LOG_INFO, "Available Commands")
    call DebugLog(LOG_INFO, "-debug component.view : Shows the list of components on the selected unit.")
endfunction

function CmdProc_Debug takes nothing returns nothing
    local integer eventArgs = Cmd_GetEventArgs()
    if CmdMatch("component.view", 1, eventArgs) then
        call CmdDebug_ComponentView()
    elseif CmdMatch("help", 1, eventArgs) then
        call CmdDebug_Help()
    else
        call CmdDebug_Help()
    endif

endfunction

function CmdDebug_Init takes nothing returns nothing
    call Cmd_RegisterHandler("-debug", function CmdProc_Debug)

endfunction