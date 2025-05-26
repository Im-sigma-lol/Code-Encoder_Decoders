-- decode_lua_strings.lua

local function is_printable(s)
  local count = 0
  for i = 1, #s do
    local byte = s:byte(i)
    if byte >= 32 and byte <= 126 or byte == 10 or byte == 13 then
      count = count + 1
    end
  end
  return count / #s >= 0.9
end

local function decode_string(s)
  local f, err = load("return " .. s)
  if not f then return s end
  local ok, result = pcall(f)
  if not ok or type(result) ~= "string" then return s end
  if not is_printable(result) then return s end
  return string.format("%q", result) -- returns it re-escaped and quoted
end

-- Read full input
local input = io.open("input.txt", "r"):read("*a")

-- Replace quoted strings
local output = input:gsub("([\"'])(.-)(%1)", function(q, content, endq)
  local raw = q .. content .. endq
  local decoded = decode_string(raw)
  return decoded or raw
end)

-- Write to output
local out = io.open("output.txt", "w")
out:write(output)
out:close()

print("[+] Decoded strings written to output.txt")
