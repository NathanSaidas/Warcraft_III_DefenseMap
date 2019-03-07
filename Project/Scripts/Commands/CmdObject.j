function CmdProc_Object_GetInstanceCount takes integer typeId returns integer
    local integer instanceCount = 0
    local integer begin = LoadInteger(gObject, typeId, ps_Object_Offset)
    local integer end = begin + LoadInteger(gObject, typeId, ps_Object_MaxInstances)
    loop
        exitwhen begin >= end
        if LoadBoolean(gObject, begin, p_Object_LoadFlag) then
            set instanceCount = instanceCount + 1
        endif
        set begin = begin + 1
    endloop
    return instanceCount
endfunction

function p_CmdProc_Object_InstanceCount takes string statMeta returns nothing
    local integer typeId = 0
    local integer i = 0
    local integer maxTypeId = TYPE_ID_MAX

    local integer instanceCount = 0
    local integer begin = 0
    local integer end = 0

    if statMeta != "all" and statMeta != "" then
        loop
            exitwhen i >= maxTypeId
            if Object_GetTypeName(i) == statMeta then
                exitwhen true
            endif
            set i = i + 1
        endloop

        if i >= maxTypeId then
            call DebugLog(LOG_INFO, "Invalid type name.")
            return
        endif

        set begin = LoadInteger(gObject, i, ps_Object_Offset)
        set end = begin + LoadInteger(gObject, i, ps_Object_MaxInstances)
        loop
            exitwhen begin >= end
            if LoadBoolean(gObject, begin, p_Object_LoadFlag) then
                set instanceCount = instanceCount + 1
            endif
            set begin = begin + 1
        endloop
        call DebugLog(LOG_INFO, "InstanceCount for " + statMeta + " = " + I2S(instanceCount))
    else
        loop
            exitwhen i >= maxTypeId
            
            set instanceCount = 0
            set begin = LoadInteger(gObject, i, ps_Object_Offset)
            set end = begin + LoadInteger(gObject, i, ps_Object_MaxInstances)
            loop
                exitwhen begin >= end
                if HaveSavedBoolean(gObject, begin, p_Object_LoadFlag) and LoadBoolean(gObject, begin, p_Object_LoadFlag) then
                    set instanceCount = instanceCount + 1
                endif
                set begin = begin + 1
            endloop

            call DebugLog(LOG_INFO, "InstanceCount for " + Object_GetTypeName(i) + " = " + I2S(instanceCount))

            set i = i + 1
        endloop
    endif
endfunction

function p_CmdProc_Object_InstanceReport takes string statMeta returns nothing
    local integer typeId = 0
    local integer i = 0
    local integer maxTypeId = TYPE_ID_MAX

    local integer instanceCount = 0
    local integer begin = 0
    local integer end = 0


    loop
        exitwhen i >= maxTypeId
        if Object_GetTypeName(i) == statMeta then
            exitwhen true
        endif
        set i = i + 1
    endloop

    if i >= maxTypeId then
        call DebugLog(LOG_INFO, "Invalid type name.")
        return
    endif

    set begin = LoadInteger(gObject, i, ps_Object_Offset)
    set end = begin + LoadInteger(gObject, i, ps_Object_MaxInstances)
    loop
        exitwhen begin >= end
        if LoadBoolean(gObject, begin, p_Object_LoadFlag) then
            call DebugLog(LOG_INFO, Object_GetFormattedName(begin))
        endif
        set begin = begin + 1
    endloop
endfunction

function p_CmdProc_Object_ListTypes takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= TYPE_ID_MAX
        call DebugLog(LOG_INFO, Object_GetTypeName(i) + ": Id=" + I2S(i))
        set i = i + 1
    endloop
endfunction

