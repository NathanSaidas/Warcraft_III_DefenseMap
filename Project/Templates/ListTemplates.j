// PUBLIC:
function List_Get<T> takes integer self, integer index returns <value_type>
    if not p_List_VerifyAccess(self, index, <TYPE_ID> ) then
        return <default>
    endif
    return <load_func>(gObject, self, index)
endfunction

// PUBLIC:
function List_Set<T> takes integer self, integer index, <value_type> value returns nothing
    if not p_List_VerifyAccess(self, index, <TYPE_ID> ) then
        return
    endif
    call <save_func>(gObject, self, index, value)
endfunction

//PUBLIC:
function List_Add<T> takes integer self, <value_type> value returns nothing
    local integer size = LoadInteger(gObject, self, p_List_Size)
    if not p_List_VerifyType(self, <TYPE_ID> ) then
        return
    endif
    call SaveInteger(gObject, self, p_List_Size, size + 1)
    call <save_func>(gObject, self, size, value)
endfunction

//PUBLIC:
function List_Remove<T> takes integer self, integer index returns nothing
    local integer i = index
    local integer size = LoadInteger(gObject, self, p_List_Size) - 1
    // TypeCheck:
    if not p_List_VerifyAccess(self, index, <TYPE_ID>) then
        return
    endif
    // Move down:
    loop
        exitwhen i >= size
        call <save_func>(gObject, self, i, <load_func>(gObject, self, i+1))
        set i = i + 1
    endloop
    // Remove:
    if size >= 0 then
        call <remove_func>(gObject, self, size+1)
    endif
    call SaveInteger(gObject, self, p_List_Size, size)
endfunction

//PUBLIC:
function List_Find<T> takes integer self, <value_type> value returns integer
    local integer i = 0
    local integer size = LoadInteger(gObject, self, p_List_Size)
    // TypeCheck:
    if not p_List_VerifyType(self, <TYPE_ID>) then
        return INVALID
    endif

    loop
        exitwhen i >= size
        if <load_func>(gObject, self, i) == value then
            return i
        endif
        set i = i + 1
    endloop

    return INVALID
endfunction
