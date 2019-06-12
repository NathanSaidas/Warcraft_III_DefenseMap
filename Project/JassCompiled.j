// ______________________________________________
// Scripts/Core/Constants
// ----------------------------------------------
//___________________________________________________
//  Table Constants
//---------------------------------------------------
//  These correspond to a first index within the
//  global table. They must not conflict with each
//  other.
//---------------------------------------------------

// Object System Globals:
globals
    constant integer LIST_NAME_INDEX = 0
    constant integer LIST_SIZE_INDEX = 1
    constant integer LIST_DATA_INDEX = 2
    constant integer LIST_TABLE_SIZE_INDEX = 3
    constant integer SYSTEM_INDEX = 4 // unused:
    constant integer OBJECT_HANDLE_INDEX = 5
    constant integer OBJECT_NAME_INDEX = 6
    constant integer DATABASE_INDEX = 7

    constant integer LOG_INFO = 0
    constant integer LOG_WARNING = 1
    constant integer LOG_ERROR = 2

    constant integer INVALID = -1
    constant real GAME_DELTA = 0.1

    constant boolean IS_DEBUG = false

    // Deprecated
    constant integer OBJECT_EX_INDEX = 8
    constant integer LIST_EX_INDEX = 10
endglobals

globals
    // Config:
    constant boolean CONFIG_ENABLE_TESTS = false
    constant boolean CONFIG_ENABLE_DEBUG = true
    constant boolean CONFIG_OBJECT_ENABLE_LOGGING = false
    constant boolean CONFIG_THREAD_ENABLE_LOGGING = true
    constant boolean CONFIG_GAME_ENABLE_LOGGING = true
    constant boolean CONFIG_GAME_FAST_START = false

    constant boolean CONFIG_DEFENSE_MAP = false
    constant boolean CONFIG_SIEGE_RACER_MAP = true
endglobals

// ============================================================================================
// =======================                 Object Type Ids              =======================
// ============================================================================================

globals
    // Natives are negative
    constant integer TYPE_ID_INT = -1
    constant integer TYPE_ID_REAL = -2
    constant integer TYPE_ID_STRING = -3
    constant integer TYPE_ID_BOOL = -4
    constant integer TYPE_ID_HANDLE = -5
    constant integer TYPE_ID_EFFECT = -6
    constant integer TYPE_ID_LOCATION = -7
    constant integer TYPE_ID_RECT = -8
    constant integer TYPE_ID_TIMER = -9
    constant integer TYPE_ID_UNIT = -10
    constant integer TYPE_ID_ITEM = -11
    constant integer TYPE_ID_TRIGGER = -12
    constant integer TYPE_ID_TEXTTAG = -13
    constant integer TYPE_ID_QUEST = -14
    constant integer TYPE_ID_NATIVE_MAX = -15
endglobals


// trigger Id for local storage
function TRIGGER_MAIN takes nothing returns integer
    return 0
endfunction
// ______________________________________________
// Scripts/Core/Util
// ----------------------------------------------
globals
    // Temporaries:
    trigger     gReturnTrigger  = null
    hashtable   gReturnTable    = null
    rect        gReturnRect     = null
    unit        gReturnUnit     = null
    player      gReturnPlayer   = null

    // Internal:
    hashtable   gTable = InitHashtable()
    hashtable   gObject = InitHashtable()
    hashtable   gList = InitHashtable()
    boolean     gConfigLogInfo = true
    boolean     gConfigLogWarning = true
    boolean     gConfigLogError = true
endglobals

function Print takes string msg returns nothing
    call DisplayTextToForce(GetPlayersAll(), msg)
endfunction

function DebugLog takes integer logLevel, string msg returns nothing
    local string printMsg = ""
    if logLevel == LOG_INFO and gConfigLogInfo then
        set printMsg = "[Info]: " + msg
    elseif logLevel == LOG_WARNING and gConfigLogWarning then
        set printMsg = "[Warning]: " + msg
    elseif logLevel == LOG_ERROR and gConfigLogError then
        set printMsg = "[Error]: " + msg
    endif
    call Print(printMsg)
endfunction

function BeginDebug takes nothing returns nothing
    call Print("[Debug]: BeginDebug")
endfunction

function EndDebug takes nothing returns nothing
    call Print("[Debug]: EndDebug")
endfunction

function Sleep takes real t returns nothing
    call PolledWait(t)
endfunction

function AccessViolation takes string sender returns nothing
    call DebugLog(LOG_ERROR, sender + " failed! Access violation!")
    call Sleep(1)
endfunction

function B2I takes boolean b returns integer
    if b == true then
        return 1
    else
        return 0
    endif
    return 0
endfunction

function I2B takes integer i returns boolean
    if i != 0 then
        return true
    else
        return false
    endif
    return false
endfunction

function B2S takes boolean b returns string
    if b then
        return "true"
    endif
    return "false"
endfunction

function MinI takes integer a, integer b returns integer
    if a < b then
        return a
    endif
    return b
endfunction

function MaxI takes integer a, integer b returns integer
    if a > b then
        return a
    endif
    return b
endfunction

function MinR takes real a, real b returns real
    if a < b then
        return a
    endif
    return b
endfunction

function MaxR takes real a, real b returns real
    if a > b then
        return a
    endif
    return b
endfunction

function Abs takes integer value returns integer
    if value < 0 then
        return value * -1
    endif
    return value
endfunction

function FAbs takes real value returns real
    if value < 0.0 then
        return value * -1.0
    endif
    return value
endfunction

// PUBLIC STATIC: Returns true if the integer is not -1
function Valid takes integer value returns boolean
    if value != -1 then
        return true
    endif
    return false
endfunction

// PUBLIC STATIC: Returns true if the integer is -1
function Invalid takes integer value returns boolean
    if value == -1 then
        return true
    endif
    return false
endfunction

function Assert takes boolean exprValue, string expression returns nothing
    if not exprValue then
        call DebugLog(LOG_ERROR, "Assertion failed: " + expression)
    endif
endfunction

function GetChar takes string str, integer index returns string
    return SubString(str, index, index + 1)
endfunction

// makes the 2 players enemies with each other
function SetPlayerEnemy takes player a, player b returns nothing
    if a == null or b == null or a == b then
        return
    endif

    call SetPlayerAllianceStateBJ(a, b, bj_ALLIANCE_UNALLIED)
    call SetPlayerAllianceStateBJ(b, a, bj_ALLIANCE_UNALLIED)
    call SetPlayerAlliance(a, b, ALLIANCE_SHARED_VISION, false)
    call SetPlayerAlliance(b, a, ALLIANCE_SHARED_VISION, false)

    call SetPlayerAlliance(a, b, ALLIANCE_SHARED_XP, false)
    call SetPlayerAlliance(b, a, ALLIANCE_SHARED_XP, false)

    call SetPlayerAlliance(a, b, ALLIANCE_SHARED_SPELLS, false)
    call SetPlayerAlliance(b, a, ALLIANCE_SHARED_SPELLS, false)
endfunction

// makes the 2 players friendly with each other
function SetPlayerFriendly takes player a, player b returns nothing
    if a == null or b == null or a == b then
        return
    endif

    call SetPlayerAllianceStateBJ(a, b, bj_ALLIANCE_ALLIED)
    call SetPlayerAllianceStateBJ(b, a, bj_ALLIANCE_ALLIED)

    call SetPlayerAlliance(a, b, ALLIANCE_SHARED_VISION, true)
    call SetPlayerAlliance(b, a, ALLIANCE_SHARED_VISION, true)

    call SetPlayerAlliance(a, b, ALLIANCE_SHARED_XP, true)
    call SetPlayerAlliance(b, a, ALLIANCE_SHARED_XP, true)

    call SetPlayerAlliance(a, b, ALLIANCE_SHARED_SPELLS, true)
    call SetPlayerAlliance(b, a, ALLIANCE_SHARED_SPELLS, true)
endfunction

function SetPlayerNeutral takes player a, player b returns nothing
    if a == null or b == null or a == b then
        return
    endif

    call SetPlayerAllianceStateBJ(a, b, bj_ALLIANCE_ALLIED)
    call SetPlayerAllianceStateBJ(b, a, bj_ALLIANCE_ALLIED)

    call SetPlayerAlliance(a, b, ALLIANCE_SHARED_VISION, false)
    call SetPlayerAlliance(b, a, ALLIANCE_SHARED_VISION, false)

    call SetPlayerAlliance(a, b, ALLIANCE_SHARED_XP, false)
    call SetPlayerAlliance(b, a, ALLIANCE_SHARED_XP, false)

    call SetPlayerAlliance(a, b, ALLIANCE_SHARED_SPELLS, false)
    call SetPlayerAlliance(b, a, ALLIANCE_SHARED_SPELLS, false)
endfunction// ______________________________________________
// Scripts/Core/Object
// ----------------------------------------------
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


globals
    constant integer TYPE_ID_OBJECT = 0
    constant integer TYPE_ID_CMD = 1
    constant integer TYPE_ID_CMD_HANDLER = 2
    constant integer TYPE_ID_THREAD = 3
    constant integer TYPE_ID_THREAD_DRIVER = 4
    constant integer TYPE_ID_UNIT_TYPE_DATA = 5
    constant integer TYPE_ID_PLAYER_DATA = 6
    constant integer TYPE_ID_COMPONENT = 7
    constant integer TYPE_ID_UNIT_DATA = 8
    constant integer TYPE_ID_SPAWN_WAVE_DATA = 9
    constant integer TYPE_ID_RUN_TO_CITY_COMPONENT = 10
    constant integer TYPE_ID_PLAYER_HERO_COMPONENT = 11
    constant integer TYPE_ID_MONITOR_UNIT_LIFE_COMPONENT = 12
    constant integer TYPE_ID_MAX = 13
endglobals

function Object_RegisterTypes takes nothing returns nothing
    call ps_Object_RegisterType(TYPE_ID_OBJECT, "object", 500, 500)
    call ps_Object_RegisterType(TYPE_ID_CMD, "Cmd", 1, 1)
    call ps_Object_RegisterType(TYPE_ID_CMD_HANDLER, "CmdHandler", 500, 1)
    call ps_Object_RegisterType(TYPE_ID_THREAD, "Thread", 1, 1)
    call ps_Object_RegisterType(TYPE_ID_THREAD_DRIVER, "ThreadDriver", 500, 1)
    call ps_Object_RegisterType(TYPE_ID_UNIT_TYPE_DATA, "UnitTypeData", 1000, 1000)
    call ps_Object_RegisterType(TYPE_ID_PLAYER_DATA, "PlayerData", 25, 25)
    call ps_Object_RegisterType(TYPE_ID_COMPONENT, "Component", 1000, 1000)
    call ps_Object_RegisterType(TYPE_ID_UNIT_DATA, "UnitData", 500, 500)
    call ps_Object_RegisterType(TYPE_ID_SPAWN_WAVE_DATA, "SpawnWaveData", 100, 100)
    call ps_Object_RegisterType(TYPE_ID_RUN_TO_CITY_COMPONENT, "RunToCityComponent", 1000, 1000)
    call ps_Object_RegisterType(TYPE_ID_PLAYER_HERO_COMPONENT, "PlayerHeroComponent", 1000, 1000)
    call ps_Object_RegisterType(TYPE_ID_MONITOR_UNIT_LIFE_COMPONENT, "MonitorUnitLifeComponent", 1000, 1000)
endfunction

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
endfunction// ______________________________________________
// Scripts/Core/List
// ----------------------------------------------
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
endfunction// ______________________________________________
// Scripts/Core/ListTemplates
// ----------------------------------------------
// PUBLIC:
function List_GetInt takes integer self, integer index returns integer
    if not p_List_VerifyAccess(self, index, TYPE_ID_INT ) then
        return 0
    endif
    return LoadInteger(gObject, self, index)
endfunction

// PUBLIC:
function List_SetInt takes integer self, integer index, integer value returns nothing
    if not p_List_VerifyAccess(self, index, TYPE_ID_INT ) then
        return
    endif
    call SaveInteger(gObject, self, index, value)
endfunction

//PUBLIC:
function List_AddInt takes integer self, integer value returns nothing
    local integer size = LoadInteger(gObject, self, p_List_Size)
    if not p_List_VerifyType(self, TYPE_ID_INT ) then
        return
    endif
    call SaveInteger(gObject, self, p_List_Size, size + 1)
    call SaveInteger(gObject, self, size, value)
endfunction

//PUBLIC:
function List_RemoveInt takes integer self, integer index returns nothing
    local integer i = index
    local integer size = LoadInteger(gObject, self, p_List_Size) - 1
    // TypeCheck:
    if not p_List_VerifyAccess(self, index, TYPE_ID_INT) then
        return
    endif
    // Move down:
    loop
        exitwhen i >= size
        call SaveInteger(gObject, self, i, LoadInteger(gObject, self, i+1))
        set i = i + 1
    endloop
    // Remove:
    if size >= 0 then
        call RemoveSavedInteger(gObject, self, size+1)
    endif
    call SaveInteger(gObject, self, p_List_Size, size)
endfunction

//PUBLIC:
function List_FindInt takes integer self, integer value returns integer
    local integer i = 0
    local integer size = LoadInteger(gObject, self, p_List_Size)
    // TypeCheck:
    if not p_List_VerifyType(self, TYPE_ID_INT) then
        return INVALID
    endif

    loop
        exitwhen i >= size
        if LoadInteger(gObject, self, i) == value then
            return i
        endif
        set i = i + 1
    endloop

    return INVALID
endfunction
// PUBLIC:
function List_GetReal takes integer self, integer index returns real
    if not p_List_VerifyAccess(self, index, TYPE_ID_REAL ) then
        return 0.0
    endif
    return LoadReal(gObject, self, index)
endfunction

// PUBLIC:
function List_SetReal takes integer self, integer index, real value returns nothing
    if not p_List_VerifyAccess(self, index, TYPE_ID_REAL ) then
        return
    endif
    call SaveReal(gObject, self, index, value)
endfunction

//PUBLIC:
function List_AddReal takes integer self, real value returns nothing
    local integer size = LoadInteger(gObject, self, p_List_Size)
    if not p_List_VerifyType(self, TYPE_ID_REAL ) then
        return
    endif
    call SaveInteger(gObject, self, p_List_Size, size + 1)
    call SaveReal(gObject, self, size, value)
endfunction

//PUBLIC:
function List_RemoveReal takes integer self, integer index returns nothing
    local integer i = index
    local integer size = LoadInteger(gObject, self, p_List_Size) - 1
    // TypeCheck:
    if not p_List_VerifyAccess(self, index, TYPE_ID_REAL) then
        return
    endif
    // Move down:
    loop
        exitwhen i >= size
        call SaveReal(gObject, self, i, LoadReal(gObject, self, i+1))
        set i = i + 1
    endloop
    // Remove:
    if size >= 0 then
        call RemoveSavedReal(gObject, self, size+1)
    endif
    call SaveInteger(gObject, self, p_List_Size, size)
endfunction

//PUBLIC:
function List_FindReal takes integer self, real value returns integer
    local integer i = 0
    local integer size = LoadInteger(gObject, self, p_List_Size)
    // TypeCheck:
    if not p_List_VerifyType(self, TYPE_ID_REAL) then
        return INVALID
    endif

    loop
        exitwhen i >= size
        if LoadReal(gObject, self, i) == value then
            return i
        endif
        set i = i + 1
    endloop

    return INVALID
endfunction
// PUBLIC:
function List_GetString takes integer self, integer index returns string
    if not p_List_VerifyAccess(self, index, TYPE_ID_STRING ) then
        return ""
    endif
    return LoadStr(gObject, self, index)
endfunction

// PUBLIC:
function List_SetString takes integer self, integer index, string value returns nothing
    if not p_List_VerifyAccess(self, index, TYPE_ID_STRING ) then
        return
    endif
    call SaveStr(gObject, self, index, value)
endfunction

//PUBLIC:
function List_AddString takes integer self, string value returns nothing
    local integer size = LoadInteger(gObject, self, p_List_Size)
    if not p_List_VerifyType(self, TYPE_ID_STRING ) then
        return
    endif
    call SaveInteger(gObject, self, p_List_Size, size + 1)
    call SaveStr(gObject, self, size, value)
endfunction

//PUBLIC:
function List_RemoveString takes integer self, integer index returns nothing
    local integer i = index
    local integer size = LoadInteger(gObject, self, p_List_Size) - 1
    // TypeCheck:
    if not p_List_VerifyAccess(self, index, TYPE_ID_STRING) then
        return
    endif
    // Move down:
    loop
        exitwhen i >= size
        call SaveStr(gObject, self, i, LoadStr(gObject, self, i+1))
        set i = i + 1
    endloop
    // Remove:
    if size >= 0 then
        call RemoveSavedString(gObject, self, size+1)
    endif
    call SaveInteger(gObject, self, p_List_Size, size)
endfunction

//PUBLIC:
function List_FindString takes integer self, string value returns integer
    local integer i = 0
    local integer size = LoadInteger(gObject, self, p_List_Size)
    // TypeCheck:
    if not p_List_VerifyType(self, TYPE_ID_STRING) then
        return INVALID
    endif

    loop
        exitwhen i >= size
        if LoadStr(gObject, self, i) == value then
            return i
        endif
        set i = i + 1
    endloop

    return INVALID
endfunction
// PUBLIC:
function List_GetBool takes integer self, integer index returns boolean
    if not p_List_VerifyAccess(self, index, TYPE_ID_BOOL ) then
        return false
    endif
    return LoadBoolean(gObject, self, index)
endfunction

// PUBLIC:
function List_SetBool takes integer self, integer index, boolean value returns nothing
    if not p_List_VerifyAccess(self, index, TYPE_ID_BOOL ) then
        return
    endif
    call SaveBoolean(gObject, self, index, value)
