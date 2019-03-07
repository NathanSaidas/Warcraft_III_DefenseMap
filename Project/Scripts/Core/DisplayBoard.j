
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
endfunction