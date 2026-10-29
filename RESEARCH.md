# RESEARCH.md — Agent skill format comparison (Phase 0)

Verified via official documentation (URLs below). No third-party blogs used as authority.

| Agent | Project location | Global location | File | Frontmatter | Trigger | Limits | Source URL |
|---|---|---|---|---|---|---|---|
| OpenCode | `.opencode/skills/<name>/SKILL.md`, `.claude/skills/`, `.agents/skills/` | `~/.config/opencode/skills/`, `~/.claude/skills/`, `~/.agents/skills/` | SKILL.md | name (req), description (req), license, compatibility, metadata. name regex `^[a-z0-9]+(-[a-z0-9]+)*$`, 1-64 chars, must match dir. description 1-1024 chars. | Description via `skill` tool. | None stated beyond desc length. | https://opencode.ai/docs/skills |
| Claude Code | `.claude/skills/<name>/SKILL.md` (nested ok) | `~/.claude/skills/<name>/SKILL.md` | SKILL.md | name (opt), description (rec), when_to_use, allowed-tools, disallowed-tools, model, effort, context, agent, hooks, paths, shell, metadata, license, compatibility, plus Claude-only fields. Standard subset only outside Claude Code. | Description + when_to_use. | Keep SKILL.md lean (<500 lines guidance). | https://code.claude.com/docs/en/skills ; https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview |
| Codex (OpenAI) | `.agents/skills/` (walks up to repo root) | `$HOME/.agents/skills/`, `/etc/codex/skills` | SKILL.md + optional `agents/openai.yaml` | name, description (req). openai.yaml: interface, policy.allow_implicit_invocation, dependencies. | Implicit via description + explicit `$skill`. | Initial list max 2% context (8000 chars default, up to 10000 tokens via config). | https://developers.openai.com/codex/build-skills ; https://learn.chatgpt.com/docs/build-skills |
| Pi | `.agents/skills/`, `.pi/skills/` (project) | `~/.pi/agent/skills/`, `~/.agents/skills/` | SKILL.md | name, description, license, compatibility, metadata, allowed-tools, disable-model-invocation. name <=64, desc <=1024. | Description + `/skill:name`. | — | https://pi.dev/docs/latest/skills |
| Gemini CLI | `.gemini/skills/` or `.agents/skills/` (workspace) | `~/.gemini/skills/` or `~/.agents/skills/` | SKILL.md | name, description (req); standard fields. | Description via `activate_skill`. | — | https://geminicli.com/docs/cli/skills |
| Cursor | `.cursor/rules/*.mdc` OR `AGENTS.md` (plain md) | User Rules in settings | .mdc (description, globs, alwaysApply) or AGENTS.md (no frontmatter) | .mdc frontmatter; AGENTS.md none. | Description-based intelligent apply. | Under 500 lines recommended. | https://cursor.com/docs/context/rules |

## Conclusion

The cross-agent compatible format is a `SKILL.md` with standard YAML frontmatter (name, description, license, compatibility, metadata) plus `references/`, `scripts/`, `assets/`, `examples/` subfolders, placed at `.agents/skills/<name>/`. This is discovered by OpenCode, Claude Code, Codex, Pi, Gemini CLI, and Cursor (via AGENTS.md fallback). No per-agent duplicate content is needed. Installation paths per agent are listed in `INSTALL.md`.
