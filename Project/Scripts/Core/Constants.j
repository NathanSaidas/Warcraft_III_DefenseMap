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
    constant boolean CONFIG_GAME_FAST_START = true
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
