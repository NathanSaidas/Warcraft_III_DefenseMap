

// -game list players
// -game list units <player>
// -game kill
// -game teleport
function CmdProc_Game takes nothing returns nothing
    local integer eventArgs = Cmd_GetEventArgs()
    if CmdMatch("start", 1, eventArgs) then
        call DebugLog(LOG_INFO, "Start")
    elseif CmdMatch("restart", 1, eventArgs) then
        call DebugLog(LOG_INFO, "Restart")
    elseif CmdMatch("stop", 1, eventArgs) then
        call DebugLog(LOG_INFO, "Stop")
    elseif CmdMatch("help", 1, eventArgs) then
        call DebugLog(LOG_INFO, "Usage: ")
        call DebugLog(LOG_INFO, "-game start")
        call DebugLog(LOG_INFO, "-game restart")
        call DebugLog(LOG_INFO, "-game stop")
    endif
endfunction

function CmdGame_Init takes nothing returns nothing
    call Cmd_RegisterHandler("-game", function CmdProc_Game)
endfunction