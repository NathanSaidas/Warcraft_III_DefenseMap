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

function PlayerData_GetComponents takes integer self returns integer
    if not SelfCheck(self, TYPE_ID_PLAYER_DATA, "PlayerData_GetComponents") then
        return INVALID
    endif
    return LoadInteger(gObject, self, PlayerData_mComponents)
endfunction

function PlayerData_GetComponent takes integer self, integer typeId returns integer
    local integer i = 0
    local integer mComponents = INVALID
    local integer mComponents_mSize = 0
    local integer current = INVALID

    if not SelfCheck(self, TYPE_ID_PLAYER_DATA, "PlayerData_GetComponent") then
        return INVALID
    endif

    set mComponents = LoadInteger(gObject, self, PlayerData_mComponents)
    set mComponents_mSize = List_GetSize(mComponents)
    loop
        exitwhen i >= mComponents_mSize
        set current = List_GetObject(mComponents, i)
        if Object_GetTypeId(current) == typeId then
            return current
        endif
        set i = i + 1
    endloop
    return INVALID
endfunction

function PlayerData_AddComponent takes integer self, integer component returns boolean
    local integer mComponents = INVALID
    if not SelfCheck(self, TYPE_ID_PLAYER_DATA, "PlayerData_AddComponent") then
        return false
    endif

    if IsNull(component) then
        call DebugLog(LOG_ERROR, "PlayerData_c: PlayerData_AddComponent failed, missing component instance.")
        return false
    endif

    if not IsNull(PlayerData_GetComponent(self, Object_GetTypeId(component))) then
        call DebugLog(LOG_ERROR, "PlayerData_c: PlayerData_AddComponent failed, component of that type already exists. Type=" + Object_GetTypeName(Object_GetTypeId(component)))
        return false
    endif

    set mComponents = LoadInteger(gObject, self, PlayerData_mComponents)
    call List_AddObject(mComponents, component)
    call SaveInteger(gObject, component, Component_mParent, self)
    return true
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

function PlayerData_GetName takes integer self returns string
    return GetPlayerName(Player(LoadInteger(gObject, self, PlayerData_mPlayerId)))
endfunction