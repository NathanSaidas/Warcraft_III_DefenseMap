globals
    constant integer DEBUG_TYPE_INTEGER = 0
    constant integer DEBUG_TYPE_REAL = 1
    constant integer DEBUG_TYPE_STRING = 2
    constant integer DEBUG_TYPE_OBJECT = 3

    integer gDebugRestoreMultiboard = INVALID
    string array gDebugWatchVariables
    integer array gDebugWatchAddresses
    integer array gDebugWatchMemberIndices
    integer array gDebugWatchTypes
    integer gDebugWatchCount = 0
endglobals

function Debug_PreInit takes nothing returns nothing
    call DisplayBoard_Create(MULTIBOARD_OBJECT_WATCH, 1, 4, "Debug Watch Window")
endfunction

function Debug_SaveDisplayBoard takes nothing returns nothing
    if DisplayBoard_GetCurrent() != MULTIBOARD_OBJECT_WATCH then
        set gDebugRestoreMultiboard = DisplayBoard_GetCurrent()
    endif
endfunction

function Debug_GetValueString takes integer addr, integer member, integer typeID returns string
    if typeID == DEBUG_TYPE_INTEGER then
        return I2S(LoadInteger(gObject, addr, member))
    elseif typeID == DEBUG_TYPE_REAL then
        return R2S(LoadReal(gObject, addr, member))
    elseif typeID == DEBUG_TYPE_STRING then
        return LoadStr(gObject, addr, member)
    else
        return "{}"
    endif
endfunction

function Debug_GetTypeString takes integer typeID returns string
    if typeID == DEBUG_TYPE_INTEGER then
        return "Integer"
    elseif typeID == DEBUG_TYPE_REAL then
        return "Real"
    elseif typeID == DEBUG_TYPE_STRING then
        return "String"
    else
        return "Object"
    endif
endfunction

function Debug_GetTypeFromString takes string typeID returns integer
    if typeID == "Integer" then
        return DEBUG_TYPE_INTEGER
    elseif typeID == "Real" then
        return DEBUG_TYPE_REAL
    elseif typeID == "String" then
        return DEBUG_TYPE_STRING
    else
        return DEBUG_TYPE_OBJECT
    endif
endfunction

function Debug_UpdateWatchValues takes nothing returns nothing
    local integer i = 0

    loop
        exitwhen i >= gDebugWatchCount
        
        call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 0, i + 1, 15.0, gDebugWatchVariables[i], MULTIBOARD_COLOR_WHITE)
        call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 1, i + 1, 8.0, I2S(gDebugWatchAddresses[i]), MULTIBOARD_COLOR_WHITE)
        call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 2, i + 1, 8.0, Debug_GetValueString(gDebugWatchAddresses[i], gDebugWatchMemberIndices[i], gDebugWatchTypes[i]), MULTIBOARD_COLOR_WHITE)
        call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 3, i + 1, 8.0, Debug_GetTypeString(gDebugWatchTypes[i]), MULTIBOARD_COLOR_WHITE)

        set i = i + 1
    endloop

endfunction

function Debug_Update takes nothing returns nothing
    if DisplayBoard_GetCurrent() == MULTIBOARD_OBJECT_WATCH then
        call DisplayBoard_Hide()
        call DisplayBoard_SetRowCount(MULTIBOARD_OBJECT_WATCH, 1 + gDebugWatchCount)
        call Debug_UpdateWatchValues()
        call DisplayBoard_Show(MULTIBOARD_OBJECT_WATCH, true)
    endif
endfunction

function Debug_ShowWatch takes nothing returns nothing
    if DisplayBoard_GetCurrent() == MULTIBOARD_OBJECT_WATCH then
        return
    endif
    call Debug_SaveDisplayBoard()
    call DisplayBoard_Hide()

    call DisplayBoard_SetRowCount(MULTIBOARD_OBJECT_WATCH, 1 + gDebugWatchCount)
    call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 0, 0, 15.0, "Variable", MULTIBOARD_COLOR_TITLE_YELLOW)
    call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 1, 0, 8.0, "Address", MULTIBOARD_COLOR_TITLE_YELLOW)
    call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 2, 0, 8.0, "Value", MULTIBOARD_COLOR_TITLE_YELLOW)
    call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 3, 0, 8.0, "Type", MULTIBOARD_COLOR_TITLE_YELLOW)

    call Debug_UpdateWatchValues()

    call DisplayBoard_Show(MULTIBOARD_OBJECT_WATCH, true)
endfunction

function Debug_HideWatch takes nothing returns nothing
    if gDebugRestoreMultiboard != INVALID then
        call DisplayBoard_Show(gDebugRestoreMultiboard, true)
    else
        call DisplayBoard_Hide()
    endif
endfunction

function Debug_AddWatch takes string variableName, integer address, integer memberIndex, string typeIDStr returns nothing
    local integer typeID = Debug_GetTypeFromString(typeIDStr)
    local integer i = gDebugWatchCount
    
    set gDebugWatchVariables[i] = variableName
    set gDebugWatchAddresses[i] = address
    set gDebugWatchMemberIndices[i] = memberIndex
    set gDebugWatchTypes[i] = typeID
    set gDebugWatchCount = gDebugWatchCount + 1
endfunction

function Debug_RemoveWatchAt takes integer i returns nothing
    if i >= gDebugWatchCount then
        return
    endif

    loop
        exitwhen i >= gDebugWatchCount

        set gDebugWatchVariables[i] = gDebugWatchVariables[i + 1]
        set gDebugWatchAddresses[i] = gDebugWatchAddresses[i + 1]
        set gDebugWatchMemberIndices[i] = gDebugWatchMemberIndices[i + 1]
        set gDebugWatchTypes[i] = gDebugWatchTypes[i+ 1]
        set i = i + 1
    endloop

    set gDebugWatchCount = gDebugWatchCount - 1
endfunction

function Debug_RemoveWatch takes string variableName returns nothing
    local integer i = 0
    loop
        exitwhen i >= gDebugWatchCount
        if gDebugWatchVariables[i] == variableName then
            call Debug_RemoveWatchAt(i)
            return
        endif
        set i = i + 1
    endloop
endfunction