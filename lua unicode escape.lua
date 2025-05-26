-- decode.lua
local input = io.open("input.txt", "r"):read("*a")

-- Function to decode all Lua string literals
local function decode_strings(str)
    return str:gsub("([\"'])(.-)%1", function(q, content)
        local try = "return " .. q .. content .. q
        local ok, result = pcall(load(try))
        if ok and type(result) == "string" then
            -- only return if printable
            local printable = result:gsub("[%c\128-\255]", "")
            if #printable / #result > 0.9 then
                return q .. result .. q
            end
        end
        return q .. content .. q -- unchanged
    end)
end

local output = decode_strings(input)
io.open("output.txt", "w"):write(output)
print("[+] Decoded to output.txt")
