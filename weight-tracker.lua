--
-- Weight Tracker
-- Built for Rockbox using the Lua Plugin

require("actions")
require("buttons")

FILES_ROOT = "/.rockbox/rocks/games/"
SAVE_FILE = FILES_ROOT.."weight-tracker.save"
DATA = {}
TEXT_LINE_HEIGHT = rb.font_getstringsize(" ", 1)
WEIGHT = 150

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
    if f ~= nil then
        for _ in io.lines(filename) do
            local line = f:read()
            datetime, weight = line:match("([^,]+),([^,]+)")
            DATA[datetime] = weight
            WEIGHT = weight
        end
        f:close()
        return true
    else
        return false
    end
end


--Draws the application menu and handles its logic
function showMainMenu() 
    mainmenu = {"Add Entry", "Chart", "History", "Exit"} 

    while true do -- don't exit of program until user selects Exit
        s = rb.do_menu("Main Menu", mainmenu, nil, false) 
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
    local min = 0
    local max = 300

    rb.lcd_clear_display()
    --rb.lcd_drawrect(0, 0, rb.LCD_WIDTH, ((rb.LCD_HEIGHT / 3) * 2) )

    local xpos = 1
    for datetime, weight in pairs(DATA) do
        rb.lcd_drawpixel(xpos, ((rb.LCD_HEIGHT / max) * weight))
        xpos = xpos + 1
    end

    rb.lcd_update()
    rb.sleep(10 * rb.HZ)
end


function show_history()
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

        -- for datetime, weight in pairs(HISTORY) do
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