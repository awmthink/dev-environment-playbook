# agents/ — Coding Agent 配置 playbook

coding agent 本身也是开发工具，也需要被管理。这里记录我用的每个 agent 的配置思路、关键文件位置、以及如何在新机器上恢复。

> 给 agent：当任务涉及「配置某个 agent」时，先读本目录对应文件，再执行。

## 涉及的 agent

按形态分两类：

### CLI 类（终端）

| Agent | 配置入口 | 文件 |
|-------|----------|------|
| opencode | `opencode.json` / `.opencode/` / 仓库内 `AGENTS.md` | `opencode.md` |
| Pi (pi coding agent) | `~/.pi/agent/`（settings.json / AGENTS.md / auth.json） | `pi.md` |

### App 类（GUI）

| Agent | 配置入口 | 文件 |
|-------|----------|------|
| Codex (OpenAI) | App 内配置（playbook 不覆盖） | `codex.md` |
| Zcode | App 内配置（playbook 不覆盖） | `zcode.md` |
| Cursor | App 内配置（playbook 不覆盖） | `cursor.md` |

> 分工思路：CLI 类覆盖终端 / 远程服务器场景，App 类覆盖 GUI 集成场景；编辑器仍由 Zed（纯 editor，见 `profile.md`）负责，agent 与 editor 职责分离。**App 类的配置在 GUI 内完成、不落配置文件，playbook 只登记分类、不管理配置**（迁移靠各自 App 的账号同步 / 手动设置）。

## 共享：全局 AGENTS.md
> 一份跨 agent 的全局指令，唯一实体 `~/.agents/AGENTS.md`（内容参考 `configs/agents/AGENTS.md`：网络代理 / 内部 PyPI / 注释规范）。各 agent 从自己的读取位置**软链**到它，改一处、全员生效：

| Agent | 读取位置 |
|-------|----------|
| opencode | `~/.config/opencode/AGENTS.md` → 软链 |
| Pi | `~/.pi/agent/AGENTS.md` → 软链（另自动读各级目录 AGENTS.md） |
| Codex | `~/.codex/AGENTS.md` → 软链 |
| Zcode | 待确认 |
| Cursor | 待确认（全局规则走 GUI，见 `cursor.md`） |

## 共享：MCP servers
> 多个 agent 共用的 MCP server 集中定义在 `configs/mcp/`（opencode 的 `mcp` 字段 + pi 的标准 `mcpServers` 两种格式 + server 清单）。各 agent 从自己配置文件读，key 统一走环境变量（`ZAI_CODING_CN_API_KEY`），放 `~/.config/shell/secrets.env`。
