
function GameState_Loading_TransitionOut takes nothing returns nothing
    call DestroyTimerDialog(GameState_Loading_gTimerDialog)
    call DestroyTimer(GameState_Loading_gTimer)
    set GameState_Loading_gTimer = null
    set GameState_Loading_gTimerDialog = null
endfunction

function GameState_Loading_TransitionIn takes nothing returns nothing
    set GameState_Loading_gTimer = CreateTimer()
    call TimerStart(GameState_Loading_gTimer, 2.0, false, null)
    set GameState_Loading_gTimerDialog = CreateTimerDialog(GameState_Loading_gTimer)
    call TimerDialogSetTitle(GameState_Loading_gTimerDialog, "Loading:")
    call TimerDialogDisplay(GameState_Loading_gTimerDialog, true)

    call DebugLog(LOG_INFO, "GameState_Loading_c: Wait 2 seconds for state to end.")
endfunction

function GameState_Loading_Update takes nothing returns nothing
    if TimerGetRemaining(GameState_Loading_gTimer) <= 0.0 then
        set gNextGameState = GS_HERO_PICK
    endif
endfunction