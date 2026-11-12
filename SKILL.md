---
name: gta-samp-lua
description: Write Lua scripts for GTA: San Andreas SA-MP on MoonLoader, MonetLoader (Android, 32-bit and 64-bit libGTASA), and .dex modules. Use when the user asks to write, fix, or review a MoonLoader/MonetLoader script, SA-MP hook, RakNet packet/RPC handler, sync manipulation, mimgui GUI, image or font in mimgui, screen-DPI handling, chat command, or a Lua library for this stack. Covers lifecycle, GUI, images, fonts, commands, RakNet, sync, memory and offsets, platform differences, and library authoring. Trigger on keywords: MoonLoader, MonetLoader, SA-MP, samp, mimgui, RakNet, onSendRpc, onReceivePacket, onBulletSync, bullet sync, MONET_DPI_SCALE, libGTASA 64-bit, sampAddChatMessage, .dex.
---

# GTA SA-MP Lua (MoonLoader / MonetLoader / .dex)

## When to use

Use this skill when writing or modifying Lua for:
- MoonLoader scripts (PC) and MonetLoader scripts (Android, 32-bit or 64-bit game).
- SA-MP hooks: RakNet RPC/packet in/out, sync data, chat commands, dialogs.
- mimgui GUI: windows, widgets, images, fonts, glyph ranges, render loop.
- Reading or writing game memory by symbol name on the 64-bit build.
- Loading or calling Java from a `.dex` via MonetLoader's `android` module.
- Authoring a reusable `lib/`-style module.

Do not use for generic Lua unrelated to GTA SA-MP or for C/C++ plugin code.

## Core rules

1. Only use APIs verified in `lib/` or the runtime globals listed in `references/lifecycle.md`
   and `references/monetloader.md`. If an API is not verified, do not write it; check
   `UNVERIFIED.md`.
2. Every script must have `function main()` with an infinite loop or `wait(-1)` at the end,
   otherwise MoonLoader terminates it when events are registered.
3. Use `local` for everything. Do not leak globals. The one exception is constants imported
   from `sampfuncs` (they are copied to `_G` by that module itself).
4. Do not call blocking or UI-thread work from the render thread. On MonetLoader, JNI calls
   belong in a thread or behind `wait`.
5. Validate before mutating sync data. Returning `false` from an outgoing handler consumes
   the packet (see `references/raknet.md`).
6. Prefer `sampAddChatMessage` over Toast for in-game text on MonetLoader.
7. Scripts start while the game still loads: the loading screen is the first thing a script
   sees. Check every game pointer before using it (see `references/monetloader.md`).
8. An offset of one build is not an offset of the other. Resolve symbols by name; never
   hardcode a 32-bit offset in a 64-bit build (see `references/memory.md`).
9. `imgui.Text` is the variadic `igText(fmt, ...)`: a call with a format and arguments has
   taken the process down inside LuaJIT. Use `imgui.TextUnformatted` with `string.format`
   (see `references/gui.md`).
10. RakNet is not thread safe: a packet is sent from the game thread only.

## Reference map

Read only the file that matches the task. Do not load all references.

- Script entry, `main`, `wait`, events, reload, termination: `references/lifecycle.md`
- Loader globals, DPI, 32/64-bit rules, starting before the game: `references/monetloader.md`
- GUI windows, widgets, state, style, render callback: `references/gui.md`
- Images (textures) in mimgui: `references/gui.md` ("Images")
- Fonts, glyph ranges, merge, non-Latin, icon fonts: `references/fonts.md`
- Chat commands: registration, parsing, removal: `references/cmd.md`
- RakNet RPC/packet hooking, bitstream types, bullet sync: `references/raknet.md`
- Sync structs and outgoing handlers: `references/sync.md`
- SA-MP event names and payloads (from `lib/samp/events.lua`): `references/samp-events.md`
- SAMPFUNCS constants and helpers: `references/sampfuncs.md`
- Android JNI, DexClassLoader, toast/chat: `references/android.md`
- Native hooks via `monethook`: `references/monethook.md`
- Memory read/write, pools, metatypes, 64-bit offsets: `references/memory.md`
- MoonMonet Rust helper: `references/moonmonet.md`
- Config, keys, notifications, HTTP, JSON, vectors: `references/utilities.md`
- Platform differences and shared code: `references/platform.md`
- Writing your own library: `references/make-lib.md`

## Pre-write checklist

Before finalizing any script, verify:
- [ ] `main()` exists and does not return early without `wait(-1)`.
- [ ] Every `require` name matches a file in `lib/` (see `references/utilities.md` for the list).
- [ ] Every event name used is listed in `references/samp-events.md` or `references/lifecycle.md`.
- [ ] No global leaks: all locals.
- [ ] Platform guards present where code is platform-specific; no PC offset in a 64-bit script.
- [ ] Every game pointer is checked before use (the game is still loading when scripts run).
- [ ] GUI uses `imgui.OnFrame` (not `imgui.OnDrawFrame`); `TextUnformatted` for formatted text.
- [ ] Fonts are added in `imgui.OnInitialize`, textures after the renderer exists.
- [ ] The UI is scaled from `MONET_DPI_SCALE` when present, otherwise from the resolution.
- [ ] Commands registered via `sampRegisterChatCommand` or `addCommand` with a fallback.
- [ ] Packets are sent from the game thread only.

## Examples

Minimal verified patterns: `examples/`. Load only the one matching the task.