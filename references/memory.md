# Memory

Source: `lib/memory.lua`, `lib/SAMemory/init.lua`, `lib/SAMemory/shared.lua`, `lib/SAMemory/metatype.lua`.

## lib/memory.lua (virtual memory I/O)

Module returns `memory`. Functions accept numeric addresses.

- `memory.read(address, size, unprot)` — reads up to 8 bytes; returns number (<=4 bytes) or int64.
- `memory.write(address, value, size, unprot)`.
- `memory.unprotect(address, size)`, `memory.protect(address, size, prot)`.
- `memory.copy(dst, src, size, unprot)`, `memory.fill(address, value, size, unprot)`.
- `memory.tostring(address, size, unprot)`, `memory.tohex(data, size, unprot)`, `memory.hex2bin(hex, dst, size)`.
- `memory.compare(m1, m2, size)`, `memory.strptr(str)`.
- Typed getters/setters: `getint8/16/32/64`, `getuint8/16/32/64`, `getfloat`, `getdouble`, and `set*` variants, each with `(address, unprot)` (setters take value).
- `memory.getvalue(ctype, address, unprot)`, `memory.setvalue(ctype, address, value, unprot)`.
- `memory.pageaccess` table: `NOACCESS/READONLY/READWRITE/EXECUTE/EXECUTE_READ/EXECUTE_READWRITE`.

`unprot=true` calls `mprotect` to make the page writable; on Android/Linux execmod may be denied, falling back to READWRITE.

## SAMemory

- `local sa = require 'SAMemory'` returns a table with `cast`, `require`, `code_pause`, `user_pause`, `nullptr`, `camera`, `crosshairs`, `player_ped`, `player_vehicle`, and pools (`ped_pool`, `vehicle_pool`, `object_pool`, `building_pool`, `dummy_pool`, `colModelPool`, `task_pool`, `pedIntelligencePool`, `ptrNodeSinglePool`, `ptrNodeDoublePool`).
- `shared = require 'SAMemory.shared'`; `shared.gta = ffi.load("GTASA")` (PC). `shared.require(name)` loads a structure module from `lib/SAMemory/game/`.
- `ffi.cdef` for `CTimer::m_UserPause/m_CodePause`, `TheCamera`, pools, etc. is in `init.lua`.
- Structure modules under `lib/SAMemory/game/` define metatypes for `CPed`, `CVehicle`, `CPlayerPed`, `CCamera`, etc. Use `shared.require 'CPed'` before casting.

## The 64-bit Android build

`memory.*` works on the 64-bit build as well, but the addresses are not the ones of the PC
build and not the ones of a 32-bit build. See `references/monetloader.md`.

- Resolve a global by name through the FFI handle of the game:

```lua
local ffi = require 'ffi'
local gta = ffi.load('GTASA')
ffi.cdef[[ float AIMWEAPON_STICK_SENS(void); ]]
local address = tonumber(ffi.cast('uintptr_t', ffi.cast('void*', gta.AIMWEAPON_STICK_SENS)))
memory.setfloat(address, 0.02)   -- the symbol is in a writable page
```

- `memory.setfloat` on an address that belongs to a read-only page is a SIGSEGV, not a Lua
  error. The 32-bit offset of the same symbol points into code on the 64-bit build.
- `MONET_GTASA_BASE` is the runtime base; an offset is `base + offset`.
- `CPools::GetPedPool()` may be null while the game loads; the loader answers 0 instead of
  crashing, but a script must still check the result.

## Gotchas

- SAMemory targets the PC GTASA binary (mangled symbol names `_ZN...`). On MonetLoader/Android the addresses and symbols differ; treat as PC-only.
- `memory.read` caps size at 8 bytes; for larger blocks use `memory.tostring`/`memory.copy`.
- `unprotect` may fail silently on Android (no exec permission); check return.
- Pools are `CPool**`; dereference with `*pool` before indexing.
- Do not write to code pages without restoring protection; use `protect` after.
