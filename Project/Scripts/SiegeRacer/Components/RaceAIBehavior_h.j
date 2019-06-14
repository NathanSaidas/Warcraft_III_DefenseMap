// DECLARE_TYPE(RaceAIBehavior, 24, 24)
globals

    constant integer RaceAIBehavior_mLogged = Component_MAX_MEMBER + 0
    constant integer RaceAIBehavior_MAX_MEMBER = Component_MAX_MEMBER + 0

    code RaceAIBehavior_gDestroyFunc = null
    code RaceAIBehavior_gUpdateFunc = null
endglobals

function RaceAIBehavior_Create takes nothing returns integer
    local integer self = Object_Allocate(TYPE_ID_RACE_AIBEHAVIOR, RaceAIBehavior_MAX_MEMBER)
    if IsNull(self) then
        return self
    endif

    call SaveBoolean(gObject, self, RaceAIBehavior_mLogged, false)
    call Component_Derive(self, RaceAIBehavior_gDestroyFunc, RaceAIBehavior_gUpdateFunc)
    return self
endfunction