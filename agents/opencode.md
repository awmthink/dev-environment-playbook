# agent: opencode

> 终端 AI coding agent（TUI），coding agent 协作主力之一。全局配置 `~/.config/opencode/opencode.json(c)`，credentials 一律走环境变量（API key 不入账号文件）。

## 为什么用
终端原生（Go 独立二进制）、启动快、provider 目录来自 models.dev、MCP 生态完整；项目级 `opencode.json(c)` / `.opencode/` 可定制 agent/command/skill；与 App 类 agent（codex / zcode）互补（终端 / 脚本 / 远程服务器场景）。CLI 除全屏 TUI 外还有 `opencode run`（headless，脚本 / CI 友好）与 `opencode mini`（极简交互）两种入口。

## 版本约束
- 版本：v2（latest；当前实测 **2.0.14**）
- 仓库：`anomalyco/opencode`

## 安装

| 平台 | 方式 |
|------|------|
| macOS | 官方脚本 `curl -fsSL https://opencode.ai/v2/install \| bash`（装到 `~/.opencode/bin/`，user-local、无 sudo）；或 `brew install anomalyco/tap/opencode-v2`——两者都推荐 |
| Linux | 官方脚本 `curl -fsSL https://opencode.ai/v2/install \| bash`（装到 `~/.opencode/bin/`，user-local，无 sudo） |

> **不用 `npm install -g @opencode/cli`**：npm 包靠 postinstall 选平台二进制，但跟随当前 node 版本（本机 node 归 mise，见 `tools/node.md`），mise 升级 node 主版本时全局包不自动迁移、会丢失。官方脚本与 brew 都是独立二进制、与 node 解耦。

> shell 钩子：官方脚本安装需要把 `$HOME/.opencode/bin` 前置进 PATH（本机放 `~/.config/shell/env.sh`，两端 bash/zsh 共享 substance；机器特定，不入 configs 模板）；brew 安装则无需任何钩子。

> 升级：`opencode upgrade`（或重跑官方脚本）；后台 server 升级后需手动重启服务。

## 配置位置
- 全局配置：`~/.config/opencode/opencode.json(c)`（**不是 `~/.opencode/`**——那是安装目录）
  - JSON / JSONC 均支持；本环境统一用 `.json`
- 项目级：仓库根 `opencode.json(c)` / `.opencode/opencode.json(c)`；从 cwd 向上搜索合并，`.opencode/` 内配置覆盖同级直接文件
- 指令文件：`AGENTS.md`（全局 `~/.config/opencode/AGENTS.md` 软链到 `~/.agents/AGENTS.md`；工作区各级 `AGENTS.md` 自动加载，仅认 `AGENTS.md`、不 fallback `CLAUDE.md`）
- 账号文件：`~/.local/share/opencode/account.json`——`opencode auth login` / TUI `/connect` 交互存的账号（OAuth token / API key，权限 600），**不用它配 apiKey**（见「Provider 与 key 注入」）
- 后台服务：默认一个共享后台 server（`opencode service` 管理）；`opencode --standalone` 起私有 server（一次性进程，直接继承 shell 环境）

## 配置思路

### Provider 与 key 注入
> **key 绝不写进 opencode.json 明文**。两条路径：

- **models.dev 已声明环境变量的内置 provider**：在 server 进程环境里设变量即可（secrets.env 由 `.zshrc` source，终端启动即继承；或 `opencode service set env VAR value` 持久化到共享 server）。`opencode auth list` 里显示为 `environment`。
  - OpenCode Go / Console → `OPENCODE_API_KEY`
  - Volcengine Ark → `ARK_API_KEY`
- **未声明环境变量的内置 provider（如 Zhipu AI Coding Plan）**：在 `providers.{id}.env` 显式声明变量名：
  ```json
  "providers": { "zhipuai-coding-plan": { "env": ["ZAI_CODING_API_KEY"] } }
  ```
- **`{env:VAR}` / `{file:path}` 插值**仅用于 MCP `headers` / `environment` 等字段；provider 的 key 走 `providers.{id}.env` 声明 + 环境变量，不往 `options.apiKey` 里写 `{env:VAR}`。
- 账号凭据（OAuth / 交互式 key）存 `~/.local/share/opencode/account.json`，`opencode auth list` 显示为账号；`opencode auth logout <provider-id>` 清除。环境变量连接不属于账号，`auth logout` 删不掉，取消变量即断连。

### 环境变量注入到 server
> 共享后台 server 默认继承**首次启动**时的 shell 环境；后续改 key 用 `opencode service set env VAR value`（会重启 service 生效）。`opencode auth list` 确认注入结果。

### MCP
> server 定义集中放 `configs/mcp/`（跨 agent 共享，见 `agents/README.md`），opencode 用 `mcp.servers` 字段。key 走 `{env:VAR}`；remote 且纯 API key（无 OAuth）的 server 设 `"oauth": false`。

### 环境变量映射（汇总）
| 用途 | 变量名 | 注入点 |
|------|--------|--------|
| OpenCode Go / Console | `OPENCODE_API_KEY` | models.dev 声明，server 环境 |
| Volcengine Ark | `ARK_API_KEY` | models.dev 声明，server 环境 |
| Zhipu AI Coding Plan | `ZAI_CODING_API_KEY` | `providers.zhipuai-coding-plan.env` |
| MCP（web-search / web-reader / zai-mcp） | `ZAI_CODING_API_KEY` | headers / environment 的 `{env:VAR}` |

> 这些变量放 `~/.config/shell/secrets.env`（见 `tools/shell.md`），由 `.zshrc` 幂等 source。

## 参考
- `configs/opencode/opencode.json`（provider / MCP 结构；key 走环境变量）
- `configs/agents/AGENTS.md`（跨 agent 全局指令的参考实物；本机 `~/.config/opencode/AGENTS.md` 软链到 `~/.agents/AGENTS.md`）
- `configs/mcp/`（MCP servers 共享参考，opencode + pi 两种格式）

## 验证
```sh
opencode --version
opencode auth list      # 看 provider 连接状态；env 注入显示 environment，账号显示 account
opencode models         # 确认可用模型
opencode mcp list       # 确认 MCP server 状态（connected）
opencode run "hi"       # headless 一镜到底，验证 provider + key 生效
```
