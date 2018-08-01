function sayhello(seconds)
    local message = string.format("Hello from LUA for %d seconds", 5)
    rb.splash(seconds, message)
end

-- Drawn an X on the screen
rb.lcd_clear_display()
rb.lcd_drawline(0, 0, rb.LCD_WIDTH, rb.LCD_HEIGHT)
rb.lcd_drawline(rb.LCD_WIDTH, 0, 0, rb.LCD_HEIGHT)
rb.lcd_update()

local seconds = 5

rb.sleep(5 * rb.HZ)

sayhello(seconds)
