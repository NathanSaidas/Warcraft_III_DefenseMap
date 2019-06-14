globals
    // Temporaries:
    trigger     gReturnTrigger  = null
    hashtable   gReturnTable    = null
    rect        gReturnRect     = null
    unit        gReturnUnit     = null
    player      gReturnPlayer   = null

    // Internal:
    hashtable   gTable = InitHashtable()
    hashtable   gObject = InitHashtable()
    hashtable   gList = InitHashtable()
    boolean     gConfigLogInfo = true
    boolean     gConfigLogWarning = true
    boolean     gConfigLogError = true
endglobals

function Print takes string msg returns nothing
    call DisplayTextToForce(GetPlayersAll(), msg)
endfunction

function DebugLog takes integer logLevel, string msg returns nothing
    local string printMsg = ""
    if logLevel == LOG_INFO and gConfigLogInfo then
        set printMsg = "[Info]: " + msg
    elseif logLevel == LOG_WARNING and gConfigLogWarning then
        set printMsg = "[Warning]: " + msg
    elseif logLevel == LOG_ERROR and gConfigLogError then
        set printMsg = "[Error]: " + msg
    endif
    call Print(printMsg)
endfunction

function Breakpoint takes string message returns nothing
    call DebugLog(LOG_INFO, "|c00FF00FFBREAKPOINT|r: " + message)
endfunction

function BeginDebug takes nothing returns nothing
    call Print("[Debug]: BeginDebug")
endfunction

function EndDebug takes nothing returns nothing
    call Print("[Debug]: EndDebug")
endfunction

function Sleep takes real t returns nothing
    call PolledWait(t)
endfunction

function AccessViolation takes string sender returns nothing
    call DebugLog(LOG_ERROR, sender + " failed! Access violation!")
    call Sleep(1)
endfunction

function B2I takes boolean b returns integer
    if b == true then
        return 1
    else
        return 0
    endif
    return 0
endfunction

function I2B takes integer i returns boolean
    if i != 0 then
        return true
    else
        return false
    endif
    return false
endfunction

function B2S takes boolean b returns string
    if b then
        return "true"
    endif
    return "false"
endfunction

function MinI takes integer a, integer b returns integer
    if a < b then
        return a
    endif
    return b
endfunction

function MaxI takes integer a, integer b returns integer
    if a > b then
        return a
    endif
    return b
endfunction

function MinR takes real a, real b returns real
    if a < b then
        return a
    endif
    return b
endfunction

function MaxR takes real a, real b returns real
    if a > b then
        return a
    endif
    return b
endfunction

function Abs takes integer value returns integer
    if value < 0 then
        return value * -1
    endif
    return value
endfunction

function FAbs takes real value returns real
    if value < 0.0 then
        return value * -1.0
    endif
    return value
endfunction

// PUBLIC STATIC: Returns true if the integer is not -1
function Valid takes integer value returns boolean
    if value != -1 then
        return true
    endif
    return false
endfunction

// PUBLIC STATIC: Returns true if the integer is -1
function Invalid takes integer value returns boolean
    if value == -1 then
        return true
    endif
    return false
endfunction

function Assert takes boolean exprValue, string expression returns nothing
    if not exprValue then
        call DebugLog(LOG_ERROR, "Assertion failed: " + expression)
    endif
endfunction

function GetChar takes string str, integer index returns string
    return SubString(str, index, index + 1)
endfunction

// makes the 2 players enemies with each other
function SetPlayerEnemy takes player a, player b returns nothing
    if a == null or b == null or a == b then
        return
    endif

    call SetPlayerAllianceStateBJ(a, b, bj_ALLIANCE_UNALLIED)
    call SetPlayerAllianceStateBJ(b, a, bj_ALLIANCE_UNALLIED)
    call SetPlayerAlliance(a, b, ALLIANCE_SHARED_VISION, false)
    call SetPlayerAlliance(b, a, ALLIANCE_SHARED_VISION, false)

    call SetPlayerAlliance(a, b, ALLIANCE_SHARED_XP, false)
    call SetPlayerAlliance(b, a, ALLIANCE_SHARED_XP, false)

    call SetPlayerAlliance(a, b, ALLIANCE_SHARED_SPELLS, false)
    call SetPlayerAlliance(b, a, ALLIANCE_SHARED_SPELLS, false)
endfunction

// makes the 2 players friendly with each other
function SetPlayerFriendly takes player a, player b returns nothing
    if a == null or b == null or a == b then
        return
    endif

    call SetPlayerAllianceStateBJ(a, b, bj_ALLIANCE_ALLIED)
    call SetPlayerAllianceStateBJ(b, a, bj_ALLIANCE_ALLIED)

    call SetPlayerAlliance(a, b, ALLIANCE_SHARED_VISION, true)
    call SetPlayerAlliance(b, a, ALLIANCE_SHARED_VISION, true)

    call SetPlayerAlliance(a, b, ALLIANCE_SHARED_XP, true)
    call SetPlayerAlliance(b, a, ALLIANCE_SHARED_XP, true)

    call SetPlayerAlliance(a, b, ALLIANCE_SHARED_SPELLS, true)
    call SetPlayerAlliance(b, a, ALLIANCE_SHARED_SPELLS, true)
endfunction

function SetPlayerNeutral takes player a, player b returns nothing
    if a == null or b == null or a == b then
        return
    endif

    call SetPlayerAllianceStateBJ(a, b, bj_ALLIANCE_ALLIED)
    call SetPlayerAllianceStateBJ(b, a, bj_ALLIANCE_ALLIED)

    call SetPlayerAlliance(a, b, ALLIANCE_SHARED_VISION, false)
    call SetPlayerAlliance(b, a, ALLIANCE_SHARED_VISION, false)

    call SetPlayerAlliance(a, b, ALLIANCE_SHARED_XP, false)
    call SetPlayerAlliance(b, a, ALLIANCE_SHARED_XP, false)

    call SetPlayerAlliance(a, b, ALLIANCE_SHARED_SPELLS, false)
    call SetPlayerAlliance(b, a, ALLIANCE_SHARED_SPELLS, false)
endfunction