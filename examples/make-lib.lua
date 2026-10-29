-- examples/make-lib.lua
-- Verified pattern: a minimal reusable module and its consumer.

-- lib/counter.lua
-- local counter = {}
-- local n = 0
-- function counter.inc() n = n + 1; return n end
-- function counter.get() return n end
-- return counter

local counter = require 'counter'

function main()
    print(counter.inc()) -- 1
    print(counter.get()) -- 1
    while true do wait(0) end
end
