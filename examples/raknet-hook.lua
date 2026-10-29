-- examples/raknet-hook.lua
-- Verified pattern: hook an outgoing RPC. onSendChat receives the message string.
require 'samp.events'

function onSendChat(message)
    if message == "/secret" then
        return false -- consume: do not send
    end
    -- to rewrite, return a table with one element:
    -- return { message .. " (edited)" }
    return message -- pass through unchanged (nil also passes through)
end

function main()
    while true do wait(0) end
end
