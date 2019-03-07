function GameState_Failed_TransitionOut takes nothing returns nothing
    call DestroyTimerDialog(GameState_Failed_gRestartTimerDialog)
    call DestroyTimer(GameState_Failed_gRestartTimer)
    set GameState_Failed_gRestartTimer = null
    set GameState_Failed_gRestartTimerDialog = null
endfunction

function GameState_Failed_TransitionIn takes nothing returns nothing
    set GameState_Failed_gRestartTimer = CreateTimer()
    call TimerStart(GameState_Failed_gRestartTimer, 15.0, false, null)
    set GameState_Failed_gRestartTimerDialog = CreateTimerDialog(GameState_Failed_gRestartTimer)
    call TimerDialogDisplay(GameState_Failed_gRestartTimerDialog, true)
    call TimerDialogSetTitle(GameState_Failed_gRestartTimerDialog, "Restarting:")
    call PlayerMgr_ResetPlayers()
    
endfunction

function GameState_Failed_Update takes nothing returns nothing
    if TimerGetRemaining(GameState_Failed_gRestartTimer) <= 0.0 then
        set gNextGameState = GS_LOADING
    endif
endfunction