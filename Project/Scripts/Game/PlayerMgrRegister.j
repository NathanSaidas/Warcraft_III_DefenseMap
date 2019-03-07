function PlayerMgr_PreInit takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= bj_MAX_PLAYERS
        if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
            call PlayerMgr_RegisterPlayer(i)
        endif
        set i = i + 1
    endloop

    call PlayerMgr_RegisterEnemyForcePlayer(8)
    call PlayerMgr_RegisterAllyForcePlayer(9)
endfunction