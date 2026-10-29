# gta-samp-lua

A cross-agent skill for writing Lua scripts for GTA: San Andreas SA-MP on
MoonLoader, MonetLoader (Android), and `.dex` modules.

Compatible with OpenCode, Claude Code, Codex, Pi, Gemini CLI, and Cursor.

## What it covers

- Script lifecycle: `main`, `wait`, events, reload, cleanup.
- GUI with mimgui: windows, widgets, render callback, state.
- Fonts: loading, glyph ranges (non-Latin), merge mode.
- Chat commands: registration, parsing, removal, platform fallback.
- RakNet: RPC/packet hooking, bitstream types, read/write.
- Sync: PlayerSync/VehicleSync/... structs, outgoing and incoming handlers.
- SA-MP event names and payloads (from `lib/samp/events.lua`).
- SAMPFUNCS constants.
- Android JNI, DexClassLoader, `.dex` workflow.
- Native hooks via `monethook`.
- Memory read/write, pools, metatypes.
- Platform differences (MoonLoader vs MonetLoader vs `.dex`).
- Authoring your own `lib/`-style module.

## Install

Copy the whole `gta-samp-lua/` folder into one of these locations.

| Agent | Project-level | Global |
|---|---|---|
| OpenCode | `.agents/skills/gta-samp-lua/` | `~/.agents/skills/gta-samp-lua/` |
| Claude Code | `.claude/skills/gta-samp-lua/` | `~/.claude/skills/gta-samp-lua/` |
| Codex | `.agents/skills/gta-samp-lua/` | `~/.agents/skills/gta-samp-lua/` |
| Pi | `.agents/skills/gta-samp-lua/` | `~/.pi/agent/skills/gta-samp-lua/` or `~/.agents/skills/gta-samp-lua/` |
| Gemini CLI | `.agents/skills/gta-samp-lua/` | `~/.agents/skills/gta-samp-lua/` |
| Cursor | `AGENTS.md` at repo root, or `.cursor/rules/gta-samp-lua.mdc` | User Rules in settings |

Cursor does not read `SKILL.md` directly. Provide an `AGENTS.md` at the repo root that says:
"For GTA SA-MP Lua work, read `gta-samp-lua/SKILL.md` and its `references/`."

Do not copy only `SKILL.md`; the `references/` and `examples/` folders must travel with it.

## Structure

```
gta-samp-lua/
├── SKILL.md
├── README.md
├── INSTALL.md
├── RESEARCH.md
├── UNVERIFIED.md
├── LICENSE
├── references/   (15 topic files)
└── examples/     (6 minimal patterns)
```

## License

MIT. See `LICENSE`.

## Notes

- Every API in `references/` is traced to `lib/` or to code in this workspace that is known to run. Items that could not be verified are listed in `UNVERIFIED.md` instead of being guessed.
- `SKILL.md` is 62 lines (under the 200-line target). References are loaded on demand.
