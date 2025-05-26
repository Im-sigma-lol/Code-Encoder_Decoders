local input = io.open("input.txt", "r"):read("*a")

local function decode_and_format_string(str)
    local f = load("return " .. str)
    if not f then return str end
    local ok, decoded = pcall(f)
    if not ok or type(decoded) ~= "string" then return str end

    -- if it's multiline, convert to [[...]] block string
    if decoded:find("\n") then
        return "[[\n" .. decoded .. "\n]]"
    else
        return ("%q"):format(decoded)
    end
end

-- Only decode Body = "..."
local output = input:gsub('(Body%s*=%s*)"([^"]-)"', function(prefix, content)
    local raw = '"' .. content .. '"'
    local formatted = decode_and_format_string(raw)
    return prefix .. formatted
end)

io.open("output.txt", "w"):write(output)

print("[+] Reformatted Body strings into readable form.")
