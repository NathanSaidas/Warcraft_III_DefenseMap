// ___________________________________________________________________________________________
// Object:
// -------------------------------------------------------------------------------------------
// Overview:
//    Object uses a 'hashtable' for its implementation. It provides an easy to use interface
//    to associate keys with values. All objects created are stored in the global hashtable
//    under the following keys OBJECT_NAME_INDEX and OBJECT_HANDLE_INDEX
//
//    When extending object you can declare your own private member variables but just make
//    sure the index isn't stomping on the inheriting objects allocated memory.
//    (Eg. Object is 4 ids long)
//
//
// New Design: gObject[instanceId][variable] = value
//
//  Common Variables: ClassName:-1, ClassId:-2,
//
// New List Design: gList[instanceId][variable] = value
//  Variables: ClassName:-1, ClassId:-2, Template:-3, Size:4,
//
// Private Constants:
//     VALUE_INDEX(0) : Primary key used to store values
//     KEY_INDEX(1) :   Primary key used to store keys (strings)
// Private Members:
//     static int mObjectCount : [ OBJECT_NAME_INDEX, -1] -- How many objects are allocated
//            int mSize   : [VALUE_INDEX, -1] -- How many variables exist inside the object
//            int mIndex  : [VALUE_INDEX, -2] -- Index to this objects address in the global object table
//            string mId  : [VALUE_INDEX, -3] -- IdString of this object, can be used to find in global object table
//            int mTypeId : [VALUE_INDEX, -4] -- TypeId describing this objects table format
//            int mClassId: [VALUD_INDEX, -5] -- ClassId specifies what type of class the object is.
//
// -------------------------------------------------------------------------------------------

globals
    // Flag used to determine if an object is loaded or not.
    constant integer p_Object_LoadFlag = -1
    constant integer p_Object_ClassId = -2
    constant integer p_Object_MemberSize = -3
    constant integer p_Object_Name = -4

    constant integer ps_Object_ClassName = -1000
    constant integer ps_Object_Offset = -1001
    constant integer ps_Object_MaxInstances = -1002
    constant integer ps_Object_ListOffset = -1003
    constant integer ps_Object_ListMaxInstances = -1004
endglobals

// Helper function to register types.
function ps_Object_RegisterType takes integer classId, string name, integer maxInstances, integer listMaxInstances returns nothing
    call SaveStr(gObject, classId, ps_Object_ClassName, name)
    call SaveInteger(gObject, classId, ps_Object_MaxInstances, maxInstances)
    call SaveInteger(gObject, classId, ps_Object_ListMaxInstances, listMaxInstances)
endfunction

function ps_Object_RegisterNative takes integer classId, string name, integer listOffset, integer listMaxInstances returns nothing
    call SaveStr(gObject, classId, ps_Object_ClassName, name)
    call SaveInteger(gObject, classId, ps_Object_Offset, 0)
    call SaveInteger(gObject, classId, ps_Object_MaxInstances, 0)
    call SaveInteger(gObject, classId, ps_Object_ListOffset, listOffset)
    call SaveInteger(gObject, classId, ps_Object_ListMaxInstances, listMaxInstances)
endfunction

function IsNull takes integer instanceId returns boolean
    if Invalid(instanceId) then
        return true
    endif
    return not LoadBoolean(gObject, instanceId, p_Object_LoadFlag)
endfunction

function SelfCheck takes integer instance, integer typeId, string sender returns boolean
    if IsNull(instance) then
        call AccessViolation(sender)
        return false
    endif
    
    if (LoadInteger(gObject, instance, p_Object_ClassId) - 1) != typeId then
        call AccessViolation(sender)
        return false
    endif
    return true
endfunction

function ObjectType_IsNative takes integer classId returns boolean
    if classId < 0 then
        return true
    endif
    return false
endfunction

function ObjectType_IsHandle takes integer classId returns boolean
    if classId >= 0 then
        return false
    elseif classId == TYPE_ID_INT or classId == TYPE_ID_REAL or classId == TYPE_ID_STRING or classId == TYPE_ID_BOOL then
        return false
    endif
    return true
endfunction

function ObjectType_GetInstanceOffset takes integer classId returns integer
    if classId < 0 or classId >= TYPE_ID_MAX then
        return INVALID
    endif
    return LoadInteger(gObject, classId, ps_Object_Offset)
endfunction

function Object_GetTypeName takes integer typeId returns string
    if Invalid(typeId) then
        return "INVALID_TYPE"
    endif
    return LoadStr(gObject, typeId, ps_Object_ClassName)
endfunction

function Object_GetTypeId takes integer instanceId returns integer
    return LoadInteger(gObject, instanceId, p_Object_ClassId) - 1
endfunction

// Returns the local offset of the instance relative to its type.
function Object_GetLocalAddress takes integer instanceId returns integer
    return instanceId - ObjectType_GetInstanceOffset(Object_GetTypeId(instanceId))
