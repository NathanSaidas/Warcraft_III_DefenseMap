// DECLARE_TYPE(PlayerData,25,25)
globals
    constant integer PlayerData_mPlayerId = 0
    constant integer PlayerData_mHeroPicker = 1
    constant integer PlayerData_mHero = 2
    constant integer PlayerData_mControlledUnits = 3

    constant integer PlayerData_MAX_MEMBER = 4
endglobals

function PlayerData_Create takes integer playerId returns integer
    local integer self = Object_Allocate(TYPE_ID_PLAYER_DATA, PlayerData_MAX_MEMBER)
    if IsNull(self) then
        return self
    endif

    call SaveInteger(gObject, self, PlayerData_mPlayerId, playerId)
    call SaveInteger(gObject, self, PlayerData_mHeroPicker, INVALID)
    call SaveInteger(gObject, self, PlayerData_mHero, INVALID)
    call SaveInteger(gObject, self, PlayerData_mControlledUnits, List_Create(TYPE_ID_UNIT_DATA))
    return self
endfunction


