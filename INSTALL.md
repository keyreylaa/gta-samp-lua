# INSTALL.md — where to put this skill

Copy the whole `gta-samp-lua/` folder into one of these locations depending on the agent:

| Agent | Project-level | Global |
|---|---|---|
| OpenCode | `.agents/skills/gta-samp-lua/` | `~/.agents/skills/gta-samp-lua/` |
| Claude Code | `.claude/skills/gta-samp-lua/` | `~/.claude/skills/gta-samp-lua/` |
| Codex | `.agents/skills/gta-samp-lua/` | `~/.agents/skills/gta-samp-lua/` |
| Pi | `.agents/skills/gta-samp-lua/` | `~/.pi/agent/skills/gta-samp-lua/` or `~/.agents/skills/gta-samp-lua/` |
| Gemini CLI | `.agents/skills/gta-samp-lua/` | `~/.agents/skills/gta-samp-lua/` |
| Cursor | (use `AGENTS.md` at repo root pointing to this folder; or `.cursor/rules/gta-samp-lua.mdc`) | User Rules in settings |

Cursor does not read `SKILL.md` directly; provide an `AGENTS.md` at the repo root that says: "For GTA SA-MP Lua work, read `/home/shellix/skills/gta-samp-lua/SKILL.md` and its `references/`." Or convert to a `.mdc` rule.

Do not copy only `SKILL.md`; the `references/` and `examples/` folders must travel with it.
