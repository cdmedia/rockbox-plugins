-- Most if not all the functions listed in plugins.h will work in a LUA program, take note that some of the functions are dedicated to certain ports
-- only. Here's an example script of playing an MP3 file in a LUA program(This will work only on ports with software decoding, unlike the
-- Archos port with a dedicated DSP chip):

-- Helper function which reads the contents of a file(This function is from the helloworld.lua example above)
function file_get_contents(filename)
    local file = io.open(filename, "r")
    if not file then
        return nil
    end

    local contents = file:read("*all") -- See Lua manual for more information
    file:close() -- GC takes care of this if you would've forgotten it

    return contents
end

rb.lcd_clear_display()
file_put_contents("/temp.m3u8","/test.mp3")
rb.playlist_create("/","temp.m3u8")
rb.playlist_start(0,0)
rb.sleep(3 * rb.HZ)
repeat
    BtnInput = rb.get_action(rb.contexts.CONTEXT_STD, rb.HZ)
until BtnInput == rb.actions.ACTION_STD_OK

-- This takes advantage of the playlist functions and plays the mp3 in the background, by writing a temporary playlist file and then playing the playlist.
-- You can rewrite the playlist file over an over just by including the path/file-name of the song file in the playlist and then loading and starting the playlist.
