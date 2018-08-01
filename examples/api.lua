--The plugin API and some Rockbox C functions are directly exposed in the rb table. Have a look at the source code for more info (like plugin.h and others).
--To generate a /rb.txt file containing the keys of the rb object, you can run this code:

rb_obj = {}
for k, v in pairs(rb) do
    local the_type = type(v)..'s'
    if not rb_obj[the_type] then
        rb_obj[the_type] = {}
        end
    table.insert(rb_obj[the_type], k)
    end

local list = {}
for rb_type, rb_table in pairs(rb_obj) do
    table.insert(list, string.format('* %s *', rb_type))
    table.sort(rb_table)
    for _, v in ipairs(rb_table) do
        table.insert(list, v)
        end
    -- jump a line
    table.insert(list, '')
    end
local file = io.open('/rb.txt', "w+")
file:write(table.concat(list, '\n'))
file:close()
