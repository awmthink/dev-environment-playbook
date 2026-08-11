# agents/ — Coding Agent 配置 playbook

coding agent 本身也是开发工具，也需要被管理。这里记录我用的每个 agent 的配置思路、关键文件位置、以及如何在新机器上恢复。

> 给 agent：当任务涉及「配置某个 agent」时，先读本目录对应文件，再执行。

## 涉及的 agent

| Agent | 配置入口 | 文件 |
|-------|----------|------|
| opencode | `opencode.json` / `.opencode/` / 仓库内 `AGENTS.md` | `opencode.md` |
| Claude Code | `CLAUDE.md` / `~/.claude/` | `claude-code.md` |
| Codex (OpenAI) | `AGENTS.md` / `~/.codex/` | `codex.md` |
| Zcode | <!-- 待补充 --> | `zcode.md` |
| Qoder | <!-- 待补充 --> | `qoder.md` |

## 共享：MCP servers
> 多个 agent 共用的 MCP server 集中定义在 `configs/mcp/`（含 opencode / Zed 两种格式 + 差异速查）。各 agent 从自己配置文件读（opencode `mcp` 字段、Zed `context_servers` 字段），key 统一走 `{env:ZAI_CODING_API_KEY}`，放 `~/.config/shell/secrets.env`。