endfunction

//PUBLIC:
function List_AddBool takes integer self, boolean value returns nothing
    local integer size = LoadInteger(gObject, self, p_List_Size)
    if not p_List_VerifyType(self, TYPE_ID_BOOL ) then
        return
    endif
    call SaveInteger(gObject, self, p_List_Size, size + 1)
    call SaveBoolean(gObject, self, size, value)
endfunction

//PUBLIC:
function List_RemoveBool takes integer self, integer index returns nothing
    local integer i = index
    local integer size = LoadInteger(gObject, self, p_List_Size) - 1
    // TypeCheck:
    if not p_List_VerifyAccess(self, index, TYPE_ID_BOOL) then
        return
    endif
    // Move down:
    loop
        exitwhen i >= size
        call SaveBoolean(gObject, self, i, LoadBoolean(gObject, self, i+1))
        set i = i + 1
    endloop
    // Remove:
    if size >= 0 then
        call RemoveSavedBoolean(gObject, self, size+1)
    endif
    call SaveInteger(gObject, self, p_List_Size, size)
endfunction

//PUBLIC:
function List_FindBool takes integer self, boolean value returns integer
    local integer i = 0
    local integer size = LoadInteger(gObject, self, p_List_Size)
    // TypeCheck:
    if not p_List_VerifyType(self, TYPE_ID_BOOL) then
        return INVALID
    endif

    loop
        exitwhen i >= size
        if LoadBoolean(gObject, self, i) == value then
            return i
        endif
        set i = i + 1
    endloop

    return INVALID
endfunction
// PUBLIC:
function List_GetUnit takes integer self, integer index returns unit
    if not p_List_VerifyAccess(self, index, TYPE_ID_UNIT ) then
        return null
    endif
    return LoadUnitHandle(gObject, self, index)
endfunction

// PUBLIC:
function List_SetUnit takes integer self, integer index, unit value returns nothing
    if not p_List_VerifyAccess(self, index, TYPE_ID_UNIT ) then
        return
    endif
    call SaveUnitHandle(gObject, self, index, value)
endfunction

//PUBLIC:
function List_AddUnit takes integer self, unit value returns nothing
    local integer size = LoadInteger(gObject, self, p_List_Size)
    if not p_List_VerifyType(self, TYPE_ID_UNIT ) then
        return
    endif
    call SaveInteger(gObject, self, p_List_Size, size + 1)
    call SaveUnitHandle(gObject, self, size, value)
endfunction

//PUBLIC:
function List_RemoveUnit takes integer self, integer index returns nothing
    local integer i = index
    local integer size = LoadInteger(gObject, self, p_List_Size) - 1
    // TypeCheck:
    if not p_List_VerifyAccess(self, index, TYPE_ID_UNIT) then
        return
    endif
    // Move down:
    loop
        exitwhen i >= size
        call SaveUnitHandle(gObject, self, i, LoadUnitHandle(gObject, self, i+1))
        set i = i + 1
    endloop
    // Remove:
    if size >= 0 then
        call RemoveSavedHandle(gObject, self, size+1)
    endif
    call SaveInteger(gObject, self, p_List_Size, size)
endfunction

//PUBLIC:
function List_FindUnit takes integer self, unit value returns integer
    local integer i = 0
    local integer size = LoadInteger(gObject, self, p_List_Size)
    // TypeCheck:
    if not p_List_VerifyType(self, TYPE_ID_UNIT) then
        return INVALID
    endif

    loop
        exitwhen i >= size
        if LoadUnitHandle(gObject, self, i) == value then
            return i
        endif
        set i = i + 1
    endloop

    return INVALID
endfunction
// PUBLIC:
function List_GetEffect takes integer self, integer index returns effect
    if not p_List_VerifyAccess(self, index, TYPE_ID_EFFECT ) then
        return null
    endif
    return LoadEffectHandle(gObject, self, index)
endfunction

// PUBLIC:
function List_SetEffect takes integer self, integer index, effect value returns nothing
    if not p_List_VerifyAccess(self, index, TYPE_ID_EFFECT ) then
        return
    endif
    call SaveEffectHandle(gObject, self, index, value)
endfunction

//PUBLIC:
function List_AddEffect takes integer self, effect value returns nothing
    local integer size = LoadInteger(gObject, self, p_List_Size)
    if not p_List_VerifyType(self, TYPE_ID_EFFECT ) then
        return
    endif
    call SaveInteger(gObject, self, p_List_Size, size + 1)
    call SaveEffectHandle(gObject, self, size, value)
endfunction

//PUBLIC:
function List_RemoveEffect takes integer self, integer index returns nothing
    local integer i = index
    local integer size = LoadInteger(gObject, self, p_List_Size) - 1
    // TypeCheck:
    if not p_List_VerifyAccess(self, index, TYPE_ID_EFFECT) then
        return
    endif
    // Move down:
    loop
        exitwhen i >= size
        call SaveEffectHandle(gObject, self, i, LoadEffectHandle(gObject, self, i+1))
        set i = i + 1
    endloop
    // Remove:
    if size >= 0 then
        call RemoveSavedHandle(gObject, self, size+1)
    endif
    call SaveInteger(gObject, self, p_List_Size, size)
endfunction

//PUBLIC:
function List_FindEffect takes integer self, effect value returns integer
    local integer i = 0
    local integer size = LoadInteger(gObject, self, p_List_Size)
    // TypeCheck:
    if not p_List_VerifyType(self, TYPE_ID_EFFECT) then
        return INVALID
    endif

    loop
        exitwhen i >= size
        if LoadEffectHandle(gObject, self, i) == value then
            return i
        endif
        set i = i + 1
    endloop

    return INVALID
endfunction
// PUBLIC:
function List_GetObject takes integer self, integer index returns integer
    if not p_List_VerifyAccess(self, index, TYPE_ID_OBJECT ) then
        return INVALID
    endif
    return LoadInteger(gObject, self, index)
endfunction

// PUBLIC:
function List_SetObject takes integer self, integer index, integer value returns nothing
    if not p_List_VerifyAccess(self, index, TYPE_ID_OBJECT ) then
        return
    endif
    call SaveInteger(gObject, self, index, value)
endfunction

//PUBLIC:
function List_AddObject takes integer self, integer value returns nothing
    local integer size = LoadInteger(gObject, self, p_List_Size)
    if not p_List_VerifyType(self, TYPE_ID_OBJECT ) then
        return
    endif
    call SaveInteger(gObject, self, p_List_Size, size + 1)
    call SaveInteger(gObject, self, size, value)
endfunction

//PUBLIC:
function List_RemoveObject takes integer self, integer index returns nothing
    local integer i = index
    local integer size = LoadInteger(gObject, self, p_List_Size) - 1
    // TypeCheck:
    if not p_List_VerifyAccess(self, index, TYPE_ID_OBJECT) then
        return
    endif
    // Move down:
    loop
        exitwhen i >= size
        call SaveInteger(gObject, self, i, LoadInteger(gObject, self, i+1))
        set i = i + 1
    endloop
    // Remove:
    if size >= 0 then
        call RemoveSavedInteger(gObject, self, size+1)
    endif
    call SaveInteger(gObject, self, p_List_Size, size)
endfunction

//PUBLIC:
function List_FindObject takes integer self, integer value returns integer
    local integer i = 0
    local integer size = LoadInteger(gObject, self, p_List_Size)
    // TypeCheck:
    if not p_List_VerifyType(self, TYPE_ID_OBJECT) then
        return INVALID
    endif

    loop
        exitwhen i >= size
        if LoadInteger(gObject, self, i) == value then
            return i
        endif
        set i = i + 1
    endloop

    return INVALID
endfunction
// PUBLIC:
function List_GetLocation takes integer self, integer index returns location
    if not p_List_VerifyAccess(self, index, TYPE_ID_LOCATION ) then
        return null
    endif
    return LoadLocationHandle(gObject, self, index)
endfunction

// PUBLIC:
function List_SetLocation takes integer self, integer index, location value returns nothing
    if not p_List_VerifyAccess(self, index, TYPE_ID_LOCATION ) then
        return
    endif
    call SaveLocationHandle(gObject, self, index, value)
endfunction

//PUBLIC:
function List_AddLocation takes integer self, location value returns nothing
    local integer size = LoadInteger(gObject, self, p_List_Size)
    if not p_List_VerifyType(self, TYPE_ID_LOCATION ) then
        return
    endif
    call SaveInteger(gObject, self, p_List_Size, size + 1)
    call SaveLocationHandle(gObject, self, size, value)
endfunction

//PUBLIC:
function List_RemoveLocation takes integer self, integer index returns nothing
    local integer i = index
    local integer size = LoadInteger(gObject, self, p_List_Size) - 1
    // TypeCheck:
    if not p_List_VerifyAccess(self, index, TYPE_ID_LOCATION) then
        return
    endif
    // Move down:
    loop
        exitwhen i >= size
        call SaveLocationHandle(gObject, self, i, LoadLocationHandle(gObject, self, i+1))
        set i = i + 1
    endloop
    // Remove:
    if size >= 0 then
        call RemoveSavedHandle(gObject, self, size+1)
    endif
    call SaveInteger(gObject, self, p_List_Size, size)
endfunction

//PUBLIC:
function List_FindLocation takes integer self, location value returns integer
    local integer i = 0
    local integer size = LoadInteger(gObject, self, p_List_Size)
    // TypeCheck:
    if not p_List_VerifyType(self, TYPE_ID_LOCATION) then
        return INVALID
    endif

    loop
        exitwhen i >= size
        if LoadLocationHandle(gObject, self, i) == value then
            return i
        endif
        set i = i + 1
    endloop

    return INVALID
endfunction
// PUBLIC:
function List_GetRect takes integer self, integer index returns rect
    if not p_List_VerifyAccess(self, index, TYPE_ID_RECT ) then
        return null
    endif
    return LoadRectHandle(gObject, self, index)
endfunction

// PUBLIC:
function List_SetRect takes integer self, integer index, rect value returns nothing
    if not p_List_VerifyAccess(self, index, TYPE_ID_RECT ) then
        return
    endif
    call SaveRectHandle(gObject, self, index, value)
endfunction

//PUBLIC:
function List_AddRect takes integer self, rect value returns nothing
    local integer size = LoadInteger(gObject, self, p_List_Size)
    if not p_List_VerifyType(self, TYPE_ID_RECT ) then
        return
    endif
    call SaveInteger(gObject, self, p_List_Size, size + 1)
    call SaveRectHandle(gObject, self, size, value)
endfunction

//PUBLIC:
function List_RemoveRect takes integer self, integer index returns nothing
    local integer i = index
    local integer size = LoadInteger(gObject, self, p_List_Size) - 1
    // TypeCheck:
    if not p_List_VerifyAccess(self, index, TYPE_ID_RECT) then
        return
    endif
    // Move down:
    loop
        exitwhen i >= size
        call SaveRectHandle(gObject, self, i, LoadRectHandle(gObject, self, i+1))
        set i = i + 1
    endloop
    // Remove:
    if size >= 0 then
        call RemoveSavedHandle(gObject, self, size+1)
    endif
    call SaveInteger(gObject, self, p_List_Size, size)
endfunction

//PUBLIC:
function List_FindRect takes integer self, rect value returns integer
    local integer i = 0
    local integer size = LoadInteger(gObject, self, p_List_Size)
    // TypeCheck:
    if not p_List_VerifyType(self, TYPE_ID_RECT) then
        return INVALID
    endif

    loop
        exitwhen i >= size
        if LoadRectHandle(gObject, self, i) == value then
            return i
        endif
        set i = i + 1
    endloop

    return INVALID
endfunction
// PUBLIC:
function List_GetTimer takes integer self, integer index returns timer
    if not p_List_VerifyAccess(self, index, TYPE_ID_TIMER ) then
        return null
    endif
    return LoadTimerHandle(gObject, self, index)
endfunction

// PUBLIC:
function List_SetTimer takes integer self, integer index, timer value returns nothing
    if not p_List_VerifyAccess(self, index, TYPE_ID_TIMER ) then
        return
    endif
    call SaveTimerHandle(gObject, self, index, value)
endfunction

//PUBLIC:
function List_AddTimer takes integer self, timer value returns nothing
    local integer size = LoadInteger(gObject, self, p_List_Size)
    if not p_List_VerifyType(self, TYPE_ID_TIMER ) then
        return
    endif
    call SaveInteger(gObject, self, p_List_Size, size + 1)
    call SaveTimerHandle(gObject, self, size, value)
endfunction

//PUBLIC:
function List_RemoveTimer takes integer self, integer index returns nothing
    local integer i = index
    local integer size = LoadInteger(gObject, self, p_List_Size) - 1
    // TypeCheck:
    if not p_List_VerifyAccess(self, index, TYPE_ID_TIMER) then
        return
    endif
    // Move down:
    loop
        exitwhen i >= size
        call SaveTimerHandle(gObject, self, i, LoadTimerHandle(gObject, self, i+1))
        set i = i + 1
    endloop
    // Remove:
    if size >= 0 then
        call RemoveSavedHandle(gObject, self, size+1)
    endif
    call SaveInteger(gObject, self, p_List_Size, size)
endfunction

//PUBLIC:
function List_FindTimer takes integer self, timer value returns integer
    local integer i = 0
    local integer size = LoadInteger(gObject, self, p_List_Size)
    // TypeCheck:
    if not p_List_VerifyType(self, TYPE_ID_TIMER) then
        return INVALID
    endif

    loop
        exitwhen i >= size
        if LoadTimerHandle(gObject, self, i) == value then
            return i
        endif
        set i = i + 1
    endloop

    return INVALID
endfunction
// PUBLIC:
function List_GetTrigger takes integer self, integer index returns trigger
    if not p_List_VerifyAccess(self, index, TYPE_ID_TRIGGER ) then
        return null
    endif
    return LoadTriggerHandle(gObject, self, index)
endfunction

// PUBLIC:
function List_SetTrigger takes integer self, integer index, trigger value returns nothing
    if not p_List_VerifyAccess(self, index, TYPE_ID_TRIGGER ) then
        return
    endif
    call SaveTriggerHandle(gObject, self, index, value)
endfunction

//PUBLIC:
function List_AddTrigger takes integer self, trigger value returns nothing
    local integer size = LoadInteger(gObject, self, p_List_Size)
    if not p_List_VerifyType(self, TYPE_ID_TRIGGER ) then
        return
    endif
    call SaveInteger(gObject, self, p_List_Size, size + 1)
    call SaveTriggerHandle(gObject, self, size, value)
endfunction

//PUBLIC:
function List_RemoveTrigger takes integer self, integer index returns nothing
    local integer i = index
    local integer size = LoadInteger(gObject, self, p_List_Size) - 1
    // TypeCheck:
    if not p_List_VerifyAccess(self, index, TYPE_ID_TRIGGER) then
        return
    endif
    // Move down:
    loop
        exitwhen i >= size
        call SaveTriggerHandle(gObject, self, i, LoadTriggerHandle(gObject, self, i+1))
        set i = i + 1
    endloop
    // Remove:
    if size >= 0 then
        call RemoveSavedHandle(gObject, self, size+1)
    endif
    call SaveInteger(gObject, self, p_List_Size, size)
endfunction

//PUBLIC:
function List_FindTrigger takes integer self, trigger value returns integer
    local integer i = 0
    local integer size = LoadInteger(gObject, self, p_List_Size)
    // TypeCheck:
    if not p_List_VerifyType(self, TYPE_ID_TRIGGER) then
        return INVALID
    endif

    loop
        exitwhen i >= size
        if LoadTriggerHandle(gObject, self, i) == value then
            return i
        endif
        set i = i + 1
    endloop

    return INVALID
endfunction
// PUBLIC:
function List_GetQuest takes integer self, integer index returns quest
    if not p_List_VerifyAccess(self, index, TYPE_ID_QUEST ) then
        return null
    endif
    return LoadQuestHandle(gObject, self, index)
endfunction

// PUBLIC:
function List_SetQuest takes integer self, integer index, quest value returns nothing
    if not p_List_VerifyAccess(self, index, TYPE_ID_QUEST ) then
        return
    endif
    call SaveQuestHandle(gObject, self, index, value)
endfunction

//PUBLIC:
function List_AddQuest takes integer self, quest value returns nothing
    local integer size = LoadInteger(gObject, self, p_List_Size)
    if not p_List_VerifyType(self, TYPE_ID_QUEST ) then
        return
    endif
    call SaveInteger(gObject, self, p_List_Size, size + 1)
    call SaveQuestHandle(gObject, self, size, value)
endfunction

//PUBLIC:
function List_RemoveQuest takes integer self, integer index returns nothing
    local integer i = index
    local integer size = LoadInteger(gObject, self, p_List_Size) - 1
    // TypeCheck:
    if not p_List_VerifyAccess(self, index, TYPE_ID_QUEST) then
        return
    endif
    // Move down:
    loop
        exitwhen i >= size
        call SaveQuestHandle(gObject, self, i, LoadQuestHandle(gObject, self, i+1))
        set i = i + 1
    endloop
    // Remove:
    if size >= 0 then
        call RemoveSavedHandle(gObject, self, size+1)
    endif
    call SaveInteger(gObject, self, p_List_Size, size)
endfunction

//PUBLIC:
function List_FindQuest takes integer self, quest value returns integer
    local integer i = 0
    local integer size = LoadInteger(gObject, self, p_List_Size)
    // TypeCheck:
    if not p_List_VerifyType(self, TYPE_ID_QUEST) then
        return INVALID
    endif

    loop
        exitwhen i >= size
        if LoadQuestHandle(gObject, self, i) == value then
            return i
        endif
        set i = i + 1
    endloop

    return INVALID
