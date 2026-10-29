-- examples/lifecycle.lua
-- Verified pattern: keep main() alive, register cleanup.
local function main()
    print("hello")
    addEventHandler('onScriptTerminate', function(scr)
        if scr == script.this then
            print("terminating")
        end
    end)
    while true do
        wait(0)
    end
end
