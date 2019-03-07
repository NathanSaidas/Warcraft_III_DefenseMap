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
endglobals