function p_CmdProc_Object_DisplayStat takes integer eventArgs returns nothing
    local string statType = ""
    local string statMeta = ""
    local integer size = List_GetSize(eventArgs)

    if size >= 3 then
        set statType = List_GetString(eventArgs, 2)
    endif
    if size >= 4 then
        set statMeta = List_GetString(eventArgs, 3)
    endif
    call DebugLog(LOG_INFO, "Display stat: " + statType + " : " + statMeta)

    if statType == "type_count" then
        call DebugLog(LOG_INFO, "TypeCount=" + I2S(Abs(TYPE_ID_NATIVE_MAX) + Abs(TYPE_ID_MAX)))
    elseif statType == "instance_count" then
        call p_CmdProc_Object_InstanceCount(statMeta)
    elseif statType == "instance_report" then
        call p_CmdProc_Object_InstanceReport(statMeta)
    endif
endfunction

function p_CmdProc_Object_GetString takes integer eventArgs returns nothing
    local string addressStr = ""
    local string memberStr = ""
    local string value = ""
    local integer size = List_GetSize(eventArgs)

    if size >= 3 then
        set addressStr = List_GetString(eventArgs, 2)
    endif

    if size >= 4 then
        set memberStr = List_GetString(eventArgs, 3)
    endif

    set value = LoadStr(gObject, S2I(addressStr), S2I(memberStr))
    if HaveSavedString(gObject, S2I(addressStr), S2I(memberStr)) then
        call DebugLog(LOG_INFO, "SET [" + addressStr + "]->[" + memberStr + "] = " + value)
    else
        call DebugLog(LOG_INFO, "UNSET [" + addressStr + "]->[" + memberStr + "] = " + value)
    endif
endfunction

function p_CmdProc_Object_GetInteger takes integer eventArgs returns nothing
    local string addressStr = ""
    local string memberStr = ""
    local string value = ""
    local integer size = List_GetSize(eventArgs)

    if size >= 3 then
        set addressStr = List_GetString(eventArgs, 2)
    endif

    if size >= 4 then
        set memberStr = List_GetString(eventArgs, 3)
    endif

    set value = I2S(LoadInteger(gObject, S2I(addressStr), S2I(memberStr)))
    if HaveSavedInteger(gObject, S2I(addressStr), S2I(memberStr)) then
        call DebugLog(LOG_INFO, "SET [" + addressStr + "]->[" + memberStr + "] = " + value)
    else
        call DebugLog(LOG_INFO, "UNSET [" + addressStr + "]->[" + memberStr + "] = " + value)
    endif
endfunction

function p_CmdProc_Object_GetBool takes integer eventArgs returns nothing
    local string addressStr = ""
    local string memberStr = ""
    local string value = ""
    local integer size = List_GetSize(eventArgs)

    if size >= 3 then
        set addressStr = List_GetString(eventArgs, 2)
    endif

    if size >= 4 then
        set memberStr = List_GetString(eventArgs, 3)
    endif

    set value = B2S(LoadBoolean(gObject, S2I(addressStr), S2I(memberStr)))
    if HaveSavedBoolean(gObject, S2I(addressStr), S2I(memberStr)) then
        call DebugLog(LOG_INFO, "SET [" + addressStr + "]->[" + memberStr + "] = " + value)
    else
        call DebugLog(LOG_INFO, "UNSET [" + addressStr + "]->[" + memberStr + "] = " + value)
    endif
endfunction

function p_CmdProc_Object_Find takes integer eventArgs returns nothing
    local string typeStr = ""
    local string memberStr = ""
    local string value = ""
    local integer size = List_GetSize(eventArgs)
    local integer objId = INVALID

    if size >= 3 then
        set typeStr = List_GetString(eventArgs, 2)
    endif

    if size >= 4 then
        set memberStr = List_GetString(eventArgs, 3)
    endif

    if size >= 5 then
        set value = List_GetString(eventArgs, 4)
    endif

    if size >= 5 then
        set objId = Object_FindByString(S2I(typeStr), S2I(memberStr), value)
        call DebugLog(LOG_INFO, "FindByString = " + I2S(objId))
    endif

endfunction

