# monethook

Source: `lib/monethook.lua`.

## Requirement

`assert(MONET_VERSION ~= nil and MONET_VERSION >= 2008000, ...)` — MonetLoader 2.8.0+.

## API

`local hook = require 'monethook'`

`hook.new(cast, callback, hook_addr)`:
- `cast` — FFI cast string describing the function signature (e.g. `"int(*)(void*)"`).
- `callback` — Lua function called in place of the original; receives the original arguments; return value replaces the original's.
- `hook_addr` — address to hook.
- Returns a hook object with:
  - `.start()` / `.stop()` — enable/disable.
  - `.call(...)` — call the original function (tramp).
  - status field `.status` (boolean).
- The hook is auto-started on creation and auto-stopped on script terminate (registered via `onScriptTerminate`).

## Mechanics

- Uses `ffi.load('monetloader')` exports `monethook_hook_enable` / `monethook_hook_disable`.
- The callback is wrapped in `pcall`; on error it disables the hook and re-invokes the original, reporting via a thread that calls `error()` on the next frame.
- `jit.off(callback, true)` is applied to the wrapper (per BlastHack note).
- Each hook is tracked in `hook.hooks` for cleanup.

## Gotchas

- `hook_addr` must be a valid, writable code address; hooking the wrong address crashes the game.
- The callback runs on the thread that triggered the hook (often the render thread); do not call `wait()` or blocking JNI.
- Return the original's result when you do not intend to change behavior; otherwise game state corrupts.
- One hook per address; stacking hooks requires chaining via `.call`.
- Do not GC the hook object while installed; keep a reference.
