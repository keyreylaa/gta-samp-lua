# Lifecycle

Source: `ScreenRecorder.lua` (usage), `lib/moonloader.lua`, `lib/monetloader.lua`, `lib/samp/events/core.lua`, `lib/samp/events.lua`, AGENTS.md of this project, MoonLoader wiki (Russian) at https://wiki.blast.hk/moonloader/scripting-api.

## Entry point

- `function main()` is the script entry. MoonLoader calls it once at load.
- If the script registers events but `main()` returns, MoonLoader terminates the script. Keep `main()` alive with `while true do wait(0) end` or end with `wait(-1)`.
- `wait(ms)` suspends only the calling thread, not the game. Valid inside `main()` and nested calls and scripting threads.

## Threading

- `lua_thread.create(function)` (used in `lib/monethook.lua`) spawns a thread that can call `wait()`.
- Delays are not allowed directly inside event callbacks; use a scripting thread if you need `wait()` in a handler.

## Events

MoonLoader runtime events (global registration via `addEventHandler(name, fn)` or a global function `onXxx`):

- `onScriptTerminate(scr)` — `scr == script.this` means this script is terminating. Use to release hooks/resources.
- `onExitScript(quitGame)`, `onQuitGame`, `onScriptLoad`, `onSystemInitialized`, `onScriptMessage`, `onSystemMessage` — listed in project AGENTS.md; verify against MoonLoader wiki before relying on signatures.
- `onReceivePacket`, `onReceiveRpc`, `onSendPacket`, `onSendRpc` — used by `lib/samp/events/core.lua`.
- `onTouch` — MonetLoader touch events (see `lib/monetloader.lua`: `touch_events.POP/PUSH/MOVE`).

SA-MP events registered by `lib/samp/events.lua` are listed in `references/samp-events.md`.

## Registration helpers

- `addEventHandler(eventName, callback)` — MoonLoader global.
- `script.this` — handle of the current script (used in `lib/monethook.lua` cleanup).
- `getMoonloaderVersion()` — returns number; `lib/samp/events/core.lua` requires `>= 20`.
- `isSampLoaded()`, `isSampfuncsLoaded()`, `isCleoLoaded()` — booleans from SAMPFUNCS.
- `reloadScripts()` — reload all scripts.
- `thisScript()` — returns the LuaScript object (per MoonLoader wiki).

## Cleanup

Pattern from `lib/monethook.lua`: register `onScriptTerminate` and stop hooks / release resources when `scr == script.this`.

```lua
addEventHandler('onScriptTerminate', function(scr)
    if scr == script.this then
        -- release
    end
end)
```

## Reload and unload

- Scripts in the MonetLoader folder are loaded at game start and on script reload.
- `wait(-1)` keeps a script alive without a busy loop.

## Gotchas

- A script with events but no `main()` (or no `wait(-1)`) is terminated by MoonLoader.
- `wait()` outside `main()`/thread context errors.
- `require` paths use the `lib/` tree; module names map to file paths (`require 'samp.events'` -> `lib/samp/events.lua`).
