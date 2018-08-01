-- It's a good example to learn how to work with the menu API, fundamental part of almost any Rockbox plugin.
-- Example script to demonstrate the development of a simple Rockbox plugin in LUA.
-- Written by Gabriel Maia (gbl08ma on the Rockbox community).
-- Licensed under GNU GPL v2 or, at your choice, any later version.

-- Function to display the main menu of this script
function ShowMainMenu() -- we invoke this function every time we want to display the main menu of the script
    mainmenu = {"Item 1", "Item 2", "Item 3", "Exit"} -- define the items of the menu

    while true do -- don't exit of program until user selects Exit
        s = rb.do_menu("Test", mainmenu, nil, false) -- actually tell Rockbox to draw the menu

        -- In the line above: "Test" is the title of the menu, mainmenu is an array with the items
        -- of the menu, nil is a null value that needs to be there, and the last parameter is
        -- whether the theme should be drawn on the menu or not.
        -- the variable s will hold the index of the selected item on the menu.
        -- the index is zero based. This means that the first item is 0, the second one is 1, etc.
        if     s == 0 then ShowSubmenu1()
        elseif s == 1 then rb.splash(2 * rb.HZ, "You selected Item 2") --show a message for two seconds
        elseif s == 2 then rb.splash(2 * rb.HZ, "You selected Item 3")
        elseif s == 3 then os.exit() -- User selected to exit
        elseif s == -2 then os.exit() -- -2 index is returned from do_menu() when user presses the key to exit the menu (on iPods, it's the left key).
                                      -- In this case, user probably wants to exit (or go back to last menu).
        else rb.splash(2 * rb.HZ, "Error! Selected index: " .. s) -- something strange happened. The program shows this message when
                                                                  -- the selected item is not on the index from 0 to 3 (in this case), and displays
                                                                  -- the selected index. Having this type of error handling is not
                                                                  -- required, but it might be nice to have specially while you're still
                                                                  -- developing the plugin.
        end
    end
end

-- Submenu 1
function ShowSubmenu1() -- function to draw the submenu 1, which will be displayed when
                        -- user selects Item 1 on main menu
    submenu1 = {"Sub Item 1", "Sub Item 2", "Return"} -- define the items of the menu

    while true do -- don't exit of program until user selects Exit
        s1 = rb.do_menu("Item 1 menu", submenu1, nil, false)

        if     s1 == 0 then rb.splash(2 * rb.HZ, "You selected Sub Item 1") --show a message for two seconds
        elseif s1 == 1 then rb.splash(2 * rb.HZ, "You selected Sub Item 2")
        elseif s1 == 2 then ShowMainMenu() -- return to the main menu, display it again
        elseif s1 == -2 then ShowMainMenu() -- user seems to want to go back
        else rb.splash(2 * rb.HZ, "Error! Selected index: " .. s)
        end
    end
end

-- code written out of any function will be executed when the file is "played" on the file browser.
-- if you don't put anything out of a function (not even a call to the main function, like we do here),
-- the script will simply do nothing.
ShowMainMenu() -- start the program by displaying the main menu of the script.
