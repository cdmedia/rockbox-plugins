--
-- Weight Tracker
-- Built for Rockbox using the Lua Plugin

--FILES_ROOT = "/.rockbox/rocks/games/"
--SAVE_FILE = FILES_ROOT.."weight-tracker.save"
SAVE_FILE = "weight-tracker.save"

--local weight = io.read('*n')

--Saves weight to file
function save_weight(filename, weight)
    local datetime = os.time()
    local file = io.open(filename, "a+")
    file:write(weight .. ',' .. datetime, "\n")
    file:write("\n")
    file:close()
    --rb.splash(1, "Saving game...")
end


--Loads the save file
--Returns true on success, false otherwise
function load_file(filename)
    local f = io.open(filename, "r")
    if f ~= nil then
        --local history = {}
        for i=1,2 do
            local line = f:read()
            weight, datetime = line:match("([^,]+),([^,]+)")
            formatted_datetime = os.date("%c", datetime)
            print(formatted_datetime)
            --histroy[i] = value
        end
        f:close()
        --return history
    else
        return false
    end
end

function draw_day(day, weight)
end

function draw_chart()
    rb.lcd_clear_display()
    rb.lcd_drawline(rb.LCD_WIDTH, 0, 0, rb.LCD_HEIGHT)
    rb.lcd_update()
end

--Draws the application menu and handles its logic
function app_menu()
    local options = {"Add New Weight", "Quit"}
    local item = rb.do_menu("Weight Tracker Menu", options, nil, false)

    if item == 0 then --Add New Weight
    elseif item == 1 then --Quit
        os.exit()
    end
end


function start()
    require("actions")

    safe_exit_action = rb.actions.ACTION_KBD_LEFT

    repeat
        local action = rb.get_action(rb.contexts.CONTEXT_KEYBOARD, -1)
        if action == rb.actions.ACTION_KBD_ABORT then
            app_menu()
        end
    until action == safe_exit_action
    rb.splash(1, "Exiting...")
end


--start()
--draw_chart()
--load_file(SAVE_FILE)
--save_weight(SAVE_FILE, weight)
