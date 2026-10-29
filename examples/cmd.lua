-- examples/cmd.lua
-- Verified pattern: register command with MonetLoader/MoonLoader fallback.
local function handler(param)
    local args = {}
    for token in tostring(param or ""):gmatch("%S+") do
        args[#args + 1] = token
    end
    print("args:", #args)
end

local registered = false
if type(sampRegisterChatCommand) == "function" then
    local ok = pcall(sampRegisterChatCommand, "mycmd", handler)
    if ok then registered = true end
end
if not registered and type(addCommand) == "function" then
    pcall(addCommand, "mycmd", handler, "example command")
    registered = true
end

function main()
    while true do wait(0) end
end
