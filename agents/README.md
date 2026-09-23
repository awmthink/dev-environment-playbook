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

> 分工思路：CLI 类覆盖终端 / 远程服务器场景，App 类覆盖 GUI 集成场景；编辑器仍由 Zed（纯 editor，见 `profile.md`）负责，agent 与 editor 职责分离。**App 类的配置在 GUI 内完成、不落配置文件，playbook 只登记分类、不管理配置**（迁移靠各自 App 的账号同步 / 手动设置）。

## 共享：全局 AGENTS.md
> 一份跨 agent 的全局指令，唯一实体 `~/.agents/AGENTS.md`（内容参考 `configs/agents/AGENTS.md`：交互原则 / 网络代理 / 凭据约定 / 注释规范）。各 agent 从自己的读取位置**软链**到它，改一处、全员生效：

| Agent | 读取位置 |
|-------|----------|
| opencode | `~/.config/opencode/AGENTS.md` → 软链 |
| Pi | `~/.pi/agent/AGENTS.md` → 软链（另自动读各级目录 AGENTS.md） |
| Codex | `~/.codex/AGENTS.md` → 软链 |
| Zcode | `~/.zcode/AGENTS.md` → 软链 |

## 共享：MCP servers
> 多个 agent 共用的 MCP server 集中定义在 `configs/mcp/`（opencode 的 `mcp` 字段 + pi 的标准 `mcpServers` 两种格式 + server 清单）。各 agent 从自己配置文件读，key 统一走环境变量（`ZAI_CODING_CN_API_KEY`），放 `~/.config/shell/secrets.env`。

## 环境对齐必检清单

> 通用「检查 / 同步环境」任务必须覆盖本清单（不只是 `tools/`）。**CLI 类 + 共享实体必检；App 类（codex / zcode）配置在 GUI 内、playbook 只登记，不检查配置内容**（可选只验版本，如 `codex --version`）。逐项按对应卡片（`opencode.md` / `pi.md`）的「验证」段执行；共享实体按本表检查。

| 项 | 检测点 | 命令 |
|----|--------|------|
| opencode | 本体 / provider / MCP | `opencode.md` 验证段（`--version`、`auth list`、`mcp list` 等） |
| pi | 本体 / 扩展 / MCP | `pi.md` 验证段（`--version`、`pi list`、pi 内 `/mcp`） |
| 全局指令软链 | opencode / pi / codex / zcode 的读取位置 → `~/.agents/AGENTS.md` | `ls -l ~/.config/opencode/AGENTS.md ~/.pi/agent/AGENTS.md ~/.codex/AGENTS.md ~/.zcode/AGENTS.md` |
| secrets.env | 存在、0600、含 agent 所需 key（如 `ZAI_CODING_CN_API_KEY`，值不外显） | `stat -c %a ~/.config/shell/secrets.env`（Linux，期望 600；macOS 用 `stat -f %Lp`）；`grep -c 'ZAI_CODING_CN_API_KEY' ~/.config/shell/secrets.env`（期望 ≥1） |
| pi MCP 配置 | `~/.config/mcp/mcp.json`（mcpServers 格式、`${VAR}` 插值） | `test -f ~/.config/mcp/mcp.json && echo ok` |
| skills 共享目录 | `~/.agents/skills/`（opencode / pi 共用，若使用） | `test -d ~/.agents/skills && echo ok` |

> 凭据约定随附检查：opencode 的 `~/.local/share/opencode/auth.json` 期望 `{}`；pi 的 `~/.pi/agent/auth.json` 期望 `{}` 或仅订阅 OAuth 条目（API key 走 env，见各卡片验证段）。
