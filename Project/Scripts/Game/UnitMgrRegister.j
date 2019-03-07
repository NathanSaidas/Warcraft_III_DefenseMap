function UnitMgr_PreInit takes nothing returns nothing
    set UnitMgr_gTypes = List_Create(TYPE_ID_UNIT_TYPE_DATA)

    call UnitMgr_RegisterUnitType('H002',"DebugHero")
    call UnitMgr_RegisterUnitType('h003',"HeroPicker")

    call UnitMgr_RegisterUnitType('h000',"TestWaveUnit")
    call UnitMgr_RegisterUnitType('h001',"TestWaveUnit2")


    set UnitMgr_gTypes_mSize = List_GetSize(UnitMgr_gTypes)

    if CONFIG_GAME_ENABLE_LOGGING then
        call DebugLog(LOG_INFO, "UnitMgrRegister: Registered " + I2S(UnitMgr_gTypes_mSize) + " unit types")
    endif
endfunction