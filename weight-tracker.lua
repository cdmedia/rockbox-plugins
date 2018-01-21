--
-- Weight Tracker
-- Built for Rockbox using the Lua Plugin

require("actions")
require("buttons")

local function Ordered()
  -- nextkey and firstkey are used as markers; nextkey[firstkey] is
  -- the first key in the table, and nextkey[nextkey] is the last key.
  -- nextkey[nextkey[nextkey]] should always be nil.
 
  local key2val, nextkey, firstkey = {}, {}, {}
  nextkey[nextkey] = firstkey
 
  local function onext(self, key)
    while key ~= nil do
      key = nextkey[key]
      local val = self[key]
      if val ~= nil then return key, val end
    end
  end
 
  -- To save on tables, we use firstkey for the (customised)
  -- metatable; this line is just for documentation
  local selfmeta = firstkey
 
  -- record the nextkey table, for routines lacking the closure
  selfmeta.__nextkey = nextkey
 
  -- setting a new key (might) require adding the key to the chain
  function selfmeta:__newindex(key, val)
    rawset(self, key, val)
    if nextkey[key] == nil then -- adding a new key
      nextkey[nextkey[nextkey]] = key
      nextkey[nextkey] = key
    end
  end
 
  -- if you don't have the __pairs patch, use this:
  -- local _p = pairs; function pairs(t, ...)
  --    return (getmetatable(t).__pairs or _p)(t, ...) end
  function selfmeta:__pairs() return onext, self, firstkey end
 
  return setmetatable(key2val, selfmeta)
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

SAVE_FILE = rb.current_path().."weight-tracker.save"
DATA = Ordered()
TEXT_LINE_HEIGHT = rb.font_getstringsize(" ", 1)
WEIGHT = 150


-- Helper function that acts like a normal printf() would do
local line = 0
function printf(...)
    local msg = string.format(...)
    local res, w, h = rb.font_getstringsize(msg, rb.FONT_UI)

    if(w >= rb.LCD_WIDTH) then
        rb.lcd_puts_scroll(0, line, msg)
    else
        rb.lcd_puts(0, line, msg)
    end
    rb.lcd_update()

    line = line + 1

    if(h * line >= rb.LCD_HEIGHT) then
        line = 0
    end
end

--Saves weight to file
function save_weight(filename, weight)
    local datetime = os.time()
    local file = io.open(filename, "a+")
    file:write(datetime .. ',' .. weight, "\n")
    file:close()
    rb.splash(5, "Entry saved!")
end


--Loads the save file
--Returns true on success, false otherwise
function load_file(filename)
    local f = io.open(filename, "r")
    local index = 1
    if f ~= nil then
        for _ in io.lines(filename) do
            local line = f:read()
            datetime, weight = line:match("([^,]+),([^,]+)")
            --DATA[datetime] = weight
            DATA[index] = {datetime = datetime, weight = weight}
            WEIGHT = weight
            index = index + 1
        end
        f:close()
        return true
    else
        return false
    end
end

function reverseTable(t)
    local reversedTable = {}
    local itemCount = #t
    for k, v in ipairs(t) do
        reversedTable[itemCount + 1 - k] = v
    end
    return reversedTable
end