endfunction
// PUBLIC:
function List_GetItem takes integer self, integer index returns item
    if not p_List_VerifyAccess(self, index, TYPE_ID_ITEM ) then
        return null
    endif
    return LoadItemHandle(gObject, self, index)
endfunction

// PUBLIC:
function List_SetItem takes integer self, integer index, item value returns nothing
    if not p_List_VerifyAccess(self, index, TYPE_ID_ITEM ) then
        return
    endif
    call SaveItemHandle(gObject, self, index, value)
endfunction

//PUBLIC:
function List_AddItem takes integer self, item value returns nothing
    local integer size = LoadInteger(gObject, self, p_List_Size)
    if not p_List_VerifyType(self, TYPE_ID_ITEM ) then
        return
    endif
    call SaveInteger(gObject, self, p_List_Size, size + 1)
    call SaveItemHandle(gObject, self, size, value)
endfunction

//PUBLIC:
function List_RemoveItem takes integer self, integer index returns nothing
    local integer i = index
    local integer size = LoadInteger(gObject, self, p_List_Size) - 1
    // TypeCheck:
    if not p_List_VerifyAccess(self, index, TYPE_ID_ITEM) then
        return
    endif
    // Move down:
    loop
        exitwhen i >= size
        call SaveItemHandle(gObject, self, i, LoadItemHandle(gObject, self, i+1))
        set i = i + 1
    endloop
    // Remove:
    if size >= 0 then
        call RemoveSavedHandle(gObject, self, size+1)
    endif
    call SaveInteger(gObject, self, p_List_Size, size)
endfunction

//PUBLIC:
function List_FindItem takes integer self, item value returns integer
    local integer i = 0
    local integer size = LoadInteger(gObject, self, p_List_Size)
    // TypeCheck:
    if not p_List_VerifyType(self, TYPE_ID_ITEM) then
        return INVALID
    endif

    loop
        exitwhen i >= size
        if LoadItemHandle(gObject, self, i) == value then
            return i
        endif
        set i = i + 1
    endloop

    return INVALID
endfunction
// PUBLIC:
function List_GetTextTag takes integer self, integer index returns texttag
    if not p_List_VerifyAccess(self, index, TYPE_ID_TEXTTAG ) then
        return null
    endif
    return LoadTextTagHandle(gObject, self, index)
endfunction

// PUBLIC:
function List_SetTextTag takes integer self, integer index, texttag value returns nothing
    if not p_List_VerifyAccess(self, index, TYPE_ID_TEXTTAG ) then
        return
    endif
    call SaveTextTagHandle(gObject, self, index, value)
endfunction

//PUBLIC:
function List_AddTextTag takes integer self, texttag value returns nothing
    local integer size = LoadInteger(gObject, self, p_List_Size)
    if not p_List_VerifyType(self, TYPE_ID_TEXTTAG ) then
        return
    endif
    call SaveInteger(gObject, self, p_List_Size, size + 1)
    call SaveTextTagHandle(gObject, self, size, value)
endfunction

//PUBLIC:
function List_RemoveTextTag takes integer self, integer index returns nothing
    local integer i = index
    local integer size = LoadInteger(gObject, self, p_List_Size) - 1
    // TypeCheck:
    if not p_List_VerifyAccess(self, index, TYPE_ID_TEXTTAG) then
        return
    endif
    // Move down:
    loop
        exitwhen i >= size
        call SaveTextTagHandle(gObject, self, i, LoadTextTagHandle(gObject, self, i+1))
        set i = i + 1
    endloop
    // Remove:
    if size >= 0 then
        call RemoveSavedHandle(gObject, self, size+1)
    endif
    call SaveInteger(gObject, self, p_List_Size, size)
endfunction

//PUBLIC:
function List_FindTextTag takes integer self, texttag value returns integer
    local integer i = 0
    local integer size = LoadInteger(gObject, self, p_List_Size)
    // TypeCheck:
    if not p_List_VerifyType(self, TYPE_ID_TEXTTAG) then
        return INVALID
    endif

    loop
        exitwhen i >= size
        if LoadTextTagHandle(gObject, self, i) == value then
            return i
        endif
        set i = i + 1
    endloop

    return INVALID
endfunction
// ______________________________________________
// Scripts/Core/DisplayBoard
// ----------------------------------------------

// Manages multiboard displays:
// Game
// Debug

globals
    // multiboard slots
    constant integer MULTIBOARD_GAME = 0
    constant integer MULTIBOARD_OBJECT_WATCH = 1
    constant integer MULTIBOARD_THREAD_WATCH = 2
    constant integer MULTIBOARD_MAX_SLOT = 3

    constant integer MULTIBOARD_COLOR_WHITE = 0
    constant integer MULTIBOARD_COLOR_TITLE_YELLOW = 1

    multiboard array gMultiboards
    integer gCurrentMultiboard = INVALID
endglobals

function DisplayColor_GetR takes integer id returns integer
    if id == MULTIBOARD_COLOR_WHITE then
        return 255
    elseif id == MULTIBOARD_COLOR_TITLE_YELLOW then
        return 238
    endif
    return 255
endfunction
function DisplayColor_GetG takes integer id returns integer
    if id == MULTIBOARD_COLOR_WHITE then
        return 255
    elseif id == MULTIBOARD_COLOR_TITLE_YELLOW then
        return 200
    endif
    return 255
endfunction
function DisplayColor_GetB takes integer id returns integer
    if id == MULTIBOARD_COLOR_WHITE then
        return 255
    elseif id == MULTIBOARD_COLOR_TITLE_YELLOW then
        return 15
    endif
    return 255
endfunction


function DisplayBoard_Create takes integer slot, integer rows, integer columns, string title returns multiboard
    local multiboard mb = null
    if gMultiboards[slot] != null then
        call DebugLog(LOG_ERROR, "Failed to create multiboard at slot " + I2S(slot))
        return null
    endif
    set mb = CreateMultiboard()
    call MultiboardSetRowCount(mb, rows)
    call MultiboardSetColumnCount(mb, columns)
    call MultiboardSetTitleText(mb, title)
    set gMultiboards[slot] = mb
    set mb = null
    return gMultiboards[slot]
endfunction

function DisplayBoard_SetRowCount takes integer slot, integer rows returns nothing
    if slot >= 0 and slot <= MULTIBOARD_MAX_SLOT and gMultiboards[slot] != null then
        call MultiboardSetRowCount(gMultiboards[slot], rows)
    endif
endfunction

function DisplayBoard_GetRowCount takes integer slot returns integer
    if slot >= 0 and slot <= MULTIBOARD_MAX_SLOT and gMultiboards[slot] != null then
        return MultiboardGetRowCount(gMultiboards[slot])
    endif
    return 0
endfunction

function DisplayBoard_SetColumnCount takes integer slot, integer rows returns nothing
    if slot >= 0 and slot <= MULTIBOARD_MAX_SLOT and gMultiboards[slot] != null then
        call MultiboardSetColumnCount(gMultiboards[slot], rows)
    endif
endfunction

function DisplayBoard_GetColumnCount takes integer slot returns integer
    if slot >= 0 and slot <= MULTIBOARD_MAX_SLOT and gMultiboards[slot] != null then
        return MultiboardGetColumnCount(gMultiboards[slot])
    endif
    return 0
endfunction

function DisplayBoard_Show takes integer slot, boolean maximize returns nothing
    if slot == gCurrentMultiboard then
        return // redundant
    endif
    // hide current
    if gCurrentMultiboard >= 0 then
        call MultiboardDisplay(gMultiboards[gCurrentMultiboard], false)
        set gCurrentMultiboard = INVALID
    endif
    
    if slot >= 0 and slot < MULTIBOARD_MAX_SLOT then
        set gCurrentMultiboard = slot
        call MultiboardDisplay(gMultiboards[gCurrentMultiboard], true)
        call MultiboardMinimize(gMultiboards[gCurrentMultiboard], not maximize)
    endif
endfunction

function DisplayBoard_Hide takes nothing returns nothing
    if gCurrentMultiboard >= 0 and gMultiboards[gCurrentMultiboard] != null then
        call MultiboardDisplay(gMultiboards[gCurrentMultiboard], false)
        set gCurrentMultiboard = INVALID
    endif

    if gCurrentMultiboard == INVALID then
        call DisplayBoard_Show(MULTIBOARD_GAME, false)
    endif
endfunction

function DisplayBoard_GetCurrent takes nothing returns integer
    return gCurrentMultiboard
endfunction


// slot
// column
// row
// width
// text
// color
function DisplayBoard_SetTextItem takes integer slot, integer column, integer row, real width, string text, integer color returns nothing
    local multiboard mb = null
    local multiboarditem mbitem = null
    if slot < 0 or slot  >= MULTIBOARD_MAX_SLOT then
        call DebugLog(LOG_ERROR, "DisplayBoard_SetTextItem failed: Invalid slot " + I2S(slot))
        return
    endif
    set mb = gMultiboards[slot]
    if mb == null then
        return // silent fail:
    endif
    set mbitem = MultiboardGetItem(mb, row,column)
    if mbitem == null then
        set mb = null
        return // silent fail:
    endif

    call MultiboardSetItemStyle(mbitem, true, false)
    call MultiboardSetItemWidth(mbitem, width / 100.00)
    call MultiboardSetItemValue(mbitem, text)
    call MultiboardSetItemValueColor(mbitem, DisplayColor_GetR(color), DisplayColor_GetG(color), DisplayColor_GetB(color), 255)
    call MultiboardReleaseItem(mbitem)
    set mbitem = null
    set mb = null
endfunction// ______________________________________________
// Scripts/Core/Thread
// ----------------------------------------------
// ___________________________________________________________________________________________
// Object:
// -------------------------------------------------------------------------------------------
// Overview:
//    Threads are a way to distribute work throughout the game.. Basically there are certain operation
//    limits on each trigger.. but we can sleep for GAME_DELTA and reset the operation limit. However
//    we want to update as much as we can in one GAME_DELTA update so we split the work into different
//    virtual threads.
//    ThreadDriver is the term used that manages work of various domains.. NpcUpdateDriver XTownUpdateDriver
//    etc...
//
// Thread is a static API, however the ThreadDrivers are objects
//
// ThreadDriver members:
//  	int mMainTick;
//      int mLocalTick;
//      bool mRunning;
//      trigger mCallback;
//
//
//  When using a ThreadDriver it's important to keep mMainTick and mLocalTick in sync, if they differ by
//  THREAD_MAX_DIFF then the thread is considered "Stalled" meaning wc3 engine likely stopped it due to
//  passing max operation limit.
//  To keep a ThreadDriver in sync, make sure you're updating on GAME_DELTA (thats the only sleep allowed!)
//  and calling Thread_UpdateTick with the driver object.

// PRIVATE CONST: The maximum tick difference between local/main thread.
// In reality there should only be 1 but were generous :)


// struct
// {
//      integer mMainTick;
//      integer mLocalTick;
//      boolean mRunning;
//      trigger mCallback;
// };
globals
    constant integer THREAD_MAX_DIFF = 25

    constant integer ThreadDriver_mMainTick = 0
    constant integer ThreadDriver_mLocalTick = 1
    constant integer ThreadDriver_mRunning = 2
    constant integer ThreadDriver_mCallback = 3

    constant integer Thread_mDrivers = 0

    integer gThread = INVALID
endglobals

function Thread_PreInit takes nothing returns nothing
    set gThread = Object_Allocate(TYPE_ID_THREAD, 1)
    call SaveInteger(gObject, gThread, Thread_mDrivers, List_Create(TYPE_ID_THREAD_DRIVER))
endfunction

// PRIVATE: Thread update function.. Checks for stalls.
function p_Thread_Update takes integer drivers returns nothing
	local integer i = 0
	local integer size = List_GetSize(drivers)
	local integer diff = 0
	local integer mtick = 0
	local integer ltick = 0
	local integer tmpi = INVALID

	loop
		exitwhen i >= size
			set tmpi = List_GetObject(drivers, i)
			set mtick = LoadInteger(gObject, tmpi, ThreadDriver_mMainTick)
			set ltick = LoadInteger(gObject, tmpi, ThreadDriver_mLocalTick)
			set diff = Abs(mtick - ltick)
			if LoadBoolean(gObject, tmpi, ThreadDriver_mRunning) == true then
				if diff > THREAD_MAX_DIFF then
					call SaveBoolean(gObject, tmpi, ThreadDriver_mRunning, false)
					call DebugLog(LOG_ERROR, I2S(tmpi) + " thread driver stalled! Missing Thread_UpdateTick?")
				else
					call SaveInteger(gObject, tmpi, ThreadDriver_mMainTick, mtick + 1)
				endif
			endif
		set i = i + 1
	endloop
endfunction

// PUBLIC: Call this each GAME_DELTA update, when running a thread driver to signal there is no
// stall.
function Thread_UpdateTick takes integer driver returns nothing
	// todo: If stuff gets to crazy.. we can use Thread_SyncTick.. to make mLocalTick=mMainTick
	call SaveInteger(gObject, driver, ThreadDriver_mLocalTick, LoadInteger(gObject, driver, ThreadDriver_mLocalTick) + 1)
endfunction

// PUBLIC: Should be called from game update.. It is a sleepy update so it should have its own thread.
function Thread_Update takes integer driver returns nothing
	local integer drivers = INVALID 
	
	if IsNull(gThread) then
		call AccessViolation("Thread_Update")
		return
	endif

	set drivers = LoadInteger(gObject, gThread, Thread_mDrivers)
	loop
		call Thread_UpdateTick(driver)
		call p_Thread_Update(drivers)
		call Sleep(GAME_DELTA)
	endloop
endfunction

function Thread_GetDriver takes string name returns integer
	return Object_FindByString(TYPE_ID_THREAD_DRIVER, p_Object_Name, name)
endfunction

// PUBLIC: Should be called during game initialization to register various updater functions.
function Thread_RegisterDriver takes string name, code func returns nothing
    local integer drivers = INVALID
	local trigger trig = null
	local integer driver = INVALID

	if IsNull(gThread) then
		call AccessViolation("Thread_RegisterDriver")
		return
	endif

	set driver = Object_Allocate(TYPE_ID_THREAD_DRIVER, 4)
	if IsNull(driver) then
		call DebugLog(LOG_ERROR, "Thread_RegisterDriver failed: Name=" + name)
		return
	endif
	if CONFIG_THREAD_ENABLE_LOGGING then
		call DebugLog(LOG_INFO, "Create driver [" + I2S(driver) + "]: " + name)
	endif

	set drivers = LoadInteger(gObject, gThread, Thread_mDrivers)
	set trig = CreateTrigger()
	call TriggerAddAction(trig, func)
	call SaveStr(gObject, driver, p_Object_Name, name)
	call SaveTriggerHandle(gObject, driver, ThreadDriver_mCallback, trig)
	call SaveInteger(gObject, driver, ThreadDriver_mMainTick, 0)
	call SaveInteger(gObject, driver, ThreadDriver_mLocalTick, 0)
	call SaveBoolean(gObject, driver, ThreadDriver_mRunning, false)
	if CONFIG_THREAD_ENABLE_LOGGING then
		call DebugLog(LOG_INFO, "Register Driver: " + Object_GetFormattedName(driver)) 
	endif
	call List_AddObject(drivers, driver)
	set trig = null
endfunction

// PUBLIC: Call to start a thread.. Can be called in game-initialization.
function Thread_StartDriver takes string name returns nothing
	local integer driver = Object_FindByString(TYPE_ID_THREAD_DRIVER, p_Object_Name, name)
	if IsNull(driver) then
		call DebugLog(LOG_ERROR, "Failed to start thread " + name + " because it doesn't exist.")
		return
	endif

	if LoadBoolean(gObject, driver, ThreadDriver_mRunning) == true then
		call DebugLog(LOG_ERROR, "Failed to start thread " + name + " because it is already running.")
		return
	endif

	call SaveInteger(gObject, driver, ThreadDriver_mLocalTick, 0)
	call SaveInteger(gObject, driver, ThreadDriver_mMainTick, 0)
	call SaveBoolean(gObject, driver, ThreadDriver_mRunning, true)
	call TriggerExecute(LoadTriggerHandle(gObject, driver, ThreadDriver_mCallback))
endfunction

function Thread_IsRunning takes integer self returns boolean
	return LoadBoolean(gObject, self, ThreadDriver_mRunning)
endfunction// ______________________________________________
// Scripts/Core/Debug
// ----------------------------------------------
globals
    constant integer DEBUG_TYPE_INTEGER = 0
    constant integer DEBUG_TYPE_REAL = 1
    constant integer DEBUG_TYPE_STRING = 2
    constant integer DEBUG_TYPE_OBJECT = 3

    integer gDebugRestoreMultiboard = INVALID
    string array gDebugWatchVariables
    integer array gDebugWatchAddresses
    integer array gDebugWatchMemberIndices
    integer array gDebugWatchTypes
    integer gDebugWatchCount = 0
endglobals

function Debug_PreInit takes nothing returns nothing
    call DisplayBoard_Create(MULTIBOARD_OBJECT_WATCH, 1, 4, "Debug Watch Window")
endfunction

function Debug_SaveDisplayBoard takes nothing returns nothing
    if DisplayBoard_GetCurrent() != MULTIBOARD_OBJECT_WATCH then
        set gDebugRestoreMultiboard = DisplayBoard_GetCurrent()
    endif
endfunction

function Debug_GetValueString takes integer addr, integer member, integer typeID returns string
    if typeID == DEBUG_TYPE_INTEGER then
        return I2S(LoadInteger(gObject, addr, member))
    elseif typeID == DEBUG_TYPE_REAL then
        return R2S(LoadReal(gObject, addr, member))
    elseif typeID == DEBUG_TYPE_STRING then
        return LoadStr(gObject, addr, member)
    else
        return "{}"
    endif
