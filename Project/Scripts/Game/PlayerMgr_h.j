// @singleton
globals
    constant integer PlayerMgr_gMaxPlayer = 8

    integer array PlayerMgr_gPlayers
    integer PlayerMgr_gPlayers_mSize = 0
    integer PlayerMgr_gEnemyForcePlayer = INVALID
    integer PlayerMgr_gAllyForcePlayer = INVALID
endglobals

// function PlayerMgr_RegisterPlayer takes integer playerId returns nothing
// function PlayerMgr_RegisterAllyForcePlayer takes integer playerId returns nothing
// function PlayerMgr_RegisterEnemyForcePlayer takes integer playerId returns nothing
// function PlayerMgr_FindPlayerData takes integer playerId returns integer
// function PlayerMgr_ResetPlayer takes integer playerData returns nothing
// function PlayerMgr_ResetPlayers takes nothing returns nothing
// function PlayerMgr_UpdateHeroes takes nothing returns nothing
// function PlayerMgr_GetActivePlayerCount takes nothing returns integer