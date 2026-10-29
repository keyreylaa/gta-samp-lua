# Sync

Source: `lib/samp/synchronization.lua`, `lib/samp/events.lua`, `lib/samp/events/utils.lua`, `lib/samp/events/handlers.lua`.

## Structs

Defined in `lib/samp/synchronization.lua` via FFI cdef (packed, `#pragma pack(push,1)`):

- `PlayerSyncData` (68 bytes)
- `VehicleSyncData` (63 bytes)
- `PassengerSyncData` (24 bytes)
- `UnoccupiedSyncData` (67 bytes)
- `TrailerSyncData` (54 bytes)
- `SpectatorSyncData` (18 bytes)
- `BulletSyncData` (40 bytes)
- `AimSyncData` (31 bytes)
- `VectorXYZ` (12 bytes), `SampKeys` (2 bytes).

Asserted sizes in source; do not change packing.

## Key fields

PlayerSyncData: leftRightKeys, upDownKeys, keys (SampKeys union), position, quaternion[4], health, armor, weapon (6 bits), specialKey (2 bits), specialAction, moveSpeed, surfingOffsets, surfingVehicleId, animation (id/frameDelta/flags).

VehicleSyncData: vehicleId, keys, quaternion[4], position, moveSpeed, vehicleHealth, playerHealth, armor, currentWeapon, specialKey, siren, landingGearState, trailerId, bikeLean/trainSpeed/hydraThrustAngle union.

SampKeys bitfields: primaryFire, horn_crouch, secondaryFire_shoot, accel_zoomOut, enterExitCar, decel_jump, circleRight, aim, circleLeft, landingGear_lookback, unknown_walkSlow, specialCtrlUp/Down/Left/Right, _unknown.

## Outgoing sync handlers

From `lib/samp/events.lua`:

- `onSendPlayerSync(data)` where `data` is a `PlayerSyncData*` (ffi pointer) — mutate `data.field`
- `onSendVehicleSync`, `onSendPassengerSync`, `onSendAimSync`, `onSendUnoccupiedSync`, `onSendTrailerSync`, `onSendBulletSync`, `onSendSpectatorSync`

Pattern:

```lua
function onSendPlayerSync(data)
    -- data is a PlayerSyncData* (ffi pointer)
    data.health = 100
    -- return false to cancel; otherwise the in-place mutation is sent
end

```

## Incoming sync handlers

- `onPlayerSync(playerId, data)`, `onVehicleSync(playerId, vehicleId, data)`, `onPassengerSync(...)`, `onAimSync(playerId, data)`, `onBulletSync(playerId, data)`, `onUnoccupiedSync(playerId, data)`, `onTrailerSync(playerId, data)`, `onMarkersSync(markers)`.

Incoming data is a Lua table (see `packet_player_sync_reader`); mutate fields and return the table to rewrite, or `false` to consume.

## Gotchas

- Outgoing sync data is a pointer wrapped in a table; index `[1][0]` before mutating.
- health/armor on the wire are compressed (7-step); use `utils.decompress_health_and_armor` / `compress_health_and_armor` when reading/writing the compressed byte manually.
- Do not modify sync structs outside a handler; the pointer is only valid during the call.
- Timing: sync sendrates are controlled by the server (`normalOnfootSendrate` etc.); do not spam.
- Returning `false` cancels the sync entirely (player may rubber-band).
