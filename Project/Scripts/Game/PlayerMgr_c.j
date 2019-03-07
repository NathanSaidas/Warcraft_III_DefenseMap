
function PlayerMgr_RegisterPlayer takes integer playerId returns nothing
    local integer playerData = PlayerData_Create(playerId)
    set PlayerMgr_gPlayers[PlayerMgr_gMaxPlayer] = playerData
    set PlayerMgr_gMaxPlayer = PlayerMgr_gMaxPlayer + 1

    // Allow the players to see the 'HeroVision' rect
    call CreateFogModifierRectBJ(true, Player(playerId), FOG_OF_WAR_VISIBLE, gg_rct_HeroVision)

    call DebugLog(LOG_INFO, "PlayerMgr_c: " + "Register player " + I2S(playerId) + ", is HumanPlaying=" + B2S(PlayerData_IsHumanPlaying(playerData)))
endfunction

function PlayerMgr_RegisterEnemyForcePlayer takes integer playerId returns nothing
    local integer playerData = PlayerData_Create(playerId)
    set PlayerMgr_gEnemyForcePlayer = playerData
endfunction 

function PlayerMgr_RegisterAllyForcePlayer takes integer playerId returns nothing
    local integer playerData = PlayerData_Create(playerId)
    set PlayerMgr_gAllyForcePlayer = playerData
endfunction

function PlayerMgr_FindPlayerData takes integer playerId returns integer
    local integer current = INVALID
    local integer i = 0
    loop
        exitwhen i >= PlayerMgr_gMaxPlayer
        set current = PlayerMgr_gPlayers[i]
        if LoadInteger(gObject, current, PlayerData_mPlayerId) == playerId then
            return current
        endif
        set i = i + 1 
    endloop

    if playerId == LoadInteger(gObject, PlayerMgr_gEnemyForcePlayer, PlayerData_mPlayerId) then
        return PlayerMgr_gEnemyForcePlayer
    endif

    if playerId == LoadInteger(gObject, PlayerMgr_gAllyForcePlayer, PlayerData_mPlayerId) then
        return PlayerMgr_gAllyForcePlayer
    endif
    return INVALID
endfunction

function PlayerMgr_ResetPlayer takes integer playerData returns nothing
    local integer mHero = LoadInteger(gObject, playerData, PlayerData_mHero)
    local integer mHeroPicker = LoadInteger(gObject, playerData, PlayerData_mHeroPicker)
    if not IsNull(mHero) then
        call UnitMgr_DestroyUnit(mHero)
        call SaveInteger(gObject, playerData, PlayerData_mHero, INVALID)
    endif

    if not IsNull(mHeroPicker) then
        call UnitMgr_DestroyUnit(mHeroPicker)
        call SaveInteger(gObject, playerData, PlayerData_mHeroPicker, INVALID)
    endif
endfunction

function PlayerMgr_ResetPlayers takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= PlayerMgr_gMaxPlayer
        call PlayerMgr_ResetPlayer(PlayerMgr_gPlayers[i])
        set i = i + 1
    endloop
endfunction

function PlayerMgr_UpdateHeroes takes nothing returns nothing
    local integer i = 0
    local integer mHero = INVALID
    local integer mPlayerData = INVALID
    loop
        exitwhen i >= PlayerMgr_gMaxPlayer
        set mHero = PlayerData_GetHero(PlayerMgr_gPlayers[i])
        if not IsNull(mHero) then
            set mPlayerData = LoadInteger(gObject, mHero, UnitData_mPlayerData)
            if LoadBoolean(gObject, mHero, UnitData_mQueueDestroy) then
                call UnitMgr_DestroyUnit(mHero)
                call SaveInteger(gObject, mPlayerData, PlayerData_mHero, INVALID)
            else
                call UnitData_Update(mHero)
            endif
        endif
        set i = i + 1
    endloop
endfunction