endfunction

function Debug_GetTypeString takes integer typeID returns string
    if typeID == DEBUG_TYPE_INTEGER then
        return "Integer"
    elseif typeID == DEBUG_TYPE_REAL then
        return "Real"
    elseif typeID == DEBUG_TYPE_STRING then
        return "String"
    else
        return "Object"
    endif
endfunction

function Debug_GetTypeFromString takes string typeID returns integer
    if typeID == "Integer" then
        return DEBUG_TYPE_INTEGER
    elseif typeID == "Real" then
        return DEBUG_TYPE_REAL
    elseif typeID == "String" then
        return DEBUG_TYPE_STRING
    else
        return DEBUG_TYPE_OBJECT
    endif
endfunction

function Debug_UpdateWatchValues takes nothing returns nothing
    local integer i = 0

    loop
        exitwhen i >= gDebugWatchCount
        
        call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 0, i + 1, 15.0, gDebugWatchVariables[i], MULTIBOARD_COLOR_WHITE)
        call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 1, i + 1, 8.0, I2S(gDebugWatchAddresses[i]), MULTIBOARD_COLOR_WHITE)
        call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 2, i + 1, 8.0, Debug_GetValueString(gDebugWatchAddresses[i], gDebugWatchMemberIndices[i], gDebugWatchTypes[i]), MULTIBOARD_COLOR_WHITE)
        call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 3, i + 1, 8.0, Debug_GetTypeString(gDebugWatchTypes[i]), MULTIBOARD_COLOR_WHITE)

        set i = i + 1
    endloop

endfunction

function Debug_Update takes nothing returns nothing
    if DisplayBoard_GetCurrent() == MULTIBOARD_OBJECT_WATCH then
        call DisplayBoard_Hide()
        call DisplayBoard_SetRowCount(MULTIBOARD_OBJECT_WATCH, 1 + gDebugWatchCount)
        call Debug_UpdateWatchValues()
        call DisplayBoard_Show(MULTIBOARD_OBJECT_WATCH, true)
    endif
endfunction

function Debug_ShowWatch takes nothing returns nothing
    if DisplayBoard_GetCurrent() == MULTIBOARD_OBJECT_WATCH then
        return
    endif
    call Debug_SaveDisplayBoard()
    call DisplayBoard_Hide()

    call DisplayBoard_SetRowCount(MULTIBOARD_OBJECT_WATCH, 1 + gDebugWatchCount)
    call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 0, 0, 15.0, "Variable", MULTIBOARD_COLOR_TITLE_YELLOW)
    call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 1, 0, 8.0, "Address", MULTIBOARD_COLOR_TITLE_YELLOW)
    call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 2, 0, 8.0, "Value", MULTIBOARD_COLOR_TITLE_YELLOW)
    call DisplayBoard_SetTextItem(MULTIBOARD_OBJECT_WATCH, 3, 0, 8.0, "Type", MULTIBOARD_COLOR_TITLE_YELLOW)

    call Debug_UpdateWatchValues()

    call DisplayBoard_Show(MULTIBOARD_OBJECT_WATCH, true)
endfunction

function Debug_HideWatch takes nothing returns nothing
    if gDebugRestoreMultiboard != INVALID then
        call DisplayBoard_Show(gDebugRestoreMultiboard, true)
    else
        call DisplayBoard_Hide()
    endif
endfunction

function Debug_AddWatch takes string variableName, integer address, integer memberIndex, string typeIDStr returns nothing
    local integer typeID = Debug_GetTypeFromString(typeIDStr)
    local integer i = gDebugWatchCount
    
    set gDebugWatchVariables[i] = variableName
    set gDebugWatchAddresses[i] = address
    set gDebugWatchMemberIndices[i] = memberIndex
    set gDebugWatchTypes[i] = typeID
    set gDebugWatchCount = gDebugWatchCount + 1
endfunction

function Debug_RemoveWatchAt takes integer i returns nothing
    if i >= gDebugWatchCount then
        return
    endif

    loop
        exitwhen i >= gDebugWatchCount

        set gDebugWatchVariables[i] = gDebugWatchVariables[i + 1]
        set gDebugWatchAddresses[i] = gDebugWatchAddresses[i + 1]
        set gDebugWatchMemberIndices[i] = gDebugWatchMemberIndices[i + 1]
        set gDebugWatchTypes[i] = gDebugWatchTypes[i+ 1]
        set i = i + 1
    endloop

    set gDebugWatchCount = gDebugWatchCount - 1
endfunction

function Debug_RemoveWatch takes string variableName returns nothing
    local integer i = 0
    loop
        exitwhen i >= gDebugWatchCount
        if gDebugWatchVariables[i] == variableName then
            call Debug_RemoveWatchAt(i)
            return
        endif
        set i = i + 1
    endloop
endfunction// ______________________________________________
// Scripts/Core/Cmd
// ----------------------------------------------
// Command Concept:

// OnText
// Get first word
// Check for "-command" in list of commands
// If valid command:
// Parse all tokens:
// 





// struct CmdHandler
// {
//      string  mCommand
//      trigger mCallback
// }

globals
    constant integer CmdHandler_mCommand = 0
    constant integer CmdHandler_mCallback = 1
endglobals

function CmdHandler_Create takes string cmd, trigger callback returns integer
    local integer self = Object_Allocate(TYPE_ID_CMD_HANDLER, 2)
    if IsNull(self) then
        return self
    endif
    call SaveStr(gObject, self, CmdHandler_mCommand, cmd)
    call SaveTriggerHandle(gObject, self, CmdHandler_mCallback, callback)
    return self
endfunction

// struct Cmd
// {
//      list<CmdHandler>
// }
globals
    integer gCmd = INVALID
    constant integer Cmd_mCommands = 0
    constant integer Cmd_mTrigger = 1
    constant integer Cmd_mEventPlayer = 2
    constant integer Cmd_mEventArgs = 3
endglobals



function Cmd_RegisterHandler takes string cmd, code callback returns nothing
    local trigger trig = null
    if IsNull(gCmd) then
        call AccessViolation("Cmd_RegisterHandler")
        return
    endif
    set trig = CreateTrigger()
    call TriggerAddAction(trig, callback)
    call List_AddObject(LoadInteger(gObject, gCmd, Cmd_mCommands), CmdHandler_Create(cmd, trig))
    set trig = null
endfunction

function Cmd_GetEventPlayer takes nothing returns player
    if IsNull(gCmd) then
        call AccessViolation("Cmd_GetEventPlayer")
        return null
    endif
    return LoadPlayerHandle(gObject, gCmd, Cmd_mEventPlayer)
endfunction

function Cmd_GetEventArgs takes nothing returns integer
    if IsNull(gCmd) then
        call AccessViolation("Cmd_GetEventArgs")
        return INVALID
    endif
    return LoadInteger(gObject, gCmd, Cmd_mEventArgs)
endfunction

function Cmd_FindHandler takes string cmd returns integer
    local integer i = 0
    local integer mCommands = 0
    local integer size = 0
    local integer current = 0

    if IsNull(gCmd) then
        return INVALID
    endif

    set mCommands = LoadInteger(gObject, gCmd, Cmd_mCommands)
    set size = List_GetSize(mCommands)
    loop
        exitwhen i >= size
        set current = List_GetObject(mCommands, i)
        if LoadStr(gObject, current, CmdHandler_mCommand) == cmd then
            return current
        endif
        set i = i + 1
    endloop

    return INVALID
endfunction

function Cmd_GetCmdString takes string msg returns string
    local integer start = 0
    local integer end = 0
    local integer i = 0
    local integer size = StringLength(msg)

    // read until non-whitespace
    loop
        exitwhen i >= size
        if GetChar(msg, i) != " " then
            set start = i
            exitwhen true
        endif
        set i = i + 1
    endloop

    // read until end or whitespace
    loop 
        exitwhen i >= size
        if GetChar(msg, i) == " " then
            set end = i
            exitwhen true
        elseif i == (size-1) then
            set end = i + 1
            exitwhen true
        endif
        set i = i + 1
    endloop

    return SubString(msg, start, end)
endfunction

function Cmd_SplitCmdString takes string msg returns integer
    local integer MAX_ARGS = 9
    local integer size = StringLength(msg)
    local integer list = List_Create(TYPE_ID_STRING)
    local integer start = INVALID
    local integer end = INVALID
    local integer i = 0
    loop
        exitwhen i >= size
        // read until non-whitespace
        loop
            exitwhen i >= size
            if GetChar(msg, i) != " " then
                set start = i
                exitwhen true
            endif
            set i = i + 1
        endloop

        // read until end or whitespace
        loop 
            exitwhen i >= size
            if GetChar(msg, i) == " " then
                set end = i
                exitwhen true
            elseif i == (size-1) then
                set end = i + 1
                exitwhen true
            endif
            set i = i + 1
        endloop

        // pop_word
        call List_AddString(list, SubString(msg, start, end))
        
        exitwhen i >= (size-1)
        exitwhen List_GetSize(list) >= MAX_ARGS
    endloop
    return list
endfunction

function Cmd_ProcessUserString takes nothing returns nothing
    local string msg = GetEventPlayerChatString()
    local string lowerMsg = StringCase(msg, false)
    local string cmd = Cmd_GetCmdString(lowerMsg)
    local integer handler = Cmd_FindHandler(cmd)
    local integer words = 0
    if IsNull(handler) then
        return
    endif
    set words = Cmd_SplitCmdString(msg)
    call SavePlayerHandle(gObject, gCmd, Cmd_mEventPlayer, GetTriggerPlayer())
    call SaveInteger(gObject, gCmd, Cmd_mEventArgs, words)
    call TriggerExecute(LoadTriggerHandle(gObject, handler, CmdHandler_mCallback))
    call SavePlayerHandle(gObject, gCmd, Cmd_mEventPlayer, null)
    call SaveInteger(gObject, gCmd, Cmd_mEventArgs, INVALID)
    call List_Destroy(words)
endfunction

function Cmd_Create takes nothing returns nothing
    local trigger chatEventTrigger = null
    if not IsNull(gCmd) then
        call DebugLog(LOG_ERROR, "Cmd_Create failed, gCmd already exists.")
        return
    endif
    set gCmd = Object_Allocate(TYPE_ID_CMD, 4)
    call SaveInteger(gObject, gCmd, Cmd_mCommands, List_Create(TYPE_ID_CMD_HANDLER))
    call Assert(not IsNull(LoadInteger(gObject, gCmd, Cmd_mCommands)), "not IsNull(LoadInteger(gObject, gCmd, Cmd_mCommands))")
    set chatEventTrigger = CreateTrigger()
    call TriggerRegisterPlayerChatEvent(chatEventTrigger, Player(0), "-", false)
    call TriggerRegisterPlayerChatEvent(chatEventTrigger, Player(1), "-", false)
    call TriggerRegisterPlayerChatEvent(chatEventTrigger, Player(2), "-", false)
    call TriggerRegisterPlayerChatEvent(chatEventTrigger, Player(3), "-", false)
    call TriggerRegisterPlayerChatEvent(chatEventTrigger, Player(4), "-", false)
    call TriggerRegisterPlayerChatEvent(chatEventTrigger, Player(5), "-", false)
    call TriggerRegisterPlayerChatEvent(chatEventTrigger, Player(6), "-", false)
    call TriggerRegisterPlayerChatEvent(chatEventTrigger, Player(7), "-", false)

    call TriggerAddAction(chatEventTrigger, function Cmd_ProcessUserString)
    call SaveTriggerHandle(gObject, gCmd, Cmd_mTrigger, chatEventTrigger)
    set chatEventTrigger = null
    call SavePlayerHandle(gObject, gCmd, Cmd_mEventPlayer, null)
    call SaveInteger(gObject, gCmd, Cmd_mEventArgs, INVALID)
endfunction

function Cmd_PreInit takes nothing returns nothing
    call Cmd_Create()
endfunction

function CmdMatch takes string arg, integer index, integer eventArgs returns boolean
    if IsNull(eventArgs) then
        return false
    endif
    if index >= List_GetSize(eventArgs) then
        return false
    endif
    return List_GetString(eventArgs, index) == arg
endfunction

function Cmd_GetString takes integer eventArgs, integer index returns string
    if index >= List_GetSize(eventArgs) then
        return ""
    endif
    return List_GetString(eventArgs, index)
endfunction

function Cmd_Test takes nothing returns nothing
    call DebugLog(LOG_INFO, "Cmd_Test...")
    
    call Assert(Cmd_GetCmdString("-object") == "-object", "Cmd_GetCmdString(-object) == -object")
    call Assert(Cmd_GetCmdString("-object stat") == "-object", "Cmd_GetCmdString(-object stat) == -object")
    call Assert(Cmd_GetCmdString("-object stat type_count") == "-object", "Cmd_GetCmdString(-object stat type_count) == -object")
    call Assert(Cmd_GetCmdString("-object stat instance_count TYPE_ID_INT") == "-object", "Cmd_GetCmdString(-object stat instance_count TYPE_ID_INT) == -object")
    call Assert(Cmd_GetCmdString("-object stat instance_report TYPE_ID_ITEM") == "-object", "Cmd_GetCmdString(-object stat instance_report TYPE_ID_ITEM) == -object")

    
    call DebugLog(LOG_INFO, "Cmd_Test finished.")
endfunction// ______________________________________________
// Scripts/Game/UnitTypeData_h
// ----------------------------------------------
// DECLARE_TYPE(UnitTypeData, 1000, 1000)
// @persistent
globals
    constant integer UnitTypeData_mName = 0
    constant integer UnitTypeData_mTypeId = 1
    constant integer UnitTypeData_mInitCallback = 2

    constant integer UnitTypeData_MAX_MEMBER = 3

    integer UnitTypeData_gArg_Init_typeData = INVALID
    integer UnitTypeData_gArg_Init_unitData = INVALID
endglobals

function UnitTypeData_Create takes string name, integer id returns integer
    local integer self = Object_Allocate(TYPE_ID_UNIT_TYPE_DATA, UnitTypeData_MAX_MEMBER)
    if IsNull(self) then
        return self
    endif
    call SaveStr(gObject, self, p_Object_Name, name)
    call SaveStr(gObject, self, UnitTypeData_mName, name)
    call SaveInteger(gObject, self, UnitTypeData_mTypeId, id)
    call SaveTriggerHandle(gObject, self, UnitTypeData_mInitCallback, null)
    return self
endfunction

function UnitTypeData_IsHero takes integer self returns boolean
    if not SelfCheck(self, TYPE_ID_UNIT_TYPE_DATA, "UnitTypeData_IsHero") then
        return false
    endif
    return IsUnitIdType(LoadInteger(gObject, self, UnitTypeData_mTypeId), UNIT_TYPE_HERO)
endfunction// ______________________________________________
// Scripts/Game/GameState_h
// ----------------------------------------------
globals
    constant integer GS_LOADING = 0
    constant integer GS_HERO_PICK = 1
    constant integer GS_PLAYING = 2
    constant integer GS_FAILED = 3
    constant integer GS_SUCCESS = 4
    constant integer GS_NONE = 5

    integer gGameState = GS_NONE
    integer gNextGameState = GS_LOADING
endglobals// ______________________________________________
// Scripts/Game/PlayerData_h
// ----------------------------------------------
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

    call Debug_AddWatch("PlayerData::Hero", self, PlayerData_mHero, "Integer")

    return self
endfunction


// ______________________________________________
// Scripts/Game/Component_h
// ----------------------------------------------
// DECLARE_TYPE(Component,1000,1000)
globals
    constant integer Component_mDestructor = 0
    constant integer Component_mParent = 1
    constant integer Component_mUpdate = 2

    constant integer Component_MAX_MEMBER = 3

    integer Component_gDestructorArg_Self = INVALID
    integer Component_gUpdateArg_Self = INVALID
endglobals

function Component_Derive takes integer self, code destructor, code update returns nothing
    local trigger mDestructor = CreateTrigger()
    local trigger mUpdate = null

    call TriggerAddAction(mDestructor, destructor)
    if update != null then
        set mUpdate = CreateTrigger()
        call TriggerAddAction(mUpdate, update)
    endif

    call SaveTriggerHandle(gObject, self, Component_mDestructor, mDestructor)
    call SaveTriggerHandle(gObject, self, Component_mUpdate, mUpdate)
    call SaveInteger(gObject, self, Component_mParent, INVALID)
endfunction

function Component_Destroy takes integer self returns nothing
    local trigger mDestructor = LoadTriggerHandle(gObject, self, Component_mDestructor)

    call RemoveSavedHandle(gObject, self, Component_mDestructor)
    call RemoveSavedInteger(gObject, self, Component_mParent)
    call RemoveSavedHandle(gObject, self, Component_mUpdate)

    set Component_gDestructorArg_Self = self
    call TriggerExecute(mDestructor)
    set mDestructor = null
endfunction

function Component_Update takes integer self returns nothing
    local trigger mUpdate = LoadTriggerHandle(gObject, self, Component_mUpdate)
    set Component_gUpdateArg_Self = self
    call TriggerExecute(mUpdate)
    set mUpdate = null
endfunction

// ______________________________________________
// Scripts/Game/UnitData_h
// ----------------------------------------------
// DECLARE_TYPE(UnitData,500,500)
globals
    constant integer UnitData_mHandle = 0
    constant integer UnitData_mTypeData = 1
    constant integer UnitData_mPlayerData = 2
    constant integer UnitData_mComponents = 3
    constant integer UnitData_mQueueDestroy = 4

    constant integer UnitData_MAX_MEMBER = 5
endglobals

