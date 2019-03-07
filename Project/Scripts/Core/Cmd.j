// Command Concept:

// OnText
// Get first word
// Check for "-command" in list of commands
// If valid command:
// Parse all tokens:
// 





// struct CmdHandler
// {
//      string  mCommand
//      trigger mCallback
// }

globals
    constant integer CmdHandler_mCommand = 0
    constant integer CmdHandler_mCallback = 1
endglobals

function CmdHandler_Create takes string cmd, trigger callback returns integer
    local integer self = Object_Allocate(TYPE_ID_CMD_HANDLER, 2)
    if IsNull(self) then
        return self
    endif
    call SaveStr(gObject, self, CmdHandler_mCommand, cmd)
    call SaveTriggerHandle(gObject, self, CmdHandler_mCallback, callback)
    return self
endfunction

// struct Cmd
// {
//      list<CmdHandler>
// }
globals
    integer gCmd = INVALID
    constant integer Cmd_mCommands = 0
    constant integer Cmd_mTrigger = 1
    constant integer Cmd_mEventPlayer = 2
    constant integer Cmd_mEventArgs = 3
endglobals



function Cmd_RegisterHandler takes string cmd, code callback returns nothing
    local trigger trig = null
    if IsNull(gCmd) then
        call AccessViolation("Cmd_RegisterHandler")
        return
    endif
    set trig = CreateTrigger()
    call TriggerAddAction(trig, callback)
    call List_AddObject(LoadInteger(gObject, gCmd, Cmd_mCommands), CmdHandler_Create(cmd, trig))
    set trig = null
endfunction

function Cmd_GetEventPlayer takes nothing returns player
    if IsNull(gCmd) then
        call AccessViolation("Cmd_GetEventPlayer")
        return null
    endif
    return LoadPlayerHandle(gObject, gCmd, Cmd_mEventPlayer)
endfunction

function Cmd_GetEventArgs takes nothing returns integer
    if IsNull(gCmd) then
        call AccessViolation("Cmd_GetEventArgs")
        return INVALID
    endif
    return LoadInteger(gObject, gCmd, Cmd_mEventArgs)
endfunction

function Cmd_FindHandler takes string cmd returns integer
    local integer i = 0
    local integer mCommands = 0
    local integer size = 0
    local integer current = 0

    if IsNull(gCmd) then
        return INVALID
    endif

    set mCommands = LoadInteger(gObject, gCmd, Cmd_mCommands)
    set size = List_GetSize(mCommands)
    loop
        exitwhen i >= size
        set current = List_GetObject(mCommands, i)
        if LoadStr(gObject, current, CmdHandler_mCommand) == cmd then
            return current
        endif
        set i = i + 1
    endloop

    return INVALID
endfunction

function Cmd_GetCmdString takes string msg returns string
    local integer start = 0
    local integer end = 0
    local integer i = 0
    local integer size = StringLength(msg)

    // read until non-whitespace
    loop
        exitwhen i >= size
        if GetChar(msg, i) != " " then
            set start = i
            exitwhen true
        endif
        set i = i + 1
    endloop

    // read until end or whitespace
    loop 
        exitwhen i >= size
        if GetChar(msg, i) == " " then
            set end = i
            exitwhen true
        elseif i == (size-1) then
            set end = i + 1
            exitwhen true
        endif
        set i = i + 1
    endloop

    return SubString(msg, start, end)
endfunction

function Cmd_SplitCmdString takes string msg returns integer
    local integer MAX_ARGS = 9
    local integer size = StringLength(msg)
    local integer list = List_Create(TYPE_ID_STRING)
    local integer start = INVALID
    local integer end = INVALID
    local integer i = 0
    loop
        exitwhen i >= size
        // read until non-whitespace
        loop
            exitwhen i >= size
            if GetChar(msg, i) != " " then
                set start = i
                exitwhen true
            endif
            set i = i + 1
        endloop

        // read until end or whitespace
        loop 
            exitwhen i >= size
            if GetChar(msg, i) == " " then
                set end = i
                exitwhen true
            elseif i == (size-1) then
                set end = i + 1
                exitwhen true
            endif
            set i = i + 1
        endloop

        // pop_word
        call List_AddString(list, SubString(msg, start, end))
        
        exitwhen i >= (size-1)
        exitwhen List_GetSize(list) >= MAX_ARGS
    endloop
    return list