function p_CmdProc_Object_Log takes integer eventArgs returns nothing
    local string addressStr = ""
    local string value = ""
    local integer size = List_GetSize(eventArgs)
    local integer addr = INVALID
    local integer i = 0
    local integer maxMember = 0
    local integer typeId = INVALID

    if size >= 3 then
        set addressStr = List_GetString(eventArgs, 2)
        set addr = S2I(addressStr)
        set typeId = Object_GetTypeId(addr)
    endif

    if not IsNull(addr) and typeId > 0 then
        // iterate all members addr
        set maxMember = LoadInteger(gObject, addr, p_Object_MemberSize)
        call DebugLog(LOG_INFO, Object_GetFormattedName(addr) + " : " + Object_GetTypeName(typeId))
        loop
            exitwhen i >= maxMember
            call DebugLog(LOG_INFO, Object_GetFormattedMember(addr, i))
            set i = i + 1
        endloop
    endif
endfunction

globals
    multiboard gObjectWatch = null
    multiboard gThreadWatch = null
endglobals

function CmdProc_Object_UpdateWatch takes nothing returns nothing
    local integer driver = Thread_GetDriver("CmdProc_Object_UpdateWatch")
    local integer i = 0
    local integer numRows = TYPE_ID_MAX + 1

    loop
        call Thread_UpdateTick(driver)
        if DisplayBoard_GetCurrent() == MULTIBOARD_OBJECT_WATCH then
            set i = 1
            loop
                exitwhen i >= numRows
                call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 0, i, 10.00, Object_GetTypeName(i-1), MULTIBOARD_COLOR_WHITE)
                call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 1, i, 5.00, I2S(CmdProc_Object_GetInstanceCount(i-1)), MULTIBOARD_COLOR_WHITE)
                set i = i + 1
            endloop
        endif
        call Sleep(GAME_DELTA)
    endloop
endfunction

function CmdProc_Object_Watch takes nothing returns nothing
    local integer numColumns = 2
    local integer numRows = TYPE_ID_MAX + 1
    local integer i = 1

    if DisplayBoard_GetCurrent() != MULTIBOARD_OBJECT_WATCH then
        call DisplayBoard_SetRowCount(MULTIBOARD_OBJECT_WATCH, numRows)
        call DisplayBoard_SetColumnCount(MULTIBOARD_OBJECT_WATCH, numColumns)
        call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 0, 0, 10.00, "Type Name", MULTIBOARD_COLOR_TITLE_YELLOW)
        call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 1, 0, 5.00, "Count", MULTIBOARD_COLOR_TITLE_YELLOW)
        set i = 1
        loop
            exitwhen i >= numRows
            call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 0, i, 10.00, Object_GetTypeName(i-1), MULTIBOARD_COLOR_WHITE)
            call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 1, i, 5.00, I2S(CmdProc_Object_GetInstanceCount(i-1)), MULTIBOARD_COLOR_WHITE)
            set i = i + 1
        endloop
        call DisplayBoard_Show(MULTIBOARD_OBJECT_WATCH, true)
    else
        call DisplayBoard_Hide()
    endif
endfunction

function CmdProc_Object_ThreadWatchUpdate takes nothing returns nothing
    local integer driver = Thread_GetDriver("CmdProc_Object_ThreadWatchUpdate")
    local integer i = 2
    local integer numRows = 0
    local integer drivers = LoadInteger(gObject, gThread, Thread_mDrivers)
    local integer current = INVALID
    local integer delta = 0

    loop
        call Thread_UpdateTick(driver)

        if DisplayBoard_GetCurrent() == MULTIBOARD_THREAD_WATCH then
            set i = 1
            set numRows = List_GetSize(drivers) + 1
            if DisplayBoard_GetRowCount(MULTIBOARD_THREAD_WATCH) != numRows then
                call DisplayBoard_SetRowCount(MULTIBOARD_THREAD_WATCH, numRows)
            endif
            loop
                exitwhen i >= numRows
                set current = List_GetObject(drivers, i -1)
                set delta = Abs( LoadInteger(gObject, current, ThreadDriver_mLocalTick) - LoadInteger(gObject, current, ThreadDriver_mMainTick)) 

                call DisplayBoard_SetTextItem(MULTIBOARD_THREAD_WATCH, 0, i, 20.00, LoadStr(gObject, current, p_Object_Name), MULTIBOARD_COLOR_WHITE)
                call DisplayBoard_SetTextItem(MULTIBOARD_THREAD_WATCH, 1, i, 7.00, I2S(LoadInteger(gObject, current, ThreadDriver_mLocalTick)), MULTIBOARD_COLOR_WHITE)
                call DisplayBoard_SetTextItem(MULTIBOARD_THREAD_WATCH, 2, i, 7.00, I2S(LoadInteger(gObject, current, ThreadDriver_mMainTick)), MULTIBOARD_COLOR_WHITE)
                call DisplayBoard_SetTextItem(MULTIBOARD_THREAD_WATCH, 3, i, 7.00, I2S(delta), MULTIBOARD_COLOR_WHITE)
                call DisplayBoard_SetTextItem(MULTIBOARD_THREAD_WATCH, 4, i, 7.00, B2S(LoadBoolean(gObject, current, ThreadDriver_mRunning)), MULTIBOARD_COLOR_WHITE)
                set i = i + 1
            endloop
        endif
        call Sleep(GAME_DELTA)
    endloop