function UnitData_Create takes nothing returns integer
    local integer self = Object_Allocate(TYPE_ID_UNIT_DATA, UnitData_MAX_MEMBER)
    if IsNull(self) then
        return self
    endif

    call SaveUnitHandle(gObject, self, UnitData_mHandle, null)
    call SaveInteger(gObject, self, UnitData_mTypeData, INVALID)
    call SaveInteger(gObject, self, UnitData_mPlayerData, INVALID)
    call SaveInteger(gObject, self, UnitData_mComponents, List_Create(TYPE_ID_COMPONENT))
    call SaveBoolean(gObject, self, UnitData_mQueueDestroy, false)
    return self
endfunction

function UnitData_QueueDestroy takes integer self returns nothing
    call SaveBoolean(gObject, self, UnitData_mQueueDestroy, true)
endfunction

function UnitData_Destroy takes integer self returns nothing
    local unit mHandle = null
    local integer mComponents = INVALID
    local integer mComponents_mSize = 0
    local integer i = 0
    if IsNull(self) then
        return 
    endif

    set mHandle = LoadUnitHandle(gObject, self, UnitData_mHandle)
    if mHandle != null then
        call RemoveUnit(mHandle)
    endif
    set mHandle = null

    set mComponents = LoadInteger(gObject, self, UnitData_mComponents)
    set mComponents_mSize = List_GetSize(mComponents)
    loop
        exitwhen i >= mComponents_mSize
        call Component_Destroy(List_GetObject(mComponents, i))
        set i = i + 1
    endloop
    call List_Clear(mComponents)
    call List_Destroy(mComponents)

    call RemoveSavedHandle(gObject, self, UnitData_mHandle)
    call RemoveSavedInteger(gObject, self, UnitData_mTypeData)
    call RemoveSavedInteger(gObject, self, UnitData_mPlayerData)
    call RemoveSavedInteger(gObject, self, UnitData_mComponents)
    call RemoveSavedBoolean(gObject, self, UnitData_mQueueDestroy)
    call Object_Free(self)
endfunction// ______________________________________________
// Scripts/Game/SpawnWaveData_h
// ----------------------------------------------
// DECLARE_TYPE(SpawnWaveData,100,100)
globals
    constant integer SpawnWaveData_mSpawnCount = 0
    constant integer SpawnWaveData_mSpawnDelay = 1
    constant integer SpawnWaveData_mUnitType = 2
    constant integer SpawnWaveData_mIsBoss = 3

    constant integer SpawnWaveData_MAX_MEMBER = 4
endglobals

function SpawnWaveData_Create takes nothing returns integer
    local integer self = Object_Allocate(TYPE_ID_SPAWN_WAVE_DATA, SpawnWaveData_MAX_MEMBER)
    if IsNull(self) then
        return self
    endif

    call SaveInteger(gObject, self, SpawnWaveData_mSpawnCount, 0)
    call SaveReal(gObject, self, SpawnWaveData_mSpawnDelay, 1.75)
    call SaveInteger(gObject, self, SpawnWaveData_mUnitType, INVALID)
    call SaveBoolean(gObject, self, SpawnWaveData_mIsBoss, false)
    return self
endfunction// ______________________________________________
// Scripts/Game/PlayerMgr_h
// ----------------------------------------------
// @singleton
globals
    integer array PlayerMgr_gPlayers
    integer PlayerMgr_gMaxPlayer = 0
    integer PlayerMgr_gEnemyForcePlayer = INVALID
    integer PlayerMgr_gAllyForcePlayer = INVALID
endglobals

// ______________________________________________
// Scripts/Game/UnitMgr_h
// ----------------------------------------------
globals
    integer UnitMgr_gTypes = INVALID
    integer UnitMgr_gTypes_mSize
    string array UnitMgr_gIndexNames
    integer array UnitMgr_gIndexIds
endglobals// ______________________________________________
// Scripts/Game/GameDirector_h
// ----------------------------------------------
globals
    integer array GameDirector_gSpawnWaveData
    integer       GameDirector_gSpawnWaveData_mSize = 0

    real array    GameDirector_gSpawnX
    real array    GameDirector_gSpawnY
    integer       GameDirector_gSpawnPointCount = 0
    real          GameDirector_gTargetX = 0.0
    real          GameDirector_gTargetY = 0.0

    integer GameDirector_gCurrentSpawnCount = 0
    real    GameDirector_gCurrentSpawnDelay = 0.0
    integer GameDirector_gCurrentUnitType = INVALID
    boolean GameDirector_gCurrentBossWave = false
    integer GameDirector_gCurrentSpawnWave = 0

    timerdialog GameDirector_gWaveTimerDialog = null
    timer       GameDirector_gWaveTimer = null
    timer       GameDirector_gSpawnTimer = null

    integer array GameDirector_gWaveUnits
    integer       GameDirector_gWaveUnits_mSize = 0
    integer       GameDirector_gMaxUnit = 150

    boolean GameDirector_gRunning = false
endglobals// ______________________________________________
// Scripts/Game/UnitTypeData_c
// ----------------------------------------------
function UnitTypeData_GetName takes integer self returns string
    if not SelfCheck(self, TYPE_ID_UNIT_TYPE_DATA, "UnitTypeData_GetName") then
        return ""
    endif
    return LoadStr(gObject, self, UnitTypeData_mName)
endfunction

function UnitTypeData_GetId takes integer self returns integer
    if not SelfCheck(self, TYPE_ID_UNIT_TYPE_DATA, "UnitTypeData_GetId") then
        return 0
    endif
    return LoadInteger(gObject, self, UnitTypeData_mTypeId)
endfunction

function UnitTypeData_GetInitCallback takes integer self returns trigger
    if not SelfCheck(self, TYPE_ID_UNIT_TYPE_DATA, "UnitTypeData_GetInitCallback") then
        return null
    endif
    return LoadTriggerHandle(gObject, self, UnitTypeData_mInitCallback)
endfunction

function UnitTypeData_Init takes integer self, integer unitData returns nothing
    local trigger mInitCallback = null
    if not SelfCheck(self, TYPE_ID_UNIT_TYPE_DATA, "UnitTypeData_Init") then
        return
    endif 
    set UnitTypeData_gArg_Init_typeData = self
    set UnitTypeData_gArg_Init_unitData = unitData
    set mInitCallback = LoadTriggerHandle(gObject, self, UnitTypeData_mInitCallback)
    if mInitCallback != null then
        call TriggerExecute(mInitCallback)
        set mInitCallback = null
    endif
endfunction// ______________________________________________
// Scripts/Game/PlayerData_c
// ----------------------------------------------
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
endfunction// ______________________________________________
// Scripts/Game/UnitData_c
// ----------------------------------------------
function GetUnitId takes unit unitHandle returns integer
    return GetUnitUserData(unitHandle) - 1
endfunction

function SetUnitId takes unit unitHandle, integer id returns nothing
    call SetUnitUserData(unitHandle, id + 1)
endfunction

function UnitData_GetComponents takes integer self returns integer
    if not SelfCheck(self, TYPE_ID_UNIT_DATA, "UnitData_GetComponents") then
        return INVALID
    endif
    return LoadInteger(gObject, self, UnitData_mComponents)
endfunction

function UnitData_GetComponent takes integer self, integer typeId returns integer
    local integer i = 0
    local integer mComponents = INVALID
    local integer mComponents_mSize = 0
    local integer current = INVALID

    if not SelfCheck(self, TYPE_ID_UNIT_DATA, "UnitData_GetComponent") then
        return INVALID
    endif

    set mComponents = LoadInteger(gObject, self, UnitData_mComponents)
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

function UnitData_AddComponent takes integer self, integer component returns boolean
    local integer mComponents = INVALID
    if not SelfCheck(self, TYPE_ID_UNIT_DATA, "UnitData_AddComponent") then
        return false
    endif

    if IsNull(component) then
        call DebugLog(LOG_ERROR, "UnitData_c: UnitData_AddComponent failed, missing component instance.")
        return false
    endif

    if not IsNull(UnitData_GetComponent(self, Object_GetTypeId(component))) then
        call DebugLog(LOG_ERROR, "UnitData_c: UnitData_AddComponent failed, component of that type already exists. Type=" + Object_GetTypeName(Object_GetTypeId(component)))
        return false
    endif

    set mComponents = LoadInteger(gObject, self, UnitData_mComponents)
    call List_AddObject(mComponents, component)
    call SaveInteger(gObject, component, Component_mParent, self)
    return true
endfunction

function UnitData_Update takes integer self returns nothing
    local integer i = 0
    local integer mComponents = INVALID
    local integer mComponents_mSize = 0
    local integer current = INVALID

    if not SelfCheck(self, TYPE_ID_UNIT_DATA, "UnitData_Update") then
        return
    endif

    set mComponents = LoadInteger(gObject, self, UnitData_mComponents)
    set mComponents_mSize = List_GetSize(mComponents)
    loop
        exitwhen i >= mComponents_mSize
        set current = List_GetObject(mComponents, i)
        call Component_Update(current)
        set i = i + 1
    endloop
endfunction// ______________________________________________
// Scripts/Game/UnitMgr_c
// ----------------------------------------------
function UnitMgr_RegisterUnitType takes integer typeId, string id returns integer
    local integer unitTypeData = UnitTypeData_Create(id, typeId)
    local integer idx = List_GetSize(UnitMgr_gTypes)
    set UnitMgr_gIndexNames[idx] = id
    set UnitMgr_gIndexIds[idx] = typeId
    call List_AddObject(UnitMgr_gTypes, unitTypeData)
    return unitTypeData
endfunction

function UnitMgr_FindUnitTypeByString takes string id returns integer
    local integer i = 0
    loop
        exitwhen i >= UnitMgr_gTypes_mSize
        if UnitMgr_gIndexNames[i] == id then
            return List_GetObject(UnitMgr_gTypes, i)
        endif
        set i = i + 1
    endloop
    return INVALID
endfunction

function UnitMgr_FindUnitTypeById takes integer id returns integer
    local integer i = 0
    loop
        exitwhen i >= UnitMgr_gTypes_mSize
        if UnitMgr_gIndexIds[i] == id then
            return List_GetObject(UnitMgr_gTypes, i)
        endif
        set i = i + 1
    endloop
    return INVALID
endfunction

function UnitMgr_CreateUnit takes integer typeData, integer playerOwner, real x, real y returns integer
    local integer unitTypeId = LoadInteger(gObject, typeData, UnitTypeData_mTypeId)
    local integer unitData = INVALID
    local unit unitHandle = null
    
    if IsNull(typeData) or IsNull(playerOwner) then
        return INVALID
    endif

    set unitData = UnitData_Create()
    if IsNull(unitData) then
        return INVALID
    endif

    set unitHandle = CreateUnit(Player(LoadInteger(gObject, playerOwner, PlayerData_mPlayerId)), unitTypeId, x, y, 0)
    if unitHandle == null then
        call UnitData_Destroy(unitData)
        return INVALID
    endif

    // Link Unit
    call SaveUnitHandle(gObject, unitData, UnitData_mHandle, unitHandle)
    call SaveInteger(gObject, unitData, UnitData_mTypeData, typeData)
    call SaveInteger(gObject, unitData, UnitData_mPlayerData, playerOwner)
    call SetUnitId(unitHandle, unitData)
    set unitHandle = null

    // Link Player
    call List_AddObject(LoadInteger(gObject, playerOwner, PlayerData_mControlledUnits), unitData)

    // Call Custom Init Func
    call UnitTypeData_Init(typeData, unitData)
    return unitData
endfunction

function UnitMgr_DestroyUnit takes integer unitData returns nothing
    local integer mPlayerData = INVALID
    local integer mControlledUnits = INVALID
    local integer unitIdx = -1
    if IsNull(unitData) then
        return
    endif
    
    // Disconnect Player Link
    set mPlayerData = LoadInteger(gObject, unitData, UnitData_mPlayerData)
    if not IsNull(mPlayerData) then
        set mControlledUnits = LoadInteger(gObject, mPlayerData, PlayerData_mControlledUnits)
        set unitIdx = List_FindObject(mControlledUnits, unitData)
        if unitIdx >= 0 then
            call List_RemoveObject(mControlledUnits, unitIdx)
        endif
    endif
    
    // Destroy Unit Data (and unit handle)
    call UnitData_Destroy(unitData)
endfunction
// ______________________________________________
// Scripts/Game/PlayerMgr_c
// ----------------------------------------------

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
    call SetPlayerState(Player(playerId), PLAYER_STATE_GIVES_BOUNTY, 1)
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
endfunction// ______________________________________________
// Scripts/Components/RunToCityComponent
// ----------------------------------------------
// DECLARE_TYPE(RunToCityComponent,1000,1000)
globals
    // Component_MAX_MEMBER
    constant integer RunToCityComponent_mPrevX = Component_MAX_MEMBER + 0
    constant integer RunToCityComponent_mPrevY = Component_MAX_MEMBER + 1
    constant integer RunToCityComponent_mTimer = Component_MAX_MEMBER + 2

    constant integer RunToCityComponent_MAX_MEMBER = Component_MAX_MEMBER + 3

    code RunToCityComponent_gDestroyFunc = null
    code RunToCityComponent_gUpdateFunc = null
endglobals


function RunToCityComponent_Create takes nothing returns integer
    local integer self = Object_Allocate(TYPE_ID_RUN_TO_CITY_COMPONENT, RunToCityComponent_MAX_MEMBER)
    if IsNull(self) then
        return self
    endif

    call Component_Derive(self, RunToCityComponent_gDestroyFunc, RunToCityComponent_gUpdateFunc)
    call SaveReal(gObject, self, RunToCityComponent_mPrevX, 0.0)
    call SaveReal(gObject, self, RunToCityComponent_mPrevY, 0.0)
    call SaveTimerHandle(gObject, self, RunToCityComponent_mTimer, CreateTimer())
    return self
endfunction

function RunToCityComponent_Destroy takes nothing returns nothing
    local integer self = Component_gDestructorArg_Self
    call DebugLog(LOG_INFO, "RunToCityComponent: Destroy " + I2S(self))

    call RemoveSavedReal(gObject, self, RunToCityComponent_mPrevX)
    call RemoveSavedReal(gObject, self, RunToCityComponent_mPrevY)
    call RemoveSavedHandle(gObject, self, RunToCityComponent_mTimer)
    call Object_Free(self)
endfunction

function RunToCityComponent_Update takes nothing returns nothing
    local integer self = Component_gUpdateArg_Self
    local real mPrevX = LoadReal(gObject, self, RunToCityComponent_mPrevX)
    local real mPrevY = LoadReal(gObject, self, RunToCityComponent_mPrevY)
    local integer mUnitData = LoadInteger(gObject, self, Component_mParent)
    local unit mUnit = LoadUnitHandle(gObject, mUnitData, UnitData_mHandle)
    local timer mTimer = LoadTimerHandle(gObject, self, RunToCityComponent_mTimer)

    // call DebugLog(LOG_INFO, "RunToCityComponent: Updating...")

    if TimerGetRemaining(mTimer) <= 0.0 and IsUnitInRangeXY(mUnit, mPrevX, mPrevY, 50.0) then
        call IssuePointOrder(mUnit, "attack", GameDirector_gTargetX, GameDirector_gTargetY)
        call TimerStart(mTimer, 3.0, false, null)
    endif

    call SaveReal(gObject, self, RunToCityComponent_mPrevX, GetUnitX(mUnit))
    call SaveReal(gObject, self, RunToCityComponent_mPrevY, GetUnitY(mUnit))

    set mUnit = null
    set mTimer = null
endfunction

// ______________________________________________
// Scripts/Components/PlayerHeroComponent
// ----------------------------------------------

// When the player dies start a timer and revive them.
//
// DECLARE_TYPE(PlayerHeroComponent,1000,1000)
globals
    constant integer PlayerHeroComponent_mTimer = Component_MAX_MEMBER + 0
    constant integer PlayerHeroComponent_mTimerDialog = Component_MAX_MEMBER + 1

    constant integer PlayerHeroComponent_MAX_MEMBER = Component_MAX_MEMBER + 2

    code PlayerHeroComponent_gDestroyFunc = null
    code PlayerHeroComponent_gUpdateFunc = null
endglobals

function PlayerHeroComponent_Create takes nothing returns integer
    local integer self = Object_Allocate(TYPE_ID_PLAYER_HERO_COMPONENT, PlayerHeroComponent_MAX_MEMBER)
    if IsNull(self) then
        return self
    endif

    call Component_Derive(self, PlayerHeroComponent_gDestroyFunc, PlayerHeroComponent_gUpdateFunc)
    call SaveTimerHandle(gObject, self, PlayerHeroComponent_mTimer, null)
    call SaveTimerDialogHandle(gObject, self, PlayerHeroComponent_mTimerDialog, null)

    return self
endfunction

function PlayerHeroComponent_Destroy takes nothing returns nothing
    local integer self = Component_gDestructorArg_Self
    local timer mTimer = LoadTimerHandle(gObject, self, PlayerHeroComponent_mTimer)
    local timerdialog mTimerDialog = LoadTimerDialogHandle(gObject, self, PlayerHeroComponent_mTimerDialog)

    if mTimer != null then
        call DestroyTimer(mTimer)
        set mTimer = null
    endif

    if mTimerDialog != null then
        call DestroyTimerDialog(mTimerDialog)
        set mTimer = null
    endif

    call RemoveSavedHandle(gObject, self, PlayerHeroComponent_mTimer)
    call RemoveSavedHandle(gObject, self, PlayerHeroComponent_mTimerDialog)
    call Object_Free(self)
endfunction

function PlayerHeroComponent_GetRespawnTime takes integer self returns real
    return 5.0
endfunction

