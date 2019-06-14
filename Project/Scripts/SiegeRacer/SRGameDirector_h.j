// Task:
// Spawn AI-Players
// Spawn AI-Enemies

globals
    integer array SRGameDirector_gPlayerUnits
    integer       SRGameDirector_gPlayerUnits_mSize = 0
    integer       SRGameDirector_gMaxUnit = 150

    real          SRGameDirector_gPlayerSpawnX = 0.0
    real          SRGameDirector_gPlayerSpawnY = 0.0
endglobals

function SRGameDirector_PreInit takes nothing returns nothing
    set SRGameDirector_gPlayerSpawnX = GetRectCenterX(gg_rct_HeroPickSpawn)
    set SRGameDirector_gPlayerSpawnY = GetRectCenterY(gg_rct_HeroPickSpawn)
endfunction

// function SRGameDirector_SpawnAIPlayerUnits takes nothing returns nothing
// function SRGameDirector_RemoveAIPlayerUnits takes nothing returns nothing
// function SRGameDirector_UpdateAIPlayerUnits takes nothing returns nothing