endfunction

function CmdProc_Object_ThreadWatch takes nothing returns nothing
    // <Thread Name>, <LocalTick>, <Tick>, <Delta> <Running>
    local integer numColumns = 5
    local integer numRows = 0
    local integer drivers = INVALID 
    local integer i = 0
    local integer current = INVALID
    local integer delta = 0

    if DisplayBoard_GetCurrent() != MULTIBOARD_THREAD_WATCH then
        set drivers = LoadInteger(gObject, gThread, Thread_mDrivers)
        set numRows = List_GetSize(drivers) + 1
        call DisplayBoard_SetRowCount(MULTIBOARD_THREAD_WATCH, numRows)
        call DisplayBoard_SetColumnCount(MULTIBOARD_THREAD_WATCH, numColumns)
        call DisplayBoard_SetTextItem(MULTIBOARD_THREAD_WATCH, 0, 0, 20.00, "Thread Name", MULTIBOARD_COLOR_TITLE_YELLOW)
        call DisplayBoard_SetTextItem(MULTIBOARD_THREAD_WATCH, 1, 0, 7.00, "Local Tick", MULTIBOARD_COLOR_TITLE_YELLOW)
        call DisplayBoard_SetTextItem(MULTIBOARD_THREAD_WATCH, 2, 0, 7.00, "Tick", MULTIBOARD_COLOR_TITLE_YELLOW)
        call DisplayBoard_SetTextItem(MULTIBOARD_THREAD_WATCH, 3, 0, 7.00, "Delta", MULTIBOARD_COLOR_TITLE_YELLOW)
        call DisplayBoard_SetTextItem(MULTIBOARD_THREAD_WATCH, 4, 0, 7.00, "Running", MULTIBOARD_COLOR_TITLE_YELLOW)
        set i = 1
        loop
            exitwhen i >= numRows
            set current = List_GetObject(drivers, i - 1)
            set delta = Abs( LoadInteger(gObject, current, ThreadDriver_mLocalTick) - LoadInteger(gObject, current, ThreadDriver_mMainTick)) 

            call DisplayBoard_SetTextItem(MULTIBOARD_THREAD_WATCH, 0, i, 20.00, LoadStr(gObject, current, p_Object_Name), MULTIBOARD_COLOR_WHITE)
            call DisplayBoard_SetTextItem(MULTIBOARD_THREAD_WATCH, 1, i, 7.00, I2S(LoadInteger(gObject, current, ThreadDriver_mLocalTick)), MULTIBOARD_COLOR_WHITE)
            call DisplayBoard_SetTextItem(MULTIBOARD_THREAD_WATCH, 2, i, 7.00, I2S(LoadInteger(gObject, current, ThreadDriver_mMainTick)), MULTIBOARD_COLOR_WHITE)
            call DisplayBoard_SetTextItem(MULTIBOARD_THREAD_WATCH, 3, i, 7.00, I2S(delta), MULTIBOARD_COLOR_WHITE)
            call DisplayBoard_SetTextItem(MULTIBOARD_THREAD_WATCH, 4, i, 7.00, B2S(LoadBoolean(gObject, current, ThreadDriver_mRunning)), MULTIBOARD_COLOR_WHITE)
            set i = i + 1
        endloop
        call DisplayBoard_Show(MULTIBOARD_THREAD_WATCH, true)
    else
        call DisplayBoard_Hide()
    endif