function PlayerHeroComponent_Update takes nothing returns nothing
    local integer self = Component_gUpdateArg_Self
    local integer mUnitData = LoadInteger(gObject, self, Component_mParent)
    local unit mUnit = LoadUnitHandle(gObject, mUnitData, UnitData_mHandle)
    local timer mTimer = null
    local timerdialog mTimerDialog = null

    if IsUnitDeadBJ(mUnit) then
        set mTimer = LoadTimerHandle(gObject, self, PlayerHeroComponent_mTimer)
        if mTimer == null then
            call DebugLog(LOG_INFO, "Detected hero unit death")
            set mTimer = CreateTimer()
            call TimerStart(mTimer, PlayerHeroComponent_GetRespawnTime(self), false, null)
            call SaveTimerHandle(gObject, self, PlayerHeroComponent_mTimer, mTimer)
            set mTimerDialog = CreateTimerDialog(mTimer)
            call TimerDialogSetTitle(mTimerDialog, "Hero Respawn:")
            call TimerDialogDisplay(mTimerDialog, true)
            call SaveTimerDialogHandle(gObject, self, PlayerHeroComponent_mTimerDialog, mTimerDialog)
        elseif TimerGetRemaining(mTimer) <= 0.0 then
            set mTimerDialog = LoadTimerDialogHandle(gObject, self, PlayerHeroComponent_mTimerDialog)
            call DestroyTimerDialog(mTimerDialog)
            call SaveTimerDialogHandle(gObject, self, PlayerHeroComponent_mTimerDialog, null)
            call ReviveHero(mUnit, GetRectCenterX(gg_rct_HeroRespawn) , GetRectCenterY(gg_rct_HeroRespawn), true)
            call DestroyTimer(mTimer)
            call SaveTimerHandle(gObject, self, PlayerHeroComponent_mTimer, null)
            call SetCameraPositionForPlayer(GetOwningPlayer(mUnit), GetRectCenterX(gg_rct_HeroRespawn) , GetRectCenterY(gg_rct_HeroRespawn))
        endif
    endif
    
    set mTimer = null
    set mTimerDialog = null
    set mUnit = null
endfunction
// ______________________________________________
// Scripts/Components/MonitorUnitLifeComponent
// ----------------------------------------------
// DECLARE_TYPE(MonitorUnitLifeComponent, 1000, 1000)
globals
    constant integer MonitorUnitLifeComponent_mDeathTimer = Component_MAX_MEMBER + 0
    constant integer MonitorUnitLifeComponent_MAX_MEMBER = Component_MAX_MEMBER + 1

    code MonitorUnitLifeComponent_gDestroyFunc = null
    code MonitorUnitLifeComponent_gUpdateFunc = null
endglobals

function MonitorUnitLifeComponent_Create takes nothing returns integer
    local integer self = Object_Allocate(TYPE_ID_MONITOR_UNIT_LIFE_COMPONENT, MonitorUnitLifeComponent_MAX_MEMBER)
    if IsNull(self) then
        return self
    endif

    call Component_Derive(self, MonitorUnitLifeComponent_gDestroyFunc, MonitorUnitLifeComponent_gUpdateFunc)
    call SaveTimerHandle(gObject, self, MonitorUnitLifeComponent_mDeathTimer, null)
    return self
endfunction

function MonitorUnitLifeComponent_Destroy takes nothing returns nothing
    local integer self = Component_gDestructorArg_Self
    local timer mDeathTimer = LoadTimerHandle(gObject, self, MonitorUnitLifeComponent_mDeathTimer)
    call DestroyTimer(mDeathTimer)
    call RemoveSavedHandle(gObject, self, MonitorUnitLifeComponent_mDeathTimer)
    call Object_Free(self)
    set mDeathTimer = null
endfunction

function MonitorUnitLifeComponent_Update takes nothing returns nothing
    local integer self = Component_gUpdateArg_Self
    local integer mUnitData = LoadInteger(gObject, self, Component_mParent)
    local unit mUnit = LoadUnitHandle(gObject, mUnitData, UnitData_mHandle)
    local timer mDeathTimer = LoadTimerHandle(gObject, self, MonitorUnitLifeComponent_mDeathTimer)

    if IsUnitDeadBJ(mUnit) then
        if mDeathTimer == null then
            set mDeathTimer = CreateTimer()
            call TimerStart(mDeathTimer, 2.0, false, null)
            call SaveTimerHandle(gObject, self, MonitorUnitLifeComponent_mDeathTimer, mDeathTimer)
        elseif TimerGetRemaining(mDeathTimer) <= 0.0 then
            call UnitData_QueueDestroy(mUnitData)
        endif
    endif
    set mUnit = null
    set mDeathTimer = null
endfunction// ______________________________________________
// Scripts/Game/GameDirector_c
// ----------------------------------------------

function GameDirector_EnrageWaveUnit takes nothing returns nothing
    // todo: 
    call DebugLog(LOG_INFO, "GameDirector_c: TODO: EnrageWaveUnit")
endfunction

function GameDirector_SpawnWaveUnit takes integer spawnIndex returns nothing
    local integer playerData = PlayerMgr_gEnemyForcePlayer
    local integer unitTypeData = GameDirector_gCurrentUnitType
    local real x = GameDirector_gSpawnX[spawnIndex]
    local real y = GameDirector_gSpawnY[spawnIndex]
    local integer index = 0
    local integer component = INVALID
    loop
        exitwhen index >= GameDirector_gMaxUnit
        if IsNull(GameDirector_gWaveUnits[index]) then
            set GameDirector_gWaveUnits[index] = UnitMgr_CreateUnit(unitTypeData, playerData, x, y)

            set component = RunToCityComponent_Create()
            if not IsNull(component) then
                call UnitData_AddComponent(GameDirector_gWaveUnits[index], component)
            else
                call DebugLog(LOG_ERROR, "GameDirector_c: Failed to create RunToCityComponent")
            endif

            set component = MonitorUnitLifeComponent_Create()
            if not IsNull(component) then
                call UnitData_AddComponent(GameDirector_gWaveUnits[index], component)
            else
                call DebugLog(LOG_ERROR, "GameDirector_c: Failed to create MonitorUnitLifeComponent")
            endif

            set GameDirector_gWaveUnits_mSize = GameDirector_gWaveUnits_mSize + 1
            return
        endif
        set index = index + 1
    endloop

endfunction

function GameDirector_SpawnWaveUnits takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= GameDirector_gSpawnPointCount
        if GameDirector_gWaveUnits_mSize >= GameDirector_gMaxUnit then
            call GameDirector_EnrageWaveUnit()
        else
            call GameDirector_SpawnWaveUnit(i)
        endif

        set i = i + 1
    endloop
endfunction

function GameDirector_BeginWaveSpawn takes nothing returns nothing
    local integer mSpawnWaveData = GameDirector_gSpawnWaveData[GameDirector_gCurrentSpawnWave]
    set GameDirector_gCurrentSpawnCount = LoadInteger(gObject, mSpawnWaveData, SpawnWaveData_mSpawnCount)
    set GameDirector_gCurrentSpawnDelay = LoadReal(gObject, mSpawnWaveData, SpawnWaveData_mSpawnDelay)
    set GameDirector_gCurrentUnitType = LoadInteger(gObject, mSpawnWaveData, SpawnWaveData_mUnitType)
    set GameDirector_gCurrentBossWave = LoadBoolean(gObject, mSpawnWaveData, SpawnWaveData_mIsBoss)

    if GameDirector_gSpawnTimer == null then
        set GameDirector_gSpawnTimer = CreateTimer()
    endif
    call TimerStart(GameDirector_gSpawnTimer, GameDirector_gCurrentSpawnDelay, false, null)
endfunction

function GameDirector_QueueWave takes nothing returns nothing
    if GameDirector_gWaveTimer == null then
        set GameDirector_gWaveTimer = CreateTimer()
    endif
    if GameDirector_gWaveTimerDialog == null then
        set GameDirector_gWaveTimerDialog = CreateTimerDialog(GameDirector_gWaveTimer)
    endif

    call TimerStart(GameDirector_gWaveTimer, 45.0, false, null)
    call TimerDialogSetTitle(GameDirector_gWaveTimerDialog, "Next Wave:")
    call TimerDialogDisplay(GameDirector_gWaveTimerDialog, true)
endfunction

function GameDirector_SetWaveIndex takes integer index returns nothing
    set GameDirector_gCurrentSpawnWave = MinI(index, GameDirector_gSpawnWaveData_mSize - 1)
endfunction

function GameDirector_GetWaveIndex takes nothing returns integer
    return GameDirector_gCurrentSpawnWave
endfunction

function GameDirector_Start takes nothing returns nothing
    if GameDirector_gWaveUnits_mSize > 0 then
        call DebugLog(LOG_ERROR, "GameDirector_c: GameDirector_Start called too early! Leaking units...")
    endif

    set GameDirector_gRunning = true
    call GameDirector_SetWaveIndex(0)
    call GameDirector_QueueWave()
    call GameDirector_BeginWaveSpawn()
endfunction

function GameDirector_Stop takes nothing returns nothing
    set GameDirector_gRunning = false
endfunction

function GameDirector_Update takes nothing returns nothing
    local integer i = 0
    if not GameDirector_gRunning then
        loop
            exitwhen i >= GameDirector_gMaxUnit
            exitwhen GameDirector_gWaveUnits_mSize == 0

            if not IsNull(GameDirector_gWaveUnits[i]) then
                call UnitMgr_DestroyUnit(GameDirector_gWaveUnits[i])
                set GameDirector_gWaveUnits_mSize = GameDirector_gWaveUnits_mSize - 1
            endif
            set GameDirector_gWaveUnits[i] = INVALID
            set i = i + 1
        endloop

        if GameDirector_gWaveTimerDialog != null then
            call DestroyTimerDialog(GameDirector_gWaveTimerDialog)
            set GameDirector_gWaveTimerDialog = null
        endif

        if GameDirector_gWaveTimer != null then
            call DestroyTimer(GameDirector_gWaveTimer)
            set GameDirector_gWaveTimer = null
        endif

        return
    endif

    if GameDirector_gWaveTimer == null or GameDirector_gSpawnTimer == null then
        call DebugLog(LOG_ERROR, "GameDirector_c: GameDirector_Update failed, missing timer variables.")
        return
    endif

    if TimerGetRemaining(GameDirector_gWaveTimer) <= 0.0 then
        call DebugLog(LOG_INFO, "GameDirector_c: QueueWave")

        call GameDirector_SetWaveIndex(GameDirector_GetWaveIndex() + 1)
        call GameDirector_QueueWave()
        call GameDirector_BeginWaveSpawn()
    endif

    if TimerGetRemaining(GameDirector_gSpawnTimer) <= 0.0 then
        if GameDirector_gCurrentSpawnCount > 0 then
            call DebugLog(LOG_INFO, "GameDirector_c: SpawnWaveUnits")
            call GameDirector_SpawnWaveUnits()
            set GameDirector_gCurrentSpawnCount = GameDirector_gCurrentSpawnCount - 1
            call TimerStart(GameDirector_gSpawnTimer, GameDirector_gCurrentSpawnDelay, false, null)
        endif
    endif
endfunction

function GameDirector_UpdateUnits takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= GameDirector_gMaxUnit
        if not IsNull(GameDirector_gWaveUnits[i]) then
            if LoadBoolean(gObject, GameDirector_gWaveUnits[i], UnitData_mQueueDestroy) then
                call DebugLog(LOG_INFO, "DestroyWaveUnit")
                call UnitMgr_DestroyUnit(GameDirector_gWaveUnits[i])
                set GameDirector_gWaveUnits_mSize = GameDirector_gWaveUnits_mSize - 1
                set GameDirector_gWaveUnits[i] = INVALID
            else
                call UnitData_Update(GameDirector_gWaveUnits[i])
            endif
        endif
        set i = i + 1
    endloop
endfunction// ______________________________________________
// Scripts/Game/GameState_Loading_h
// ----------------------------------------------
// @singleton
globals
    timer       GameState_Loading_gTimer = null
    timerdialog GameState_Loading_gTimerDialog = null
endglobals// ______________________________________________
// Scripts/Game/GameState_Loading_c
// ----------------------------------------------

function GameState_Loading_TransitionOut takes nothing returns nothing
    call DestroyTimerDialog(GameState_Loading_gTimerDialog)
    call DestroyTimer(GameState_Loading_gTimer)
    set GameState_Loading_gTimer = null
    set GameState_Loading_gTimerDialog = null
endfunction

function GameState_Loading_TransitionIn takes nothing returns nothing
    set GameState_Loading_gTimer = CreateTimer()
    call TimerStart(GameState_Loading_gTimer, 2.0, false, null)
    set GameState_Loading_gTimerDialog = CreateTimerDialog(GameState_Loading_gTimer)
    call TimerDialogSetTitle(GameState_Loading_gTimerDialog, "Loading:")
    call TimerDialogDisplay(GameState_Loading_gTimerDialog, true)

    call DebugLog(LOG_INFO, "GameState_Loading_c: Wait 2 seconds for state to end.")
endfunction

function GameState_Loading_Update takes nothing returns nothing
    if TimerGetRemaining(GameState_Loading_gTimer) <= 0.0 then
        set gNextGameState = GS_HERO_PICK
    endif
endfunction// ______________________________________________
// Scripts/Game/GameState_HeroPick_h
// ----------------------------------------------
// Manages the HeroPick state of the game. 
// HeroPick is a state that lasts for a brief amount of time
// - Players are able to select / review units
// - Players are able to buy starting items
// - Players are able to position themself in lanes
globals
    trigger array GameState_HeroPick_gTriggers
    integer       GameState_HeroPick_gCount = 0
    timer         GameState_HeroPick_gTimer = null
    timerdialog   GameState_HeroPick_gTimerDialog = null

    real    GameState_HeroPick_gHeroPickerSpawnX = 0.0
    real    GameState_HeroPick_gHeroPickerSpawnY = 0.0
    real    GameState_HeroPick_gHeroSpawnX = 0.0
    real    GameState_HeroPick_gHeroSpawnY = 0.0
    integer GameState_HeroPick_gHeroPickerType = INVALID
endglobals// ______________________________________________
// Scripts/Game/GameState_HeroPick_c
// ----------------------------------------------
function GameState_HeroPick_RegisterHeroPicker takes rect area, code callback returns nothing
    local trigger mTrigger = CreateTrigger()
    call TriggerRegisterEnterRectSimple(mTrigger, area)
    call TriggerAddAction(mTrigger, callback)

    set GameState_HeroPick_gTriggers[GameState_HeroPick_gCount] = mTrigger
    set GameState_HeroPick_gCount = GameState_HeroPick_gCount + 1
endfunction

function GameState_HeroPick_SelectHero takes string typeName, unit enteringUnit returns nothing
    local integer playerData = INVALID
    local integer unitData = INVALID
    local integer unitTypeData = INVALID
    local integer mHero = INVALID
    local integer mPlayerId = INVALID

    set unitTypeData = UnitMgr_FindUnitTypeByString(typeName)
    if IsNull(unitTypeData) then
        call DebugLog(LOG_ERROR, "GameState_HeroPick_c: Bad Hero pick, typeName=" + typeName)
        return
    endif

    set unitData = GetUnitId(enteringUnit)
    if IsNull(unitData) then
        call DebugLog(LOG_ERROR, "GameState_HeroPick_c: Bad Hero pick, entering unit has no UnitData")
        return
    endif

    set playerData = LoadInteger(gObject, unitData, UnitData_mPlayerData)
    if IsNull(playerData) then
        call DebugLog(LOG_ERROR, "GameState_HeroPick_c: Bad Hero pick, UnitData has no PlayerData")
        return
    endif

    if not IsNull(LoadInteger(gObject, playerData, PlayerData_mHero)) then
        call DebugLog(LOG_ERROR, "GameState_HeroPick_c: Bad Hero pick, player already has a hero!")
        return
    endif

    if unitData != LoadInteger(gObject, playerData, PlayerData_mHeroPicker) then
        call DebugLog(LOG_ERROR, "GameState_HeroPick_c: Bad Hero pick, unit type is not HeroPicker!")
        return
    endif

    set mHero = UnitMgr_CreateUnit(unitTypeData, playerData, GameState_HeroPick_gHeroSpawnX, GameState_HeroPick_gHeroSpawnY)
    call SaveInteger(gObject, playerData, PlayerData_mHero, mHero)

    call UnitMgr_DestroyUnit(LoadInteger(gObject, playerData, PlayerData_mHeroPicker))
    call SaveInteger(gObject, playerData, PlayerData_mHeroPicker, INVALID)

    set mPlayerId = LoadInteger(gObject, playerData, PlayerData_mPlayerId)
    call SetPlayerStateBJ(Player(mPlayerId), PLAYER_STATE_RESOURCE_GOLD, 500)
    call SetPlayerStateBJ(Player(mPlayerId), PLAYER_STATE_RESOURCE_LUMBER, 0)

endfunction

function GameState_HeroPick_CreateHeroPicker takes integer playerData returns nothing
    local integer mHeroPicker = LoadInteger(gObject, playerData, PlayerData_mHeroPicker)
    if not IsNull(mHeroPicker) then
        return
    endif
    set mHeroPicker = UnitMgr_CreateUnit(GameState_HeroPick_gHeroPickerType, playerData, GameState_HeroPick_gHeroPickerSpawnX, GameState_HeroPick_gHeroPickerSpawnY)
    if IsNull(mHeroPicker) then
        call DebugLog(LOG_ERROR, "GameState_HeroPick_c: Failed to make hero picker!")
        return
    endif
    call SaveInteger(gObject, playerData, PlayerData_mHeroPicker, mHeroPicker)
endfunction