endfunction

function Object_GetFormattedName takes integer instanceId returns string
    if IsNull(instanceId) then
        return "NULL"
    endif
    return "[" + I2S(instanceId) + "]: " + LoadStr(gObject, instanceId, p_Object_Name)
endfunction

function Object_GetFormattedMember takes integer instanceId, integer memberIdx returns string
    if IsNull(instanceId) then
        return "NULL"
    endif

    if HaveSavedBoolean(gObject, instanceId, memberIdx) then
        return "[" + I2S(memberIdx) + "]: Boolean " + B2S(LoadBoolean(gObject, instanceId, memberIdx))
    elseif HaveSavedInteger(gObject, instanceId, memberIdx) then
        if HaveSavedInteger(gObject, LoadInteger(gObject, instanceId, memberIdx), -5) then
            return "[" + I2S(memberIdx) + "]: List " + I2S(LoadInteger(gObject, instanceId, memberIdx))
        elseif HaveSavedInteger(gObject, LoadInteger(gObject, instanceId, memberIdx), p_Object_ClassId) then
            return "[" + I2S(memberIdx) + "]: Object " + I2S(LoadInteger(gObject, instanceId, memberIdx))
        else
            return "[" + I2S(memberIdx) + "]: Integer " + I2S(LoadInteger(gObject, instanceId, memberIdx))
        endif
    elseif HaveSavedReal(gObject, instanceId, memberIdx) then
        return "[" + I2S(memberIdx) + "]: Real " + R2S(LoadReal(gObject, instanceId, memberIdx))
    elseif HaveSavedString(gObject, instanceId, memberIdx) then
        return "[" + I2S(memberIdx) + "]: String " + (LoadStr(gObject, instanceId, memberIdx))
    elseif HaveSavedHandle(gObject, instanceId, memberIdx) then
        return "[" + I2S(memberIdx) + "]: " + "handle"
    else
        return "[" + I2S(memberIdx) + "]: " + "'out of range'"
    endif
endfunction

// Helper method to search for an instance of an object by member/string. `[n][memberId] == value`
function Object_FindByString takes integer classId, integer memberId, string value returns integer
    local integer begin = LoadInteger(gObject, classId, ps_Object_Offset)
    local integer end = begin + LoadInteger(gObject, classId, ps_Object_MaxInstances)
    loop    
        exitwhen begin >= end
        if HaveSavedBoolean(gObject, begin, p_Object_LoadFlag) and LoadBoolean(gObject, begin, p_Object_LoadFlag) then
            if LoadStr(gObject, begin, memberId) == value then
                return begin
            endif
        endif
        set begin = begin + 1
    endloop
    return INVALID
endfunction

// Allocates an object from the "class pool" and returns the "instance id"
function Object_Allocate takes integer classId, integer memberSize returns integer
    local integer begin = 0
    local integer end = 0

    if classId < 0 or classId >= TYPE_ID_MAX then
        call DebugLog(LOG_ERROR, "Object_Allocate failed! Invalid classId. " + I2S(classId))
        return INVALID
    endif

    // Find space:
    set begin = LoadInteger(gObject, classId, ps_Object_Offset)
    set end = begin + LoadInteger(gObject, classId, ps_Object_MaxInstances)
    loop
        exitwhen begin >= end
        if not HaveSavedBoolean(gObject, begin, p_Object_LoadFlag) or not LoadBoolean(gObject, begin, p_Object_LoadFlag) then
            exitwhen true
        endif
        set begin = begin + 1
    endloop

    // No room:
    if begin == end then
        call DebugLog(LOG_WARNING, "Object_Allocate failed! Max instances reached for type " + Object_GetTypeName(classId))
        return INVALID
    endif

    call SaveBoolean(gObject, begin, p_Object_LoadFlag, true)
    call SaveInteger(gObject, begin, p_Object_ClassId, classId + 1)
    call SaveInteger(gObject, begin, p_Object_MemberSize, memberSize)
    call SaveStr(gObject, begin, p_Object_Name, "Unknown")
    return begin
endfunction

function Object_Free takes integer instanceId returns nothing
    local integer typeId = INVALID
    if Invalid(instanceId) then
        return
    endif

    set typeId = LoadInteger(gObject, instanceId, p_Object_ClassId) - 1
    if Invalid(typeId) then
        call DebugLog(LOG_ERROR, "Failed to destroy object, INVALID instance type Id")
        return
    endif

    if not LoadBoolean(gObject, instanceId, p_Object_LoadFlag) then
        call DebugLog(LOG_ERROR, "Failed to destroy object Id=" + I2S(instanceId) + ", TypeId=" + Object_GetTypeName(typeId) + " because it's already destroyed.")
        return
    endif

    call SaveBoolean(gObject, instanceId, p_Object_LoadFlag, false)
