globals
    constant integer GS_LOADING = 0
    constant integer GS_HERO_PICK = 1
    constant integer GS_PLAYING = 2
    constant integer GS_FAILED = 3
    constant integer GS_SUCCESS = 4
    constant integer GS_NONE = 5

    integer gGameState = GS_NONE
    integer gNextGameState = GS_LOADING
endglobals