function GameState_HeroPick_CmdRepick takes nothing returns nothing
    local player eventPlayer = null 
    local integer eventPlayerData = INVALID
    local integer mHero = INVALID
    if gGameState != GS_HERO_PICK then
        call DebugLog(LOG_INFO, "GameState_HeroPick_c: Cannot repick! Invalid state!")
        return
    endif

    set eventPlayer = Cmd_GetEventPlayer()
    set eventPlayerData = PlayerMgr_FindPlayerData(GetPlayerId(eventPlayer))
    set eventPlayer = null
    if IsNull(eventPlayerData) then
        call DebugLog(LOG_ERROR, "GameState_HeroPick_c: Repick failed, unknown player!")
        return
    endif

    set mHero = LoadInteger(gObject, eventPlayerData, PlayerData_mHero)
    if not IsNull(mHero) then
        call UnitMgr_DestroyUnit(mHero)
        call SaveInteger(gObject, eventPlayerData, PlayerData_mHero, INVALID)
    endif
    call GameState_HeroPick_CreateHeroPicker(eventPlayerData)
endfunction

function GameState_HeroPick_SelectDebugHero takes nothing returns nothing
    call GameState_HeroPick_SelectHero("DebugHero", GetEnteringUnit())
endfunction

function GameState_HeroPick_SelectCaster takes nothing returns nothing
    call GameState_HeroPick_SelectHero("Caster", GetEnteringUnit())
endfunction

function GameState_HeroPick_SelectTank takes nothing returns nothing
    call GameState_HeroPick_SelectHero("SiegeRacer_Tank", GetEnteringUnit())
endfunction

function GameState_HeroPick_PreInit takes nothing returns nothing
    // Initialize starting locations:

    set GameState_HeroPick_gHeroPickerSpawnX = GetRectCenterX(gg_rct_HeroVision)
    set GameState_HeroPick_gHeroPickerSpawnY = GetRectCenterY(gg_rct_HeroVision)
    set GameState_HeroPick_gHeroSpawnX = GetRectCenterX(gg_rct_HeroPickSpawn)
    set GameState_HeroPick_gHeroSpawnY = GetRectCenterY(gg_rct_HeroPickSpawn)
    set GameState_HeroPick_gHeroPickerType = UnitMgr_FindUnitTypeByString("HeroPicker")
    if CONFIG_DEFENSE_MAP then
        call GameState_HeroPick_RegisterHeroPicker(gg_rct_HeroPickDebugHero, function GameState_HeroPick_SelectDebugHero)
        call GameState_HeroPick_RegisterHeroPicker(gg_rct_HeroPickCaster, function GameState_HeroPick_SelectCaster)
    endif

    if CONFIG_SIEGE_RACER_MAP then
        call GameState_HeroPick_RegisterHeroPicker(gg_rct_srHeroPickTank, function GameState_HeroPick_SelectTank)
    endif
endfunction

function GameState_HeroPick_Init takes nothing returns nothing
    call Cmd_RegisterHandler("-repick", function GameState_HeroPick_CmdRepick)
endfunction

function GameState_HeroPick_TransitionOut takes nothing returns nothing
    // Give player's who are playing a random hero.
    call DestroyTimerDialog(GameState_HeroPick_gTimerDialog)
    call DestroyTimer(GameState_HeroPick_gTimer)
    set GameState_HeroPick_gTimer = null
    set GameState_HeroPick_gTimerDialog = null
endfunction

function GameState_HeroPick_TransitionIn takes nothing returns nothing
    // foreach Player
    //   Drop items from existing player owned units/hero's
    //   Destroy existing player owned units/hero's
    //   Reset player resources
    local integer i = 0
    local integer current = 0

    
    // CreateHeroPicker if not already created
    loop 
        exitwhen i >= PlayerMgr_gMaxPlayer
        set current = PlayerMgr_gPlayers[i]
        if PlayerData_IsHumanPlaying(current) then
            call GameState_HeroPick_CreateHeroPicker(current)
        endif
        set i = i + 1
    endloop

    set GameState_HeroPick_gTimer = CreateTimer()
    if CONFIG_GAME_FAST_START then
        call TimerStart(GameState_HeroPick_gTimer, 15.0, false, null)
    else
        call TimerStart(GameState_HeroPick_gTimer, 120.0, false, null)
    endif
    set GameState_HeroPick_gTimerDialog = CreateTimerDialog(GameState_HeroPick_gTimer)
    call TimerDialogSetTitle(GameState_HeroPick_gTimerDialog, "Hero Pick:")
    call TimerDialogDisplay(GameState_HeroPick_gTimerDialog, true)
endfunction

function GameState_HeroPick_Update takes nothing returns nothing
    // Wait a brief period then advance to GS_PLAYING and spawn waves 
    if TimerGetRemaining(GameState_HeroPick_gTimer) <= 0.0 then
        set gNextGameState = GS_PLAYING
    endif
endfunction// ______________________________________________
// Scripts/Game/GameState_Playing_c
// ----------------------------------------------
function GameState_Playing_OnEnterLifeTrigger takes nothing returns nothing
    local unit enteringUnit = GetTriggerUnit()
    local integer unitData = GetUnitId(enteringUnit)
    
    if not IsNull(unitData) and LoadInteger(gObject, unitData, UnitData_mPlayerData) == PlayerMgr_gEnemyForcePlayer then
        set GameState_Playing_gCurrentLives = MaxI(0, GameState_Playing_gCurrentLives - 1)
        call DebugLog(LOG_INFO, "GameState_Playing_c: Remaining Lives " + I2S(GameState_Playing_gCurrentLives))

        if GameState_Playing_gCurrentLives == 0 then
            set gNextGameState = GS_FAILED
        endif

        call UnitData_QueueDestroy(unitData)
    endif

endfunction

function GameState_Playing_PreInit takes nothing returns nothing
    set GameState_Playing_gLifeTrigger = CreateTrigger()
    call TriggerRegisterEnterRectSimple(GameState_Playing_gLifeTrigger, gg_rct_WaveTarget)
    call TriggerAddAction(GameState_Playing_gLifeTrigger, function GameState_Playing_OnEnterLifeTrigger)
endfunction

function GameState_Playing_TransitionOut takes nothing returns nothing
    call DebugLog(LOG_INFO, "GameState_Playing_c: GameDirector_Stop()")
    call GameDirector_Stop()
endfunction

function GameState_Playing_TransitionIn takes nothing returns nothing
    call DebugLog(LOG_INFO, "GameState_Playing_c: GameDirector_Start()")
    set GameState_Playing_gCurrentLives = GameState_Playing_gMaxLives
    call GameDirector_Start()
endfunction

function GameState_Playing_Update takes nothing returns nothing
    // todo: check game win/lose condition
endfunction// ______________________________________________
// Scripts/Game/GameState_Playing_h
// ----------------------------------------------
// @singleton
globals
    trigger GameState_Playing_gLifeTrigger = null

    integer GameState_Playing_gCurrentLives = 0
    integer GameState_Playing_gMaxLives = 300 // Maximum number of lives before game-over
endglobals// ______________________________________________
// Scripts/Game/GameState_Failed_c
// ----------------------------------------------
function GameState_Failed_TransitionOut takes nothing returns nothing
    call DestroyTimerDialog(GameState_Failed_gRestartTimerDialog)
    call DestroyTimer(GameState_Failed_gRestartTimer)
    set GameState_Failed_gRestartTimer = null
    set GameState_Failed_gRestartTimerDialog = null
endfunction

function GameState_Failed_TransitionIn takes nothing returns nothing
    set GameState_Failed_gRestartTimer = CreateTimer()
    call TimerStart(GameState_Failed_gRestartTimer, 15.0, false, null)
    set GameState_Failed_gRestartTimerDialog = CreateTimerDialog(GameState_Failed_gRestartTimer)
    call TimerDialogDisplay(GameState_Failed_gRestartTimerDialog, true)
    call TimerDialogSetTitle(GameState_Failed_gRestartTimerDialog, "Restarting:")
    call PlayerMgr_ResetPlayers()
    
endfunction

function GameState_Failed_Update takes nothing returns nothing
    if TimerGetRemaining(GameState_Failed_gRestartTimer) <= 0.0 then
        set gNextGameState = GS_LOADING
    endif
endfunction// ______________________________________________
// Scripts/Game/GameState_Failed_h
// ----------------------------------------------
globals
    timer GameState_Failed_gRestartTimer = null
    timerdialog GameState_Failed_gRestartTimerDialog = null
endglobals// ______________________________________________
// Scripts/Game/GameState_Success_c
// ----------------------------------------------
function GameState_Success_TransitionOut takes nothing returns nothing

endfunction

function GameState_Success_TransitionIn takes nothing returns nothing

endfunction

function GameState_Success_Update takes nothing returns nothing

endfunction// ______________________________________________
// Scripts/Game/GameState_Success_h
// ----------------------------------------------
globals
    timer GameState_Success_gRestartTimer = null
endglobals// ______________________________________________
// Scripts/Game/Game_h
// ----------------------------------------------
globals


endglobals// ______________________________________________
// Scripts/Game/Game_c
// ----------------------------------------------

function Game_TransitionOut takes nothing returns nothing
    if gGameState == GS_LOADING then
        call GameState_Loading_TransitionOut()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_LOADING->TransitionOut()")
        endif
    elseif gGameState == GS_HERO_PICK then
        call GameState_HeroPick_TransitionOut()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_HERO_PICK->TransitionOut()")
        endif
    elseif gGameState == GS_PLAYING then
        call GameState_Playing_TransitionOut()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_PLAYING->TransitionOut()")
        endif
    elseif gGameState == GS_FAILED then
        call GameState_Failed_TransitionOut()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_FAILED->TransitionOut()")
        endif
    elseif gGameState == GS_SUCCESS then
        call GameState_Success_TransitionOut()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_SUCCESS->TransitionOut()")
        endif
    endif
endfunction

function Game_TransitionIn takes nothing returns nothing
    if gNextGameState == GS_LOADING then
        call GameState_Loading_TransitionIn()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_LOADING->TransitionIn()")
        endif
    elseif gNextGameState == GS_HERO_PICK then
        call GameState_HeroPick_TransitionIn()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_HERO_PICK->TransitionIn()")
        endif
    elseif gNextGameState == GS_PLAYING then
        call GameState_Playing_TransitionIn()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_PLAYING->TransitionIn()")
        endif
    elseif gNextGameState == GS_FAILED then
        call GameState_Failed_TransitionIn()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_FAILED->TransitionIn()")
        endif
    elseif gNextGameState == GS_SUCCESS then
        call GameState_Success_TransitionIn()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_SUCCESS->TransitionIn()")
        endif
    endif
endfunction

function Game_UpdateState takes nothing returns nothing
    local integer mUpdateThread = Thread_GetDriver("Game_UpdateState")

    loop
        call Thread_UpdateTick(mUpdateThread)

        // Process State Changes:
        if gGameState != gNextGameState then
            call Game_TransitionOut()
            call Game_TransitionIn()
            set gGameState = gNextGameState
        endif
        if gGameState == GS_LOADING then
            call GameState_Loading_Update()
        elseif gGameState == GS_HERO_PICK then
            call GameState_HeroPick_Update()
        elseif gGameState == GS_PLAYING then
            call GameState_Playing_Update()
        elseif gGameState == GS_FAILED then
            call GameState_Failed_Update()
        elseif gGameState == GS_SUCCESS then
            call GameState_Success_Update()
        endif
        call Sleep(GAME_DELTA)
    endloop
endfunction 

function Game_DirectorUpdate takes nothing returns nothing
    local integer mUpdateThread = Thread_GetDriver("Game_DirectorUpdate")

    loop
        call Thread_UpdateTick(mUpdateThread)
        call GameDirector_Update()
        call Sleep(GAME_DELTA)
    endloop
endfunction

function Game_DirectorUnitUpdate takes nothing returns nothing
    local integer mUpdateThread = Thread_GetDriver("Game_DirectorUnitUpdate")
    loop
        call Thread_UpdateTick(mUpdateThread)
        call GameDirector_UpdateUnits()
        call Sleep(GAME_DELTA)
    endloop
endfunction

function Game_PlayerHeroUpdate takes nothing returns nothing
    local integer mUpdateThread = Thread_GetDriver("Game_PlayerHeroUpdate")
    loop
        call Thread_UpdateTick(mUpdateThread)
        call PlayerMgr_UpdateHeroes()
        call Sleep(GAME_DELTA)
    endloop 
endfunction

function Game_Update takes nothing returns nothing
    local integer mUpdateThread = Thread_GetDriver("Game_Update")
    local integer mStateThread = INVALID
    local integer mDirectorThread = INVALID
    local integer mDirectorUnitUpdateThread = INVALID
    local integer mPlayerHeroUpdateThread = INVALID
    
    call Thread_RegisterDriver("Game_UpdateState", function Game_UpdateState)
    set mStateThread = Thread_GetDriver("Game_UpdateState")

    call Thread_RegisterDriver("Game_DirectorUpdate", function Game_DirectorUpdate)
    set mDirectorThread = Thread_GetDriver("Game_DirectorUpdate")

    call Thread_RegisterDriver("Game_DirectorUnitUpdate", function Game_DirectorUnitUpdate)
    set mDirectorUnitUpdateThread = Thread_GetDriver("Game_DirectorUnitUpdate")

    call Thread_RegisterDriver("Game_PlayerHeroUpdate", function Game_PlayerHeroUpdate)
    set mPlayerHeroUpdateThread = Thread_GetDriver("Game_PlayerHeroUpdate")

    loop
        call Thread_UpdateTick(mUpdateThread)
        
        // Try and keep threads active
        if not Thread_IsRunning(mStateThread) then
            call Thread_StartDriver("Game_UpdateState")
        endif

        if not Thread_IsRunning(mDirectorThread) then
            call Thread_StartDriver("Game_DirectorUpdate")
        endif

        if not Thread_IsRunning(mDirectorUnitUpdateThread) then
            call Thread_StartDriver("Game_DirectorUnitUpdate")
        endif

        if not Thread_IsRunning(mPlayerHeroUpdateThread) then
            call Thread_StartDriver("Game_PlayerHeroUpdate")
        endif

        call Sleep(GAME_DELTA)
    endloop
endfunction// ______________________________________________
// Scripts/SiegeRacer/SRGame_h
// ----------------------------------------------
globals
    constant integer DEBUG_WATCH_WINDOW = 1

endglobals
// ______________________________________________
// Scripts/SiegeRacer/SRGame_c
// ----------------------------------------------
function SiegeRacer_OnLoadingDone takes nothing returns nothing
    call SetDestructableInvulnerableBJ( udg_SC_GateBack, true )
    call SetDestructableInvulnerableBJ( udg_SC_GateFront, true )
    call ModifyGateBJ( bj_GATEOPERATION_CLOSE, udg_SC_GateBack )
    call ModifyGateBJ( bj_GATEOPERATION_CLOSE, udg_SC_GateFront )
endfunction

function SiegeRacer_TransitionOut takes nothing returns nothing
    if gGameState == GS_LOADING then
        call SiegeRacer_OnLoadingDone()
        call GameState_Loading_TransitionOut()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_LOADING->TransitionOut()")
        endif
    elseif gGameState == GS_HERO_PICK then
        call GameState_HeroPick_TransitionOut()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_HERO_PICK->TransitionOut()")
        endif
    endif
endfunction

function SiegeRacer_TransitionIn takes nothing returns nothing
    if gNextGameState == GS_LOADING then
        call GameState_Loading_TransitionIn()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_LOADING->TransitionIn()")
        endif
    elseif gNextGameState == GS_HERO_PICK then
        call GameState_HeroPick_TransitionIn()
        if CONFIG_GAME_ENABLE_LOGGING then
            call DebugLog(LOG_INFO, "Game_c: GS_HERO_PICK->TransitionIn()")
        endif
    endif
endfunction

function SiegeRacer_UpdateState takes nothing returns nothing
    local integer mUpdateThread = Thread_GetDriver("SiegeRacer_UpdateState")

    loop
        call Thread_UpdateTick(mUpdateThread)

        // Process State Changes:
        if gGameState != gNextGameState then
            call SiegeRacer_TransitionOut()
            call SiegeRacer_TransitionIn()
            set gGameState = gNextGameState
        endif
        if gGameState == GS_LOADING then
            call GameState_Loading_Update()
        elseif gGameState == GS_HERO_PICK then
            call GameState_HeroPick_Update()
        endif

        call Sleep(GAME_DELTA)
    endloop
endfunction

// todo: 
//  -- We need to get a win condition (a lap is completed once all check points have been reached.)
function SiegeRacer_Update takes nothing returns nothing
    local integer mUpdateThread = Thread_GetDriver("SiegeRacer_Update")
    local integer mStateThread = INVALID

    call Thread_RegisterDriver("SiegeRacer_UpdateState", function SiegeRacer_UpdateState)
    set mStateThread = Thread_GetDriver("SiegeRacer_UpdateState")


    loop
        call Thread_UpdateTick(mUpdateThread)

        if not Thread_IsRunning(mStateThread) then
            call Thread_StartDriver("SiegeRacer_UpdateState")
        endif

        call Sleep(GAME_DELTA)
    endloop
endfunction// ______________________________________________
// Scripts/Game/PlayerMgrRegister
// ----------------------------------------------
function PlayerMgr_PreInit takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= bj_MAX_PLAYERS
        if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
            call PlayerMgr_RegisterPlayer(i)
        endif
        set i = i + 1
    endloop

    call PlayerMgr_RegisterEnemyForcePlayer(8)
    call PlayerMgr_RegisterAllyForcePlayer(9)
endfunction// ______________________________________________
// Scripts/Game/UnitMgrRegister
// ----------------------------------------------
function UnitMgr_RegisterInit takes integer unitTypeData, code callback returns integer
    local trigger mInitCallback = null
    if callback == null then
        return unitTypeData
    endif
    set mInitCallback = CreateTrigger()
    call TriggerAddAction(mInitCallback, callback)
    call SaveTriggerHandle(gObject, unitTypeData, UnitTypeData_mInitCallback, mInitCallback)
    set mInitCallback = null
    return unitTypeData
