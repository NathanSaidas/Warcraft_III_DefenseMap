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

function UnitData_DebugHero_Create takes nothing returns nothing
    local integer unitTypeData = UnitTypeData_gArg_Init_typeData
    local integer unitData = UnitTypeData_gArg_Init_unitData
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

function UnitMgr_PreInit takes nothing returns nothing
    set UnitMgr_gTypes = List_Create(TYPE_ID_UNIT_TYPE_DATA)

    call UnitMgr_RegisterInit(UnitMgr_RegisterUnitType('H002',"DebugHero"), function UnitData_DebugHero_Create)
    call UnitMgr_RegisterUnitType('h003',"HeroPicker")

    call UnitMgr_RegisterUnitType('h000',"TestWaveUnit")
    call UnitMgr_RegisterUnitType('h001',"TestWaveUnit2")


    set UnitMgr_gTypes_mSize = List_GetSize(UnitMgr_gTypes)

    if CONFIG_GAME_ENABLE_LOGGING then
        call DebugLog(LOG_INFO, "UnitMgrRegister: Registered " + I2S(UnitMgr_gTypes_mSize) + " unit types")
    endif
endfunction