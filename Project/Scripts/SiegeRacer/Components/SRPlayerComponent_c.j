

function SRPlayerComponentt_Destroy takes nothing returns nothing
    local integer self = Component_gDestructorArg_Self

    call RemoveSavedInteger(gObject, self, SRPlayerComponent_mCheckPointIndex)
    call RemoveSavedInteger(gObject, self, SRPlayerComponent_mLapsComplete)
    call Object_Free(self)
endfunction

function SRPlayerComponent_Update takes nothing returns nothing
    local integer self = Component_gUpdateArg_Self

endfunction