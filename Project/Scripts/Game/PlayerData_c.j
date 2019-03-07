function PlayerData_GetId takes integer self returns integer
    if not SelfCheck(self, TYPE_ID_PLAYER_DATA, "PlayerData_GetId") then
        return INVALID
    endif

    return LoadInteger(gObject, self, PlayerData_mPlayerId)
endfunction

function PlayerData_GetHeroPicker takes integer self returns integer
    if not SelfCheck(self, TYPE_ID_PLAYER_DATA, "PlayerData_GetHeroPicker") then
        return INVALID
    endif
    return LoadInteger(gObject, self, PlayerData_mHeroPicker)
endfunction

function PlayerData_GetHero takes integer self returns integer
    if not SelfCheck(self, TYPE_ID_PLAYER_DATA, "PlayerData_GetHero") then
        return INVALID
    endif
    return LoadInteger(gObject, self, PlayerData_mHero)
endfunction

// List<UnitData>
function PlayerData_GetControlledUnits takes integer self returns integer
    if not SelfCheck(self, TYPE_ID_PLAYER_DATA, "PlayerData_GetHero") then
        return INVALID
    endif
    return LoadInteger(gObject, self, PlayerData_mControlledUnits)
endfunction

function PlayerData_IsPlaying takes integer self returns boolean
    if not SelfCheck(self, TYPE_ID_PLAYER_DATA, "PlayerData_IsPlaying") then
        return false
    endif
    return GetPlayerSlotState(Player(LoadInteger(gObject, self, PlayerData_mPlayerId))) == PLAYER_SLOT_STATE_PLAYING
endfunction

function PlayerData_IsHuman takes integer self returns boolean
    if not SelfCheck(self, TYPE_ID_PLAYER_DATA, "PlayerData_IsPlaying") then
        return false
    endif
    return GetPlayerController(Player(LoadInteger(gObject, self, PlayerData_mPlayerId))) == MAP_CONTROL_USER
endfunction

function PlayerData_IsHumanPlaying takes integer self returns boolean
    return PlayerData_IsPlaying(self) and PlayerData_IsHuman(self)
endfunction