endfunction

// -object help
// -object stat type_count : Shows how many types there are
// -object stat instance_count <type|all> : Shows how many instances there are
// -object stat instance_report <type|all> : Lists the instance Ids
// -object list_types : Shows all type names
// -object get_string  : <address> : <member id>
// -object get_bool    : <address> : <member id>
// -object get_integer : <address> : <member id>
// -object find <type> <member> <value>
// -object log <address>
function CmdProc_Object takes nothing returns nothing
    local integer eventArgs = Cmd_GetEventArgs()
    call DebugLog(LOG_INFO, "CmdProc_Object invoked")
    if CmdMatch("stat", 1, eventArgs) then
        call p_CmdProc_Object_DisplayStat(eventArgs)
    elseif CmdMatch("list_types", 1, eventArgs) then
        call p_CmdProc_Object_ListTypes()
    elseif CmdMatch("get_string", 1, eventArgs) then
        call p_CmdProc_Object_GetString(eventArgs)
    elseif CmdMatch("get_bool", 1, eventArgs) then
        call p_CmdProc_Object_GetBool(eventArgs)
    elseif CmdMatch("get_integer", 1, eventArgs) then
        call p_CmdProc_Object_GetInteger(eventArgs)
    elseif CmdMatch("find", 1, eventArgs) then
        call p_CmdProc_Object_Find(eventArgs)
    elseif CmdMatch("log", 1, eventArgs) then
        call p_CmdProc_Object_Log(eventArgs)
    elseif CmdMatch("help", 1, eventArgs) then
        call DebugLog(LOG_INFO, "Usage Examples:")
        call DebugLog(LOG_INFO, "-object stat type_count : Shows how many types are there")
        call DebugLog(LOG_INFO, "-object stat instance_count <type|all> : Shows how many instances there are")
        call DebugLog(LOG_INFO, "-object stat instance_report <type|all> : Lists the instance Ids")
        call DebugLog(LOG_INFO, "-object list_types : Shows all type names")
        call DebugLog(LOG_INFO, "-object get_string  : <address> : <member id>")
        call DebugLog(LOG_INFO, "-object get_bool    : <address> : <member id>")
        call DebugLog(LOG_INFO, "-object get_integer : <address> : <member id>")
        call DebugLog(LOG_INFO, "-object find <type> <member> <value>")
        call DebugLog(LOG_INFO, "-object log <address>")
        call DebugLog(LOG_INFO, "-object watch <thread|instance>")
    elseif CmdMatch("watch", 1, eventArgs) then
        if CmdMatch("instance", 2, eventArgs) then
            call CmdProc_Object_Watch()
        elseif CmdMatch("thread", 2, eventArgs) then
            call CmdProc_Object_ThreadWatch()
        else
            call DebugLog(LOG_INFO, "Expected -object watch thread | -object watch instance")
        endif

    endif
endfunction

function CmdObject_Init takes nothing returns nothing
    call Cmd_RegisterHandler("-object", function CmdProc_Object)

    call DisplayBoard_Create(MULTIBOARD_OBJECT_WATCH, 1, 1, "Object Watch")
    call DisplayBoard_Create(MULTIBOARD_THREAD_WATCH, 1, 1, "Thread Watch")

    call Thread_RegisterDriver("CmdProc_Object_UpdateWatch", function CmdProc_Object_UpdateWatch)
    call Thread_StartDriver("CmdProc_Object_UpdateWatch")
    call Thread_RegisterDriver("CmdProc_Object_ThreadWatchUpdate", function CmdProc_Object_ThreadWatchUpdate)
    call Thread_StartDriver("CmdProc_Object_ThreadWatchUpdate")
endfunction