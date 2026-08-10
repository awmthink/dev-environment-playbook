# agents/ — Coding Agent 配置 playbook

coding agent 本身也是开发工具，也需要被管理。这里记录我用的每个 agent 的配置思路、关键文件位置、以及如何在新机器上恢复。

> 给 agent：当任务涉及「配置某个 agent」时，先读本目录对应文件，再执行。

## 涉及的 agent

| Agent | 配置入口 | 文件 |
|-------|----------|------|
| opencode | `opencode.json` / `.opencode/` / 仓库内 `AGENTS.md` | `opencode.md` |
| Claude Code | `CLAUDE.md` / `~/.claude/` | `claude-code.md` |
| Codex (OpenAI) | `AGENTS.md` / `~/.codex/` | `codex.md` |
| Cursor | `.cursor/rules` / settings.json | `cursor.md` |
| Zed | `~/.config/zed/settings.json` | `zed.md` |
| Zcode | <!-- 待补充 --> | `zcode.md` |
| Qoder | <!-- 待补充 --> | `qoder.md` |

## 共享：MCP servers
<!-- 多个 agent 共用的 MCP server 配置集中记录，避免重复。如需可创建 mcp.md -->
