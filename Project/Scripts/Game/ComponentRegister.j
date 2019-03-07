function Component_PreInit takes nothing returns nothing
    set RunToCityComponent_gDestroyFunc = function RunToCityComponent_Destroy
    set RunToCityComponent_gUpdateFunc = function RunToCityComponent_Update
    set PlayerHeroComponent_gDestroyFunc = function PlayerHeroComponent_Destroy
    set PlayerHeroComponent_gUpdateFunc = function PlayerHeroComponent_Update
    set MonitorUnitLifeComponent_gDestroyFunc = function MonitorUnitLifeComponent_Destroy
    set MonitorUnitLifeComponent_gUpdateFunc = function MonitorUnitLifeComponent_Update
endfunction