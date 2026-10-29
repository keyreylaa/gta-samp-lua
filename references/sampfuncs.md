# SAMPFUNCS

Source: `lib/sampfuncs.lua`. This module only defines constants and copies them into `_G`. The underlying SAMPFUNCS functions (`isSampLoaded`, `sampAddChatMessage`, `sampRegisterChatCommand`, `raknetBitStream*`, etc.) are provided by the SAMPFUNCS plugin at runtime, not by this file.

## Constants (selected groups)

- RPC ids: `RPC_*` (e.g. `RPC_CHAT`, `RPC_DIALOGRESPONSE`, `RPC_SHOWDIALOG`). Full list in file.
- Packet ids: `PACKET_*`.
- Game states: `GAMESTATE_NONE/WAIT_CONNECT/AWAIT_JOIN/CONNECTED/RESTARTING/DISCONNECTED`.
- BitStream types: `BS_TYPE_BYTE/BOOL/SHORT/INT/FLOAT/ARRAY/BITSTREAM`.
- Priorities: `SYSTEM_PRIORITY/HIGH_PRIORITY/MEDIUM_PRIORITY/LOW_PRIORITY`.
- Reliability: `UNRELIABLE/UNRELIABLE_SEQUENCED/RELIABLE/RELIABLE_ORDERED/RELIABLE_SEQUENCED`.
- Sendrates: `ONFOOTSENDRATE/INCARSENDRATE/AIMSENDRATE`.
- Limits: `MAX_PLAYERS=1004`, `MAX_VEHICLES=2000`, `MAX_PICKUPS=4096`, `MAX_OBJECTS=1000`, `MAX_GANGZONES=1024`, `MAX_3DTEXTS=2048`, `MAX_TEXTDRAWS=2048`, `MAX_CLIENTCMDS=144`, `MAX_MENUS=128`.
- Dialog styles: `DIALOG_STYLE_MSGBOX/INPUT/LIST/PASSWORD/TABLIST/TABLIST_HEADERS`.
- Cursor modes: `CMODE_*`.
- Text styles: `FCR_NONE/BOLD/ITALICS/BORDER/SHADOW/UNDERLINE/STRIKEOUT`.
- Special actions: `SPECIAL_ACTION_*`.
- SCM events: `SCMEVENT_PAINTJOB/UPGRADE/COLOR/MODSHOPENTEREXIT`.
- Primitive types: `D3DPT_*`.

## Runtime functions (provided by plugin, not in lib)

`sampAddChatMessage(text, color)`, `sampRegisterChatCommand(name, cb)`, `sampUnregisterChatCommand(name)`, `isSampLoaded()`, `isSampfuncsLoaded()`, `raknetBitStream*`, `getMoonloaderVersion()`. Guard with `type(...) == "function"`; not all builds expose all of them.

## Gotchas

- Constants are globals after `require 'sampfuncs'` (the module copies itself into `_G`).
- Do not redefine these constants; rely on the module.
- SAMPFUNCS is a separate plugin; if it is missing, `isSampfuncsLoaded()` is false and `samp.events` refuses to load.
