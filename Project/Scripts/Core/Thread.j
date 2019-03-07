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
endfunction