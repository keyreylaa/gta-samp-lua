# Platform differences

Source: `lib/moonloader.lua`, `lib/monetloader.lua`, `lib/android.lua`, `lib/memory.lua`, `lib/monethook.lua`, `ScreenRecorder.lua`, AGENTS.md.

## MoonLoader (PC)

- Lua 5.1/5.2 via LuaJIT; FFI available.
- `ffi.load("GTASA")` works; memory patching works; SAMemory works.
- GUI via mimgui binding to `monetloader` DLL (same binding name, PC build).
- SAMPFUNCS plugin provides sampfuncs constants and RPC ids.
- Commands: `addCommand(name, cb, desc)` (MoonLoader style).

## MonetLoader (Android)

- `MONET_VERSION` global present; check `>= 2008000` for monethook.
- `monetloader.lua` exposes `touch_events.POP/PUSH/MOVE`.
- `android` module provides JNI; `.dex` loading via Activity classloader.
- Memory patching may be restricted (execmod); `mprotect` fallback.
- SAMemory symbols (PC mangled names) do not apply.
- Commands: `sampRegisterChatCommand`.
- GUI: mimgui binding to `monetloader` (Android build); `imgui.OnFrame`/`OnDrawFrame` both possible.

## .dex modules (Java)

- Run on the Android runtime, not Lua. Loaded by MonetLoader via DexClassLoader.
- Used for APIs Lua cannot reach (MediaProjection, MediaRecorder, Activity result).
- Lua polls status from Java; Java calls back via JNI/env.
- Thread rules: capture on a dedicated thread; UI work on the main looper.

## Shared code

- Pure Lua (json, md5, vector3d, copas, socket, requests) is platform-independent.
- Anything touching `ffi`, `memory`, `SAMemory`, `monethook`, `android`, or `.dex` is platform-specific; guard with `MONET_VERSION` / `ffi` availability.
- `ScreenRecorder.lua` pattern: `local MONET_OK = (MONET_VERSION ~= nil)` and branch.

## Gotchas

- Do not assume `ffi` is available on every MonetLoader build; `tryRequire` and degrade.
- `getWorkingDirectory()` differs (PC vs Android media path).
- Touch input on Android: set `imgui.Process = false` when no window is interactive.
- File paths: use `/sdcard/...` on Android; relative paths resolve to the script working dir.
