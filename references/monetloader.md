# MonetLoader runtime (Android, 64-bit)

Verified against the loader sources of this client (`cpp/script/script_manager.cpp`,
`cpp/script/luafuncs.cpp`, `dist/lib/mimgui/init.lua`) and against the device logs.

## Globals the loader sets

| Global | Meaning |
|---|---|
| `MONET_VERSION` | version index of the loader (`PROJECT_VERSION_INDEX`) |
| `MONET_DPI_SCALE` | display density / 200, never below 1 (1.346 on a 269 dpi phone) |
| `MONET_GTASA_BASE` | runtime base of `libGTASA.so` |
| `PLAYER_PED`, `PLAYER_HANDLE` | handle of the player's ped, read when the script's state is created |
| `script.this`, `thisScript` | the running script (`thisScript()` is the function form) |

## Screen density without MONET_DPI_SCALE

`MONET_DPI_SCALE` is optional: a script that has to run on a loader that does not set it
should compute its own scale. The resolution is the only other source:

```lua
local function uiScale()
    if MONET_DPI_SCALE then return MONET_DPI_SCALE end
    local ok, w, h = pcall(getScreenResolution)
    if ok and h and h > 0 then return math.max(1.0, h / 720) end
    return 1.0
end
local S = uiScale()
```

Size the widgets with it (`imgui.ImVec2(200 * S, 120 * S)`, font sizes, line widths). The
resolution is also what decides how much of the world is on screen: a 720p phone and a
1440p phone do not share pixel sizes.

## Scripts start before the game exists

The loader starts the script manager from the game loop, which runs while the game still
loads: the loading screen is the first thing a script sees. During that phase

- the ped pool and the vehicle pool are not created yet,
- `getCharPointer()` answers 0 instead of crashing (the loader hands out an empty pool),
- `PLAYER_PED` holds the handle of the moment the state was made, so it is 0 while loading.

Guard every read:

```lua
local function playerPed()
    return getCharPointer(getPlayerChar(0))   -- asked for at every read
end

imgui.OnFrame(function() return true end, function()
    local ped = playerPed()
    if ped == 0 then return end
    ...
end)
```

`getCharPointer(PLAYER_PED)` is a snapshot taken at load; use `getPlayerChar(0)` when the
value has to be current.

## 64-bit and 32-bit are different builds

The two builds of `libGTASA.so` have different segment layouts and different sizes for the
same structures. A hardcoded offset from a 32-bit build can land on a read-only page, and a
write there is a SIGSEGV instead of a Lua error.

- Resolve a symbol by **name**, not by number:

```lua
local ffi  = require 'ffi'
local gta  = ffi.load('GTASA')
ffi.cdef[[ float AIMWEAPON_STICK_SENS(void); ]]
local address = tonumber(ffi.cast('uintptr_t', ffi.cast('void*', gta.AIMWEAPON_STICK_SENS)))
```

- The base of the module at runtime is `MONET_GTASA_BASE`; an offset is `base + offset`.
- `ffi.C` with `RTLD_DEFAULT` does not find the symbols of the game on Android (linker
  namespace): use the handle from `ffi.load('GTASA')`.
- Structure sizes and strides differ: `CMatrix` (plugin-sdk) has a 16-byte stride between
  vectors, `RwMatrix` has 12. Casting one to the other corrupts the vectors.
- A pointer to a streamed-out entity is null: `m_pRwObject` / `m_pRwClump` sits at `0x20` in
  `CEntityGTA` on the 64-bit build. Check it before calling a game function that touches it.
- The offsets of the 64-bit build can be dumped from the device (`dump-gtasa-offsets.lua`
  in the test scripts); do not mix them with a 32-bit table.

## Handle or pointer

The script commands take a **handle** (the id of the game), the structures of the game take a
**pointer**. The two are not interchangeable:

```lua
local handle = getPlayerChar(0)        -- handle of the player's ped
local health = getCharHealth(handle)   -- opcode: handle
local ped    = getCharPointer(handle)  -- pointer: ffi, structures, matrices
```

- `getCharHealth`, `getCharArmour`, `getCharCoordinates`, `isCharInVehicle`,
  `isCharSitting` and the other commands of `opcodes.cpp` want a handle.
- `getCharPointer`, `getCharPointerHandle`, and every `ffi` read want a pointer.
- A pointer is not a handle: passing one to an opcode reads a slot that does not exist and
  answers 0 (or worse). A handle is not a pointer: passing one to `ffi` reads the pool slot.

## SAMP availability and threads

- `isSampAvailable()` is true once the RakNet hooks are in place; `samp*` calls before that
  are meaningless.
- RakNet is not thread safe: a packet is sent from the game thread, never from a JNI or UI
  callback. A script callback runs on the game thread, so sending from an event handler is
  fine; sending from a Java call is not.

## Logs

- loader log: `Android/media/<pkg>/monetloader/logs/monetloader.log` (`print` goes there)
- client log: `Android/data/<pkg>/files/samp_log.txt`
- `FLog` flushes on every call: never call it per frame or per bullet.

## Gotchas

- `getCharPointer` is safe, but the pool behind it is not: a lookup on a pool that the game
  has not made yet answers 0, so always check the result.
- `m_pRwClump` may be null on a ped that is not streamed; a game function that touches it
  crashes.
- `inicfg` writes sections only: a value at the top of the config table makes
  `inicfg.save` assert. Put every value in a section.