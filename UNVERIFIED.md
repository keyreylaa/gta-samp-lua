# UNVERIFIED.md — items not verifiable from lib/ or official docs

These are intentionally excluded or flagged. Verify manually before relying on them.

## Runtime globals (MoonLoader/MonetLoader, not in lib/)

- `main`, `wait`, `addEventHandler`, `script.this`, `thisScript`, `getMoonloaderVersion`, `isSampLoaded`, `isSampfuncsLoaded`, `isCleoLoaded`, `reloadScripts`, `getWorkingDirectory`, `sampAddChatMessage`, `sampRegisterChatCommand`, `sampUnregisterChatCommand`, `addCommand`, `getGameGlobal`, `setGameGlobal`, `isKeyDown`, `showCursor`, `lockPlayerControl`, `isGamePaused`, `gameClock`, `consumeWindowMessage`, `encodeJson`, `decodeJson`, `import`, `script_properties`, `script_url`, `representFloatAsInt`. These are documented by the MoonLoader wiki (Russian) at https://wiki.blast.hk/moonloader/scripting-api and by project AGENTS.md. Signatures here are from wiki/usage, not from a source file in this workspace. Verify against the installed loader version.

## MoonLoader event signatures

- `onExitScript(quitGame)`, `onQuitGame`, `onScriptLoad`, `onSystemInitialized`, `onScriptMessage`, `onSystemMessage`, `onTouch`. Names come from project AGENTS.md. Parameter shapes are not verified against source; check the wiki.

## mimgui exact signatures

- `lib/mimgui/imgui.lua` is an auto-generated binding (1950+ lines). Function names drop the `ig` prefix and keep ImGui's C signature, but exact parameter order/types must be read from that file. The skill describes patterns, not full signatures. Verify against `lib/mimgui/imgui.lua` or `lib/mimgui/cdefs.lua` for any function used.

## inicfg / jsoncfg / requests exact API

- These modules exist in `lib/` but their exact function names were not exhaustively audited. Inspect the file before calling. `ScreenRecorder.lua` uses `inicfg` for settings; copy its usage pattern.

## SAMPFUNCS function availability

- `sampfuncs.lua` only defines constants. Functions like `sampAddChatMessage`, `raknetBitStream*`, `sampRegisterChatCommand` come from the SAMPFUNCS plugin and vary by build/version. Guard every call with `type(...) == "function"`.

## Font API

- Dear ImGui font functions (`AddFontFromFileTTF`, `ImFontGlyphRangesBuilder`, merge mode) are exposed through the binding but their exact Lua-side parameter forms must be checked in `lib/mimgui/imgui.lua`/`cdefs.lua`. The skill describes the ImGui model, not verified Lua signatures.

## MoonMonet

- `lib/MoonMonet/init.lua` and the `.so` were not audited line-by-line for function names. Inspect before use.

## SAMemory on Android

- SAMemory targets the PC GTASA binary with mangled symbol names. Its applicability to MonetLoader/Android is not verified; treat as PC-only.

## Memory protection on Android

- `memory.unprotect` may fail on Android (execmod restrictions). The fallback to READWRITE is implemented, but write success is not guaranteed on all devices.
