#!/usr/bin/env lua

-- lua asd1.lua
-- or ./asd1.lua

-- comments
-- arrays start indexing at 1 ...

-- utils
function read_entire_file(file_name)
    local f = io.open(file_name,"rb")
    if f == nil then print("Could not open file for reading file_name: `"..file_name.."`") return "" end
    local content = f:read("*all")
    f:close()
    return content
end

function count_new_lines(str)
    local i = 0
    local n = 1
    while true do
        i = str:find('\n',i+1)
        if i == nil then return n end
        n = n + 1
    end
end

-- interesting
-- define the indexing operator str[i] for strings
-- getmetatable('').__index = function(str,i) return string.sub(str,i,i) end

LEFT =0
UP   =1
RIGHT=2
DOWN =3

function start_and_dir(start_idx, map_bytes, W)
    local x = start_idx%W
    local y = (start_idx//W) + 1
    if map_bytes[x+y*W] == string.byte('|') or
       map_bytes[x+y*W] == string.byte('J') or
       map_bytes[x+y*W] == string.byte('L') then
        return (x+y*W),UP
    end
    

    x = start_idx%W
    y = (start_idx//W) - 1
    if map_bytes[x+y*W] == string.byte('|') or
       map_bytes[x+y*W] == string.byte('F') or
       map_bytes[x+y*W] == string.byte('7') then
        return (x+y*W),DOWN
    end

    x = start_idx%W+1
    y = (start_idx//W)
    if map_bytes[x+y*W] == string.byte('-') or
       map_bytes[x+y*W] == string.byte('J') or
       map_bytes[x+y*W] == string.byte('7') then
        return (x+y*W),LEFT
    end

    x = start_idx%W -1
    y = (start_idx//W)
    if map_bytes[x+y*W] == string.byte('-') or
       map_bytes[x+y*W] == string.byte('F') or
       map_bytes[x+y*W] == string.byte('L') then
        return (x+y*W),RIGHT
    end

    print("Could not find starting direction at ", start_idx, "x:", x, "y:", y-dir)
    return nil,nil
end

function traverse(start_idx, map_bytes, W,H,L)
    local ftable = {
        -- dir = left 0 up 1 right 2 down 3 : which direction we ended up here
        -- | is a vertical pipe connecting north and south.
        [string.byte('|')]= 
        function (x,y,dir) 
            if dir==UP   then return x,y+1,UP
        elseif dir==DOWN then return x,y-1,DOWN
        else return nil,nil,nil end
        end
        ,
        -- - is a horizontal pipe connecting east and west.
        [string.byte('-')]= 
        function (x,y,dir) 
            if dir==LEFT  then return x+1,y,LEFT
        elseif dir==RIGHT then return x-1,y,RIGHT
        else return nil,nil,nil end
        end
        ,
        -- L is a 90-degree bend connecting north and east.
        [string.byte('L')]= 
        function (x,y,dir) 
            if dir==UP    then return x+1,y,LEFT
        elseif dir==RIGHT then return x,y-1,DOWN
        else return nil,nil,nil end
        end
        ,
        -- J is a 90-degree bend connecting north and west.
        [string.byte('J')]= 
        function (x,y,dir) 
            if dir==UP   then return x-1,y,RIGHT
        elseif dir==LEFT then return x,y-1,DOWN
        else return nil,nil,nil end
        end
        ,
        -- 7 is a 90-degree bend connecting south and west.
        [string.byte('7')]= 
        function (x,y,dir) 
            if dir==LEFT then return x,y+1,UP
        elseif dir==DOWN then return x-1,y,RIGHT
        else return nil,nil,nil end
        end
        ,
        -- F is a 90-degree bend connecting south and east.
        [string.byte('F')]= 
        function (x,y,dir) 
            if dir==RIGHT then return x,y+1,UP
        elseif dir==DOWN  then return x+1,y,LEFT
        else return nil,nil,nil end
        end
        ,
        -- . is ground; there is no pipe in this tile.
        [string.byte('.')]= 
        function (x,y,dir) 
            -- if we end up here something went wrong
            print("Got to dead end at ", idx, "x:", x, "y:", y, "dir:", dir)
            return nil,nil,nil
        end
        ,
        -- S is the starting position of the animal; there is a pipe on this tile, but your sketch doesn't show what shape the pipe has.
        [string.byte('S')]= 
        function (x,y,dir) 
            -- found start again
            print("Got to start at ","x:", x, "y:", y, "dir:", dir)
            return nil,nil,nil
        end
    }

    local loop_len = 0
    local idx,dir = start_and_dir(start_idx, map_bytes, W)


    repeat 
        local x = idx  % W
        local y = (idx//W)
        loop_len = loop_len + 1

        x,y, dir = ftable[map_bytes[idx]](x,y,dir)
        if x == nil then print("dead end at idx", idx, "char:",string.char(map_bytes[idx])) end
        
        idx = (x+y*W)

        --print("idx:",idx,"x:",x,"y:",y,"dir:",dir,"char:",string.char(map_bytes[idx]))
    until( idx == start_idx )
    print("loop len:",loop_len," longest spot",math.ceil(loop_len/2))
end

-------------------------------------
-- main
fname = "input"
print("file name: `" .. fname .."`")


map = read_entire_file(fname)
W = map:find('\n')
H = count_new_lines(map)
L = map:len()--string.len(map)
-- string to array of bytes
map_bytes = {string.byte(map,1,-1)}

start_idx = map:find('S')
print("start idx: ", start_idx, " x: ", start_idx%W, " y: ", start_idx//W ) --> // floor division operator


traverse(start_idx, map_bytes, W,H,L)