endfunction

function UnitMgr_AddHeroComponents takes integer unitTypeData, integer unitData returns nothing
    local integer component = INVALID

    call DebugLog(LOG_INFO, "UnitMgrRegister: UnitData_DebugHero_Create")
    if Invalid(unitTypeData) or Invalid(unitData) then
        return
    endif

    set component = PlayerHeroComponent_Create()
    if not IsNull(component) then
        call UnitData_AddComponent(unitData, component)
    else
        call DebugLog(LOG_ERROR, "UnitMgrRegister: UnitData_DebugHero_Create failed to create component PlayerHeroComponent!")
    endif
endfunction

function UnitData_DebugHero_Create takes nothing returns nothing
    local integer unitTypeData = UnitTypeData_gArg_Init_typeData
    local integer unitData = UnitTypeData_gArg_Init_unitData
    call UnitMgr_AddHeroComponents(unitTypeData, unitData)
endfunction

function UnitData_Caster_Create takes nothing returns nothing
    local integer unitTypeData = UnitTypeData_gArg_Init_typeData
    local integer unitData = UnitTypeData_gArg_Init_unitData
    call UnitMgr_AddHeroComponents(unitTypeData, unitData)
endfunction

// todo: I think we should have a different type of 'HeroRespawn' component on the hero.
// Respawn in place?
function UnitData_Tank_Create takes nothing returns nothing
    local integer unitTypeData = UnitTypeData_gArg_Init_typeData
    local integer unitData = UnitTypeData_gArg_Init_unitData
    call UnitMgr_AddHeroComponents(unitTypeData, unitData)
endfunction

function UnitMgr_PreInit takes nothing returns nothing
    set UnitMgr_gTypes = List_Create(TYPE_ID_UNIT_TYPE_DATA)

    call UnitMgr_RegisterInit(UnitMgr_RegisterUnitType('H002',"DebugHero"), function UnitData_DebugHero_Create)
    call UnitMgr_RegisterUnitType('h003',"HeroPicker")

    call UnitMgr_RegisterUnitType('h000',"TestWaveUnit")
    call UnitMgr_RegisterUnitType('h001',"TestWaveUnit2")

    call UnitMgr_RegisterInit(UnitMgr_RegisterUnitType('H004', "Caster"), function UnitData_Caster_Create)
    call UnitMgr_RegisterInit(UnitMgr_RegisterUnitType('H00E', "SiegeRacer_Tank"), function UnitData_Tank_Create)
    

    call UnitMgr_RegisterUnitType('h005', "Gnoll")
    call UnitMgr_RegisterUnitType('h006', "Kobold")
    call UnitMgr_RegisterUnitType('h007', "Troll")
    call UnitMgr_RegisterUnitType('h008', "Gnoll Poacher")
    call UnitMgr_RegisterUnitType('h009', "Kobold Miner")
    call UnitMgr_RegisterUnitType('h00A', "Troll Axe Thrower")



    set UnitMgr_gTypes_mSize = List_GetSize(UnitMgr_gTypes)

    if CONFIG_GAME_ENABLE_LOGGING then
        call DebugLog(LOG_INFO, "UnitMgrRegister: Registered " + I2S(UnitMgr_gTypes_mSize) + " unit types")
    endif
endfunction// ______________________________________________
// Scripts/Game/ComponentRegister
// ----------------------------------------------
function Component_PreInit takes nothing returns nothing
    set RunToCityComponent_gDestroyFunc = function RunToCityComponent_Destroy
    set RunToCityComponent_gUpdateFunc = function RunToCityComponent_Update
    set PlayerHeroComponent_gDestroyFunc = function PlayerHeroComponent_Destroy
    set PlayerHeroComponent_gUpdateFunc = function PlayerHeroComponent_Update
    set MonitorUnitLifeComponent_gDestroyFunc = function MonitorUnitLifeComponent_Destroy
    set MonitorUnitLifeComponent_gUpdateFunc = function MonitorUnitLifeComponent_Update
endfunction// ______________________________________________
// Scripts/Game/GameDirectorRegister
// ----------------------------------------------
function GameDirector_RegisterWave takes string typeName, boolean isBossWave, integer spawnCount, real spawnDelay returns nothing
    local integer data = SpawnWaveData_Create()
    call SaveInteger(gObject, data, SpawnWaveData_mSpawnCount, spawnCount)
    call SaveReal(gObject, data, SpawnWaveData_mSpawnDelay, spawnDelay)
    call SaveInteger(gObject, data, SpawnWaveData_mUnitType, UnitMgr_FindUnitTypeByString(typeName))
    call SaveBoolean(gObject, data, SpawnWaveData_mIsBoss, isBossWave)

    set GameDirector_gSpawnWaveData[GameDirector_gSpawnWaveData_mSize] = data
    set GameDirector_gSpawnWaveData_mSize = GameDirector_gSpawnWaveData_mSize + 1

    if IsNull(LoadInteger(gObject, data, SpawnWaveData_mUnitType)) then
        call DebugLog(LOG_ERROR, "GameDirector_c: Failed to register type " + typeName)
    endif
endfunction


function GameDirector_AddSpawnPoint takes rect area returns nothing
    set GameDirector_gSpawnX[GameDirector_gSpawnPointCount] = GetRectCenterX(area)
    set GameDirector_gSpawnY[GameDirector_gSpawnPointCount] = GetRectCenterY(area)
    set GameDirector_gSpawnPointCount = GameDirector_gSpawnPointCount + 1
endfunction

function GameDirector_PreInit takes nothing returns nothing
    local integer i = 0
    loop
        exitwhen i >= GameDirector_gMaxUnit
        set GameDirector_gWaveUnits[i] = INVALID
        set i = i + 1
    endloop
    call GameDirector_AddSpawnPoint(gg_rct_WaveSpawner0)
    call GameDirector_AddSpawnPoint(gg_rct_WaveSpawner1)
    call GameDirector_AddSpawnPoint(gg_rct_WaveSpawner2)
    call GameDirector_AddSpawnPoint(gg_rct_WaveSpawner3)
    set GameDirector_gTargetX = GetRectCenterX(gg_rct_WaveTarget)
    set GameDirector_gTargetY = GetRectCenterY(gg_rct_WaveTarget)

    // call GameDirector_RegisterWave("TestWaveUnit", false, 3, 1.75)
    // call GameDirector_RegisterWave("TestWaveUnit2", false, 3, 1.75)

    call GameDirector_RegisterWave("Gnoll", false, 10, 1.75)
    call GameDirector_RegisterWave("Kobold", false, 10, 1.75)
    call GameDirector_RegisterWave("Troll", false, 10, 1.75)
    call GameDirector_RegisterWave("Gnoll Poacher", false, 10, 1.75)
    call GameDirector_RegisterWave("Kobold Miner", false, 10, 1.75)
    call GameDirector_RegisterWave("Troll Axe Thrower", false, 10, 1.75)



    if CONFIG_GAME_ENABLE_LOGGING then
        call DebugLog(LOG_INFO, "GameDirectorRegister: Registered " + I2S(GameDirector_gSpawnWaveData_mSize) + " waves")
    endif
endfunction// ______________________________________________
// Scripts/Game/GameState_c
// ----------------------------------------------
function GameState_PreInit takes nothing returns nothing
    call DebugLog(LOG_INFO, "GameState_PreInit")

    call PlayerMgr_PreInit()
    call UnitMgr_PreInit()
    if CONFIG_DEFENSE_MAP then
        call GameDirector_PreInit()
    endif
    call Component_PreInit()

    if CONFIG_DEFENSE_MAP then
        call GameState_HeroPick_PreInit()
        call GameState_Playing_PreInit()
    endif

    if CONFIG_SIEGE_RACER_MAP then
        call GameState_HeroPick_PreInit()
    endif
endfunction

function GameState_Init takes nothing returns nothing
    call DebugLog(LOG_INFO, "GameState_Init")

    if CONFIG_DEFENSE_MAP then
        call GameState_HeroPick_Init()

        call Thread_RegisterDriver("Game_Update", function Game_Update)
        call Thread_StartDriver("Game_Update")
    endif

    if CONFIG_SIEGE_RACER_MAP then
        call GameState_HeroPick_Init()

        call Thread_RegisterDriver("SiegeRacer_Update", function SiegeRacer_Update)
        call Thread_StartDriver("SiegeRacer_Update")
    endif
endfunction// ______________________________________________
// Scripts/Commands/CmdGame
// ----------------------------------------------


// -game list players
// -game list units <player>
// -game kill
// -game teleport
function CmdProc_Game takes nothing returns nothing
    local integer eventArgs = Cmd_GetEventArgs()
    if CmdMatch("start", 1, eventArgs) then
        call DebugLog(LOG_INFO, "Start")
    elseif CmdMatch("restart", 1, eventArgs) then
        call DebugLog(LOG_INFO, "Restart")
    elseif CmdMatch("stop", 1, eventArgs) then
        call DebugLog(LOG_INFO, "Stop")
    elseif CmdMatch("help", 1, eventArgs) then
        call DebugLog(LOG_INFO, "Usage: ")
        call DebugLog(LOG_INFO, "-game start")
        call DebugLog(LOG_INFO, "-game restart")
        call DebugLog(LOG_INFO, "-game stop")
    endif
endfunction

function CmdGame_Init takes nothing returns nothing
    call Cmd_RegisterHandler("-game", function CmdProc_Game)
endfunction// ______________________________________________
// Scripts/Commands/CmdDebug
// ----------------------------------------------
// -debug component.view
// -debug 

function CmdDebug_GetSelectedUnits takes player p returns integer
    local group selectedUnits = GetUnitsSelectedAll(p)
    local integer unitData = GetUnitId(FirstOfGroup(selectedUnits))
    call DestroyGroup(selectedUnits)
    set selectedUnits = null
    return unitData
endfunction

function CmdDebug_ComponentView takes nothing returns nothing
    local integer unitData = CmdDebug_GetSelectedUnits(Cmd_GetEventPlayer())
    local integer mComponents = INVALID
    local integer mComponents_mSize = 0
    local integer i = 0
    local integer component = INVALID
    if IsNull(unitData) then
        call DebugLog(LOG_INFO, "Missing unit data")
        return
    endif
    call DebugLog(LOG_INFO, "Showing Components for [" + I2S(unitData) + "]")
    set mComponents = UnitData_GetComponents(unitData)
    set mComponents_mSize = List_GetSize(mComponents)
    loop
        exitwhen i >= mComponents_mSize
        set component = List_GetObject(mComponents, i)
        call DebugLog(LOG_INFO, "[" + I2S(component) + "] " + Object_GetTypeName(Object_GetTypeId(component)))
        set i = i + 1
    endloop
endfunction

function CmdDebug_SetLevel takes integer level returns nothing
    local integer unitData = CmdDebug_GetSelectedUnits(Cmd_GetEventPlayer())
    local unit u = null

    if IsNull(unitData) then
        return
    endif
    
    call DebugLog(LOG_INFO, "Set Level to " + I2S(level))
    if UnitTypeData_IsHero(LoadInteger(gObject, unitData, UnitData_mTypeData)) then
        set u = LoadUnitHandle(gObject, unitData, UnitData_mHandle)
        call SetHeroLevel(u, level, true)
    endif
    set u = null
endfunction

function CmdDebug_Help takes nothing returns nothing
    call DebugLog(LOG_INFO, "Available Commands")
    call DebugLog(LOG_INFO, "-debug component.view : Shows the list of components on the selected unit.")
endfunction

function CmdDebug_AddWatch takes integer eventArgs returns nothing
    local string name = Cmd_GetString(eventArgs, 3)
    local string address = Cmd_GetString(eventArgs, 4)
    local string member = Cmd_GetString(eventArgs, 5)
    local string typeID = StringCase(Cmd_GetString(eventArgs, 6), false)

// -debug watch add <name> <address> <member> <type:integer>
//    -     1    2    3        4        5          6
    if typeID == "" then
        set typeID = "int"
    endif


    if typeID != "int" and typeID != "integer" and typeID != "real" and typeID != "string" and typeID != "object" then
        call DebugLog(LOG_INFO, "'debug watch add' expects the type to be one of the following: 'int' 'real' 'string' or 'object'")
        return
    endif

    if name == "" then
        call DebugLog(LOG_INFO, "'debug watch add' expects <name> <address> <member>, missing 'name'")
        return
    endif

    if address == "" then
        call DebugLog(LOG_INFO, "'debug watch add' expects <name> <address> <member>, missing 'address'")
        return
    endif

    if member == "" then
        call DebugLog(LOG_INFO, "'debug watch add' expects <name> <address> <member>, missing 'member'")
        return
    endif

    if typeID == "int" or typeID == "integer" then
        set typeID = Debug_GetTypeString(DEBUG_TYPE_INTEGER)
    elseif typeID == "real" then
        set typeID = Debug_GetTypeString(DEBUG_TYPE_REAL)
    elseif typeID == "string" then
        set typeID = Debug_GetTypeString(DEBUG_TYPE_STRING)
    elseif typeID == "object" then
        set typeID = Debug_GetTypeString(DEBUG_TYPE_OBJECT)
    endif

    call Debug_AddWatch(name, S2I(address), S2I(member), typeID)
endfunction

function CmdDebug_RemoveWatch takes integer eventArgs returns nothing
    local string index = Cmd_GetString(eventArgs, 3)
    if index == "" then
        call DebugLog(LOG_INFO, "debug watch remove missing argument <index>.")
        return
    endif
    call Debug_RemoveWatchAt(S2I(index))
endfunction

function CmdDebug_ClearWatch takes nothing returns nothing
    set gDebugWatchCount = 0
endfunction

function CmdProc_Debug takes nothing returns nothing
    local integer eventArgs = Cmd_GetEventArgs()
    if CmdMatch("component.view", 1, eventArgs) then
        call CmdDebug_ComponentView()
    elseif CmdMatch("setlevel", 1, eventArgs) then
        if List_GetSize(eventArgs) >= 3 then
            call CmdDebug_SetLevel(S2I(List_GetString(eventArgs, 2)))
        else
            call DebugLog(LOG_INFO, "Missing arg <level>")
        endif
    elseif CmdMatch("help", 1, eventArgs) then
        call CmdDebug_Help()
    elseif CmdMatch("fastpick", 1, eventArgs) then
        if gGameState == GS_HERO_PICK and TimerGetRemaining(GameState_HeroPick_gTimer) > 15.0 then
            call TimerStart(GameState_HeroPick_gTimer, 15.0, false, null)
        endif
    elseif CmdMatch("watch", 1, eventArgs) then
        if CmdMatch("show", 2, eventArgs) then
            call Debug_ShowWatch()
        elseif CmdMatch("hide", 2, eventArgs) then
            call Debug_HideWatch()
        elseif CmdMatch("add", 2, eventArgs) then
            call CmdDebug_AddWatch(eventArgs)
        elseif CmdMatch("remove", 2, eventArgs) then
            call CmdDebug_RemoveWatch(eventArgs)

        elseif CmdMatch("clear", 2, eventArgs) then
            call CmdDebug_ClearWatch()
        else
            call DebugLog(LOG_INFO, "Invalid argument for 'debug watch' command. Use either 'show' or 'hide'")
        endif
    else
        call CmdDebug_Help()
    endif

endfunction

function CmdDebug_Init takes nothing returns nothing
    call Cmd_RegisterHandler("-debug", function CmdProc_Debug)

endfunction// ______________________________________________
// Scripts/Core/Main
// ----------------------------------------------
globals
	
endglobals

function Main_ThreadUpdate takes nothing returns nothing
    local integer driver = Thread_GetDriver("Main_ThreadUpdate")
	call Thread_UpdateTick(driver)
	call Sleep(GAME_DELTA)
	call Thread_Update(driver)
endfunction

function Main_UpdateDebug takes nothing returns nothing
    local integer driver = Thread_GetDriver("Main_UpdateDebug")
    loop
        call Thread_UpdateTick(driver)
        call Sleep(GAME_DELTA)
        call Debug_Update()
    endloop
endfunction

function Main_PreInit takes nothing returns nothing
    call DebugLog(LOG_INFO, "Main_PreInit...")
    call Object_PreInit()
    call Debug_PreInit()
    call Cmd_PreInit()
    call Thread_PreInit()
    call Thread_RegisterDriver("Main_ThreadUpdate", function Main_ThreadUpdate)
    call Thread_StartDriver("Main_ThreadUpdate")
    call Thread_RegisterDriver("Main_UpdateDebug", function Main_UpdateDebug)
    call Thread_StartDriver("Main_UpdateDebug")
    // call UnitHook_PreInit()
    // call GameRules_PreInit()
    call GameState_PreInit()
    call DebugLog(LOG_INFO, "Main_PreInit finished.")
endfunction

function Main_Init takes nothing returns nothing
    call DebugLog(LOG_INFO, "Main_Init...")
    call GameState_Init()
    // call GameRules_Init()
    // call CmdObject_Init()
    call CmdGame_Init()
    call CmdDebug_Init()
    call DebugLog(LOG_INFO, "Main_Init finished.")

    
endfunction

function Trig_Main_Actions takes nothing returns nothing    
    call Sleep(5.0) // Wait a bit so that the logging works.
    call Main_PreInit()
    call Main_Init()

    call Object_Test()
    // call Cmd_Test()
    call DebugLog(LOG_INFO, "Initialization Complete")
endfunction

//===========================================================================
function InitTrig_Main takes nothing returns nothing
    set gg_trg_Main = CreateTrigger(  )
    call TriggerAddAction( gg_trg_Main, function Trig_Main_Actions )
endfunction