-- function reverse(tbl)
--   for i=1, math.floor(#tbl / 2) do
--     tbl[i], tbl[#tbl - i + 1] = tbl[#tbl - i + 1], tbl[i]
--   end
-- end
-- function reverse(tbl)
--   for i=1, math.floor(#tbl / 2) do
--     local tmp = tbl[i]
--     tbl[i] = tbl[#tbl - i + 1]
--     tbl[#tbl - i + 1] = tmp
--   end
-- end

function show_history()
    load_file(SAVE_FILE)
    rb.lcd_clear_display()
    line = 0
    printf('Weight History')
    printf('--------------')

    function draw_entries()
        --for datetime, weight in pairs(DATA) do 
        --for datetime, weight in spairs(DATA, function(t,a,b) return t[b] < t[a] end) do    
        local newestDataFirst = reverseTable(DATA)
        for i,v in ipairs(newestDataFirst) do
            formatted_date = os.date("%x", v.datetime)
            formatted_time = os.date("%I:%M%p", v.datetime)
            printf(v.weight, formatted_date, formatted_time)
        end
    end

    draw_entries()
    local exit = false
    repeat
        local action = rb.get_action(rb.contexts.CONTEXT_KEYBOARD, -1)
        if action == rb.actions.ACTION_KBD_DOWN then
        elseif action == rb.actions.ACTION_KBD_UP then
        elseif action == rb.actions.ACTION_KBD_LEFT or 
            action == rb.actions.ACTION_KBD_RIGHT or 
            action == rb.actions.ACTION_KBD_SELECT or
            action == rb.actions.ACTION_KBD_ABORT then
            exit = true
        end
        rb.lcd_clear_display()
        draw_entries()
    until exit == true
end


--Draws the application menu and handles its logic
function showMainMenu() 
    mainmenu = {"Add Entry", "View Chart", "Show History", "Exit"} 

    while true do -- don't exit of program until user selects Exit
        s = rb.do_menu("Weight Tracker", mainmenu, nil, false) 
        if     s == 0 then add_entry()
        elseif s == 1 then draw_chart() 
        elseif s == 2 then show_history()
        elseif s == 3 then os.exit() 
        elseif s == -2 then os.exit()
        else rb.splash(2 * rb.HZ, "Error! Selected index: " .. s)
        end
    end
end


function increment_up()
    WEIGHT = WEIGHT + 1
end


function increment_down()
    WEIGHT = WEIGHT - 1
end


function add_entry()
    rb.lcd_clear_display()

    local title = "Add Weight Entry"
    local rtn, title_width, h = rb.font_getstringsize(title, 1)
    local title_xpos = (rb.LCD_WIDTH - title_width) / 2
    local space_width = rb.font_getstringsize(" ", 1)

    function draw_content()
        rb.lcd_set_foreground(rb.lcd_rgbpack(255,0,0))
        rb.lcd_putsxy(title_xpos, 0, title)
        rb.lcd_hline(title_xpos, title_xpos + title_width, TEXT_LINE_HEIGHT)
        rb.lcd_set_foreground(rb.lcd_rgbpack(255,255,255))

        rb.lcd_putsxy(0, (rb.LCD_WIDTH / 2), WEIGHT)

        rb.lcd_update()
        return true
    end

    draw_content()
    local exit = false
    repeat
        local action = rb.get_action(rb.contexts.CONTEXT_KEYBOARD, -1)
        if action == rb.actions.ACTION_KBD_DOWN then
            increment_down()
        elseif action == rb.actions.ACTION_KBD_UP then
            increment_up()
        elseif action == rb.actions.ACTION_KBD_SELECT then
            save_weight(SAVE_FILE, WEIGHT)
            exit = true
        elseif action == rb.actions.ACTION_KBD_LEFT or 
            action == rb.actions.ACTION_KBD_RIGHT or 
            action == rb.actions.ACTION_KBD_ABORT then
            exit = true
        end
        rb.lcd_clear_display()
        draw_content()
    until exit == true
end


function draw_chart()
    load_file(SAVE_FILE)
    local scale = 200

    rb.lcd_clear_display()
    function draw_entries()
        local xpos = 0
        local bar_width = 3
        for i,v in ipairs(DATA) do
        --for datetime, weight in spairs(DATA, function(t,a,b) return t[b] < t[a] end) do 
            local percentage = (v.weight * 100) / scale
            local screen_percentage = rb.LCD_HEIGHT * percentage
            local bar_height = math.floor(screen_percentage / 100)
            rb.lcd_drawrect(xpos, (rb.LCD_HEIGHT - bar_height), bar_width, bar_height)
            xpos = xpos + bar_width
        end
        rb.lcd_update()
    end

    draw_entries()
    local exit = false
    repeat
        local action = rb.get_action(rb.contexts.CONTEXT_KEYBOARD, -1)
        if action == rb.actions.ACTION_KBD_DOWN then
        elseif action == rb.actions.ACTION_KBD_UP then
        elseif action == rb.actions.ACTION_KBD_LEFT or 
            action == rb.actions.ACTION_KBD_RIGHT or 
            action == rb.actions.ACTION_KBD_SELECT or
            action == rb.actions.ACTION_KBD_ABORT then
            exit = true
        end
        rb.lcd_clear_display()
        draw_entries()
    until exit == true
end


function show_history_long()
    rb.lcd_clear_display()

    local title = "Weight History"
    local rtn, title_width, h = rb.font_getstringsize(title, 1)
    local title_xpos = (rb.LCD_WIDTH - title_width) / 2
    local space_width = rb.font_getstringsize(" ", 1)

    function draw_text(y_offset)
        rb.lcd_set_foreground(rb.lcd_rgbpack(255,0,0))
        rb.lcd_putsxy(title_xpos, y_offset, title)
        rb.lcd_hline(title_xpos, title_xpos + title_width, TEXT_LINE_HEIGHT + y_offset)
        rb.lcd_set_foreground(rb.lcd_rgbpack(255,255,255))

        -- for datetime, weight in pairs(DATA) do
        --     formatted_datetime = os.date("%c", datetime)
        --     print(formatted_datetime)
        -- end
        local body_text = [[
            Coming soon!
        ]]
        local body_len = string.len(body_text)

        --Draw body text
        local word_buffer = ""
        local xpos = 0
        local ypos = TEXT_LINE_HEIGHT * 2 
        for i=1,body_len do
            local c = string.sub(body_text, i, i)
            if c == " " or c == "\n" then
                local word_length = rb.font_getstringsize(word_buffer, 1)
                if (xpos + word_length) > rb.LCD_WIDTH then
                    xpos = 0
                    ypos = ypos + TEXT_LINE_HEIGHT
                end
                rb.lcd_putsxy(xpos, ypos + y_offset, word_buffer)

                word_buffer = ""
                if c == "\n" then
                    xpos = 0
                    ypos = ypos + TEXT_LINE_HEIGHT
                else
                    xpos = xpos + word_length + space_width
                end
            else
                word_buffer = word_buffer .. c
            end
        end

        rb.lcd_update()

        return ypos
    end

    --Deal with scrolling the help
    local y_offset = 0
    local max_y_offset = math.max(draw_text(y_offset) - rb.LCD_HEIGHT, 0)
    local exit = false
    repeat
        local action = rb.get_action(rb.contexts.CONTEXT_KEYBOARD, -1)
        if action == rb.actions.ACTION_KBD_DOWN then
            y_offset = math.max(-max_y_offset, y_offset - TEXT_LINE_HEIGHT)
        elseif action == rb.actions.ACTION_KBD_UP then
            y_offset = math.min(0, y_offset + TEXT_LINE_HEIGHT)
        elseif action == rb.actions.ACTION_KBD_LEFT or 
            action == rb.actions.ACTION_KBD_RIGHT or 
            action == rb.actions.ACTION_KBD_SELECT or 
            action == rb.actions.ACTION_KBD_ABORT then
            exit = true
        end
        rb.lcd_clear_display()
        draw_text(y_offset)
    until exit == true

end


function start()
    load_file(SAVE_FILE)
    showMainMenu()
end

start()