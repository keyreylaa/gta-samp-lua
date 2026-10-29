# Utilities

Source: files under `lib/`. List of modules verified present: ADDONS.lua, MoonMonet/, SAMemory/, android.lua, basexx.lua, binaryheap.lua, bitex.lua, cjson/, copas/, copas.lua, dkjson.lua, encoding.lua, fAwesome5/6/6_solid.lua, faIcons.lua, game/globals.lua, game/keys.lua, game/models.lua, game/weapons.lua, hotkey.lua, imgui_addons.lua, inicfg.lua, inspect.lua, jsoncfg.lua, ltn12.lua, matrix3x3.lua, md5.lua, memory.lua, mime.lua, mimgui/, mimtoasts.lua, monethook.lua, monetloader.lua, moonloader.lua, notifications.lua, requests.lua, sa_renderfix.lua, samp/, sampfuncs.lua, sandbox.lua, sha1/, socket/, socket.lua, ssl/, ssl.lua, timerwheel.lua, toast_notf.lua, vector3d.lua, vkeys.lua, widgets.lua.

## Config

- `inicfg` (`lib/inicfg.lua`): INI read/write. `ScreenRecorder.lua` uses it for settings persistence; inspect the file for exact function names (`inicfg.load`, `inicfg.save`) before use.
- `jsoncfg` (`lib/jsoncfg.lua`): JSON-backed config.
- `dkjson` / `cjson` (`lib/dkjson.lua`, `lib/cjson/`): JSON encode/decode.

## Keys and input

- `vkeys` (`lib/vkeys.lua`): virtual key constants.
- `game/keys.lua`: game key constants.
- `hotkey` (`lib/hotkey.lua`): hotkey registration.

## Notifications / toasts

- `notifications`, `mimtoasts`, `toast_notf` (`lib/notifications.lua`, `lib/mimtoasts.lua`, `lib/toast_notf.lua`).
- Prefer `sampAddChatMessage(text, color)` for in-game text; toasts are UI-only.

## HTTP / networking

- `requests` (`lib/requests.lua`), `socket` (`lib/socket.lua` + `lib/socket/`), `ssl` (`lib/ssl.lua`), `copas` (`lib/copas.lua` + `lib/copas/`), `ltn12`, `mime`.
- `requests` is the high-level HTTP client; use it before raw socket.

## Encoding / text

- `encoding` (`lib/encoding.lua`): `encoding.default = 'CP1251'`, `encoding.UTF8`. Used in `ScreenRecorder.lua` for chat text.
- `basexx` (`lib/basexx.lua`), `bitex` (`lib/bitex.lua`).

## Math / geometry

- `vector3d` (`lib/vector3d.lua`), `matrix3x3` (`lib/matrix3x3.lua`).
- Required by `bitstream_io` for vector types; do not replace with plain tables.

## Hashing

- `md5` (`lib/md5.lua`), `sha1` (`lib/sha1/`).

## Introspection / misc

- `inspect` (`lib/inspect.lua`): pretty-print tables.
- `timerwheel`, `binaryheap`: scheduling helpers.
- `sandbox` (`lib/sandbox.lua`): sandboxed execution.
- `sa_renderfix` (`lib/sa_renderfix.lua`): render fix helper.
- `game/globals.lua`, `game/models.lua`, `game/weapons.lua`: game constants.

## Gotchas

- `require` names use dots for subpaths: `require 'samp.events'`, `require 'cjson.safe'`, `require 'socket.http'`.
- Some modules (requests, copas) depend on `socket`/`ssl`; load order matters.
- `encoding.default` must be set before using `u8` helpers (see ScreenRecorder.lua).
- Font/icon modules (`fAwesome6`, `faIcons`) are large; load only if needed.