endfunction

// DECLARE_TYPE(object, 500, 500)
// DECLARE_TYPE(Cmd, 1,1)
// DECLARE_TYPE(CmdHandler, 500, 1)
// DECLARE_TYPE(Thread, 1, 1)
// DECLARE_TYPE(ThreadDriver, 500, 1)

function Object_PreInit takes nothing returns nothing
    local integer i = TYPE_ID_OBJECT
    local integer offset = 0
    local integer listOffset = 0
    local integer maxTypeId = TYPE_ID_MAX

    call ps_Object_RegisterNative(TYPE_ID_INT, "int", 1000, 100)
    call ps_Object_RegisterNative(TYPE_ID_REAL, "real", 1100, 100)
    call ps_Object_RegisterNative(TYPE_ID_STRING, "string", 1200, 100)
    call ps_Object_RegisterNative(TYPE_ID_BOOL, "bool", 1300, 100)
    call ps_Object_RegisterNative(TYPE_ID_HANDLE, "handle", 1400, 100)
    call ps_Object_RegisterNative(TYPE_ID_EFFECT, "effect", 1500, 100)
    call ps_Object_RegisterNative(TYPE_ID_LOCATION, "location", 1600, 100)
    call ps_Object_RegisterNative(TYPE_ID_RECT, "rect", 1700, 100)
    call ps_Object_RegisterNative(TYPE_ID_TIMER, "timer", 1800, 100)
    call ps_Object_RegisterNative(TYPE_ID_UNIT, "unit", 1900, 100)
    call ps_Object_RegisterNative(TYPE_ID_ITEM, "item", 2000, 100)
    call ps_Object_RegisterNative(TYPE_ID_TRIGGER, "trigger", 2100, 100)
    call ps_Object_RegisterNative(TYPE_ID_TEXTTAG, "texttag", 2200, 100)
    call ps_Object_RegisterNative(TYPE_ID_QUEST, "quest", 2300, 100)

    call Object_RegisterTypes()

    loop
        exitwhen i >= maxTypeId
        call SaveInteger(gObject, i, ps_Object_Offset, offset)
        call SaveInteger(gObject, i, ps_Object_ListOffset, listOffset)
        set offset = offset + LoadInteger(gObject, i, ps_Object_MaxInstances)
        set listOffset = listOffset + LoadInteger(gObject, i, ps_Object_ListMaxInstances)
        if CONFIG_OBJECT_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Registered Type: " + LoadStr(gObject,i, ps_Object_ClassName) + ", Offset=" + I2S(LoadInteger(gObject, i, ps_Object_Offset)) + ", MaxInstances=" + I2S(LoadInteger(gObject, i, ps_Object_MaxInstances)))
        endif
        set i = i + 1
    endloop

    set maxTypeId = TYPE_ID_NATIVE_MAX
    set i = -1
    loop
        exitwhen i <= maxTypeId
        call SaveInteger(gObject, i, ps_Object_ListOffset, listOffset)
        set listOffset = listOffset + LoadInteger(gObject, i, ps_Object_ListMaxInstances)
        if CONFIG_OBJECT_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Registered Type: " + LoadStr(gObject, i, ps_Object_ClassName) + ", List Offset=" + I2S(LoadInteger(gObject, i, ps_Object_ListOffset)))
        endif
        set i = i - 1
    endloop

    call Sleep(GAME_DELTA)
endfunction

function Object_Test takes nothing returns nothing
    local boolean ENABLED = false
    local integer array objects

    if ENABLED then
        call Sleep(1.0)
        call DebugLog(LOG_INFO, "Object_Test...")

        set objects[1] = Object_Allocate(TYPE_ID_OBJECT, 0)
        set objects[2] = Object_Allocate(TYPE_ID_OBJECT, 0)
        set objects[3] = Object_Allocate(TYPE_ID_OBJECT, 0)
        set objects[4] = Object_Allocate(TYPE_ID_OBJECT, 0)

        call Assert(IsNull(objects[1]), "IsNull(objects[1])")

        call Assert(not IsNull(objects[1]), "not IsNull(objects[1])")
        call Assert(not IsNull(objects[2]), "not IsNull(objects[2])")
        call Assert(not IsNull(objects[3]), "not IsNull(objects[3])")
        call Assert(not IsNull(objects[4]), "not IsNull(objects[4])")

        call Object_Free(objects[1])
        call Object_Free(objects[2])
        call Object_Free(objects[3])
        call Object_Free(objects[4])

        call Assert(IsNull(objects[1]), "IsNull(objects[1])")
        call Assert(IsNull(objects[2]), "IsNull(objects[2])")
        call Assert(IsNull(objects[3]), "IsNull(objects[3])")
        call Assert(IsNull(objects[4]), "IsNull(objects[4])")

        call DebugLog(LOG_INFO, "Object_Test finished.")
    endif
endfunction