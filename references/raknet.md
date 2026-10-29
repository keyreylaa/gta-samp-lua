# RakNet

Source: `lib/samp/raknet.lua`, `lib/samp/events/core.lua`, `lib/samp/events/bitstream_io.lua`, `lib/samp/events/utils.lua`, `lib/samp/events/handlers.lua`, `lib/samp/events.lua`.

## Hooking

`lib/samp/events.lua` registers SA-MP events by mapping RPC/packet IDs to handler functions. To react to an event, define the global function named in `lib/samp/events.lua` (e.g. `onServerMessage`, `onSendChat`, `onPlayerSync`). Signature is defined by the mapping in that file.

General outgoing/incoming hooks (lower level) are registered by `lib/samp/events/core.lua`:

- `addEventHandler('onSendRpc', fn)` — fn(id, bitStream, priority, reliability, orderingChannel, shiftTs)
- `addEventHandler('onSendPacket', fn)` — fn(id, bitStream, priority, reliability, orderingChannel)
- `addEventHandler('onReceiveRpc', fn)` — fn(id, bitStream)
- `addEventHandler('onReceivePacket', fn)` — fn(id, bitStream)

Return values:
- Return `false` from a handler to consume the packet/RPC (do not send/receive).
- Return a table to rewrite fields (outgoing only; see `process_event` in `core.lua`).
- Return `nil`/nothing to pass through unchanged.

## Bitstream I/O

Types in `lib/samp/events/bitstream_io.lua` (each has `.read(bs)` and `.write(bs, value)`):

bool, uint8, uint16, uint32, int8, int16, int32, float, string8, string16, string32, bool8, bool32, int1, fixedString32, string256 (= fixedString32), encodedString2048, encodedString4096, compressedFloat, compressedVector, normQuat, vector3d, vector2d.

Shortcuts: `bsread = bs_io.bs_read`, `bswrite = bs_io.bs_write` (metatables that index `.type`).

Raw helpers (from SAMPFUNCS, used in handlers): `raknetBitStreamReadBuffer`, `raknetBitStreamWriteBuffer`, `raknetBitStreamIgnoreBits`, `raknetBitStreamSetWriteOffset`, `raknetBitStreamGetNumberOfUnreadBits`, `raknetBitStreamGetNumberOfBytesUsed`, `raknetBitStreamGetDataPtr`, `raknetBitStreamDecodeString`, `raknetBitStreamEncodeString`.

## Reading/writing sync data

- `utils.create_sync_data(st)` — `ffi.new(st)` where st is a struct name from `samp.synchronization` (e.g. `'PlayerSyncData'`).
- `utils.read_sync_data(bs, st)` — reads a whole struct from the bitstream.
- `utils.write_sync_data(bs, st, ffiobj)` — writes a whole struct.
- `utils.process_outcoming_sync_data(bs, st)` — returns `{ffi.cast(st..'*', dataPtr)}`; use in outgoing sync handlers to get a mutable pointer.
- `utils.decompress_health_and_armor(hpAp)` / `utils.compress_health_and_armor(health, armor)`.

## Constants

- `raknet.RPC.*` and `raknet.PACKET.*` (from `lib/samp/raknet.lua`).
- Priority/reliability constants from `lib/sampfuncs.lua`: `SYSTEM_PRIORITY`, `HIGH_PRIORITY`, `MEDIUM_PRIORITY`, `LOW_PRIORITY`; `UNRELIABLE`, `UNRELIABLE_SEQUENCED`, `RELIABLE`, `RELIABLE_ORDERED`, `RELIABLE_SEQUENCED`.

## Gotchas

- Outgoing sync handler receives the struct pointer directly (e.g. `PlayerSyncData*`); mutate `data.field` in place. Returning `false` cancels the sync.
- Do not reassign the pointer; the bitstream reads from the same memory.
- Returning `false` consumes the packet; returning a table rewrites it; returning nothing passes through.
- Custom reader/writer pairs (e.g. `onSendGiveDamage`) receive positional arrays, not named fields.
- `vector3d` from `lib/vector3d.lua` is required by bitstream_io; do not substitute a plain table.
- Out-of-range bit reads crash; check `raknetBitStreamGetNumberOfUnreadBits` first (see `rpc_create_object_reader`).
