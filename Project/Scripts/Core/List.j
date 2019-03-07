// ___________________________________________________________________________________________
// List:
// -------------------------------------------------------------------------------------------
// Overview:
//    List is a wrapper API around blizzard hashtables and are attached to a 'Object'.
//
//
// Private Members:
//            int mSize   : [0, -1]
//            int mTypeId : [0, -2]
//
// Public Functions: ( prefixed List_ , and 'self' is assumed hashtable)
//     Create(Object parent, string name) : hashtable
//     Get(Object parent, string name) : hashtable
//     GetSize(self) : integer
//     GetTypeId(self) : int
//     Clear()
//
//   templates:
//     Get<T>(self, int index) T
//     Set<T>(self, int index, T value) : void
//     Remove<T>(self, int index) : void
//     Find<T>(self, T value) : int
//
//
// -------------------------------------------------------------------------------------------

globals
    // Private list members: Each element exists from 0-N
    constant integer p_List_Size = -5
endglobals

function List_GetTypeId takes integer self returns integer
    return Object_GetTypeId(self)
endfunction

function List_GetTypeName takes integer self returns string
    return Object_GetTypeName(self)
endfunction

function p_List_VerifyType takes integer self, integer typeId returns boolean
    local integer classId = 0
    if IsNull(self) then
        call DebugLog(LOG_ERROR, "List_VerifyAccess failed! Access violation! self = NULL")
        call Sleep(1)
        return false
    endif
    set classId = List_GetTypeId(self)
    if not (ObjectType_IsNative(classId) == ObjectType_IsNative(typeId) and ObjectType_IsHandle(classId) == ObjectType_IsHandle(typeId)) then
        call DebugLog(LOG_ERROR, "List_VerifyAccess failed! Type mismatch " + Object_GetTypeName(classId) + " != " + Object_GetTypeName(typeId) + " self=" + I2S(self))
        call Sleep(1)
        return false
    endif
    return true
endfunction

function p_List_VerifyAccess takes integer self, integer index, integer typeId returns boolean
    local integer classId = 0 
    local integer size = 0 
    if Invalid(self) then
        call DebugLog(LOG_ERROR, "p_List_VerifyAccess failed! Access violation! self = NULL")
        call Sleep(1)
        return false
    endif

    set classId = List_GetTypeId(self)
    set size = LoadInteger(gObject, self, p_List_Size)
    if not (ObjectType_IsNative(classId) == ObjectType_IsNative(typeId) and ObjectType_IsHandle(classId) == ObjectType_IsHandle(typeId)) then
        call DebugLog(LOG_ERROR, "p_List_VerifyAccess failed! Type mismatch " + Object_GetTypeName(classId) + " != " + Object_GetTypeName(typeId) + " self=" + I2S(self))
        call Sleep(1)
        return false
    endif

    if index < 0 or index >= size then
        call DebugLog(LOG_ERROR, "p_List_VerifyAccess failed! Index out of Bounds! self=" + I2S(self) + " Type=" + Object_GetTypeName(classId) + " Index=" + I2S(index))
        call Sleep(1)
        return false
    endif

    return true
endfunction



function List_ClearInt takes integer self returns nothing
    local integer i = 0
    local integer size = LoadInteger(gObject, self, p_List_Size)
    loop
        exitwhen i >= size
        call RemoveSavedInteger(gObject, self, i)
        set i = i + 1
    endloop
    call SaveInteger(gObject, self, p_List_Size, 0)
endfunction

function List_ClearReal takes integer self returns nothing
    local integer i = 0
    local integer size = LoadInteger(gObject, self, p_List_Size)
    loop
        exitwhen i >= size
        call RemoveSavedReal(gObject, self, i)
        set i = i + 1
    endloop
    call SaveInteger(gObject, self, p_List_Size, 0)
endfunction

function List_ClearString takes integer self returns nothing
    local integer i = 0
    local integer size = LoadInteger(gObject, self, p_List_Size)
    loop
        exitwhen i >= size
        call RemoveSavedString(gObject, self, i)
        set i = i + 1
    endloop
    call SaveInteger(gObject, self, p_List_Size, 0)
endfunction

function List_ClearBool takes integer self returns nothing
    local integer i = 0
    local integer size = LoadInteger(gObject, self, p_List_Size)
    loop
        exitwhen i >= size
        call RemoveSavedBoolean(gObject, self, i)
        set i = i + 1
    endloop
    call SaveInteger(gObject, self, p_List_Size, 0)
endfunction

function List_ClearHandle takes integer self returns nothing
    local integer i = 0
    local integer size = LoadInteger(gObject, self, p_List_Size)
    loop
        exitwhen i >= size
        call RemoveSavedHandle(gObject, self, i)
        set i = i + 1
    endloop
    call SaveInteger(gObject, self, p_List_Size, 0)
endfunction

function List_Clear takes integer self returns nothing
    local integer typeId = List_GetTypeId(self)

    // Clear:
    if not ObjectType_IsNative(typeId) or typeId == TYPE_ID_INT then
        call List_ClearInt(self)
    elseif typeId == TYPE_ID_REAL then
        call List_ClearReal(self)
    elseif typeId == TYPE_ID_STRING then
        call List_ClearString(self)
    elseif typeId == TYPE_ID_BOOL then
        call List_ClearBool(self)
    else
        call List_ClearHandle(self)
    endif
endfunction

function List_GetSize takes integer self returns integer
    return LoadInteger(gObject, self, p_List_Size)
endfunction
function List_Empty takes integer self returns boolean
    return LoadInteger(gObject, self, p_List_Size) == 0
endfunction

function List_Create takes integer classId returns integer
    local integer begin = 0
    local integer end = 0

    if classId <= TYPE_ID_NATIVE_MAX or classId >= TYPE_ID_MAX or classId == 0 then
        call DebugLog(LOG_ERROR, "List_Create failed! Invalid classId. " + I2S(classId))
        return INVALID
    endif
    set begin = LoadInteger(gObject, classId, ps_Object_ListOffset) + 10000
    set end = begin + LoadInteger(gObject, classId, ps_Object_ListMaxInstances) + 10000
    loop
        exitwhen begin >= end
        if not HaveSavedBoolean(gObject, begin, p_Object_LoadFlag) or not LoadBoolean(gObject, begin, p_Object_LoadFlag) then
            exitwhen true
        endif
        set begin = begin + 1
    endloop

    // No room:
    if begin == end then
        call DebugLog(LOG_WARNING, "List_Create failed! Max instances reached for type " + Object_GetTypeName(classId))
        return INVALID
    endif

    call SaveBoolean(gObject, begin, p_Object_LoadFlag, true)
    call SaveInteger(gObject, begin, p_Object_ClassId, classId + 1)
    call SaveInteger(gObject, begin, p_Object_MemberSize, 0)
    call SaveInteger(gObject, begin, p_List_Size, 0)
    return begin
endfunction

function List_Destroy takes integer self returns nothing
    call List_Clear(self)
    call Object_Free(self)
endfunction