endfunction

function Cmd_ProcessUserString takes nothing returns nothing
    local string msg = GetEventPlayerChatString()
    local string lowerMsg = StringCase(msg, false)
    local string cmd = Cmd_GetCmdString(lowerMsg)
    local integer handler = Cmd_FindHandler(cmd)
    local integer words = 0
    if IsNull(handler) then
        return
    endif
    set words = Cmd_SplitCmdString(msg)
    call SavePlayerHandle(gObject, gCmd, Cmd_mEventPlayer, GetTriggerPlayer())
    call SaveInteger(gObject, gCmd, Cmd_mEventArgs, words)
    call TriggerExecute(LoadTriggerHandle(gObject, handler, CmdHandler_mCallback))
    call SavePlayerHandle(gObject, gCmd, Cmd_mEventPlayer, null)
    call SaveInteger(gObject, gCmd, Cmd_mEventArgs, INVALID)
    call List_Destroy(words)
endfunction

function Cmd_Create takes nothing returns nothing
    local trigger chatEventTrigger = null
    if not IsNull(gCmd) then
        call DebugLog(LOG_ERROR, "Cmd_Create failed, gCmd already exists.")
        return
    endif
    set gCmd = Object_Allocate(TYPE_ID_CMD, 4)
    call SaveInteger(gObject, gCmd, Cmd_mCommands, List_Create(TYPE_ID_CMD_HANDLER))
    call Assert(not IsNull(LoadInteger(gObject, gCmd, Cmd_mCommands)), "not IsNull(LoadInteger(gObject, gCmd, Cmd_mCommands))")
    set chatEventTrigger = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(chatEventTrigger, Player(0), "-", false)
    call TriggerRegisterPlayerChatEvent(chatEventTrigger, Player(1), "-", false)
    call TriggerRegisterPlayerChatEvent(chatEventTrigger, Player(2), "-", false)
    call TriggerRegisterPlayerChatEvent(chatEventTrigger, Player(3), "-", false)
    call TriggerRegisterPlayerChatEvent(chatEventTrigger, Player(4), "-", false)
    call TriggerRegisterPlayerChatEvent(chatEventTrigger, Player(5), "-", false)
    call TriggerRegisterPlayerChatEvent(chatEventTrigger, Player(6), "-", false)
    call TriggerRegisterPlayerChatEvent(chatEventTrigger, Player(7), "-", false)

    call TriggerAddAction(chatEventTrigger, function Cmd_ProcessUserString)
    call SaveTriggerHandle(gObject, gCmd, Cmd_mTrigger, chatEventTrigger)
    set chatEventTrigger = null
    call SavePlayerHandle(gObject, gCmd, Cmd_mEventPlayer, null)
    call SaveInteger(gObject, gCmd, Cmd_mEventArgs, INVALID)
endfunction

function Cmd_PreInit takes nothing returns nothing
    call Cmd_Create()
endfunction

function CmdMatch takes string arg, integer index, integer eventArgs returns boolean
    if IsNull(eventArgs) then
        return false
    endif
    if index >= List_GetSize(eventArgs) then
        return false
    endif
    return List_GetString(eventArgs, index) == arg
endfunction



function Cmd_Test takes nothing returns nothing
    call DebugLog(LOG_INFO, "Cmd_Test...")
    
    call Assert(Cmd_GetCmdString("-object") == "-object", "Cmd_GetCmdString(-object) == -object")
    call Assert(Cmd_GetCmdString("-object stat") == "-object", "Cmd_GetCmdString(-object stat) == -object")
    call Assert(Cmd_GetCmdString("-object stat type_count") == "-object", "Cmd_GetCmdString(-object stat type_count) == -object")
    call Assert(Cmd_GetCmdString("-object stat instance_count TYPE_ID_INT") == "-object", "Cmd_GetCmdString(-object stat instance_count TYPE_ID_INT) == -object")
    call Assert(Cmd_GetCmdString("-object stat instance_report TYPE_ID_ITEM") == "-object", "Cmd_GetCmdString(-object stat instance_report TYPE_ID_ITEM) == -object")

    
    call DebugLog(LOG_INFO, "Cmd_Test finished.")
endfunction