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
endfunction