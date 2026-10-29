-- examples/sync.lua
-- Verified pattern: mutate outgoing player sync via pointer.
require 'samp.events'

function onSendPlayerSync(data)
    -- data is a PlayerSyncData* (ffi pointer). Mutate fields directly.
    data.health = 100
    data.armor = 100
    -- return false to cancel the sync; return nothing to pass through
    -- (in-place mutation is already applied to the bitstream).
end

function main()
    while true do wait(0) end
end
