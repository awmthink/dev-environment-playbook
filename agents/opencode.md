# agent: opencode

> 终端 AI coding agent（TUI），coding agent 协作主力之一。全局配置 `~/.config/opencode/opencode.json`，credentials 一律走环境变量（不入 auth.json）。

## 为什么用
终端原生、启动快、支持 75+ LLM provider（via models.dev）、MCP 生态完整；项目级 `.opencode/` 可定制 agent/command/skill；与 Zed/Cursor 等 IDE 的 agent 互补（终端 / 脚本 / 远程服务器场景）。

## 版本约束
- 版本：latest

## 安装

| 平台 | 方式 |
|------|------|
| macOS / Linux | 官方脚本 `curl -fsSL https://opencode.ai/install \| bash`，装到 `~/.opencode/`（user-local，无 sudo） |

> shell 钩子：`.zshrc` 里 `export PATH="$HOME/.opencode/bin:$PATH"`（机器特定，不入 configs 模板）。

## 配置位置
- 全局配置：`~/.config/opencode/opencode.json`（**注意：不是 `~/.opencode/`**——那是安装目录）
  - **后缀**：官方同时支持 `opencode.json` 和 `opencode.jsonc`（JSONC = 允许注释），两者等价、任选其一；本环境统一用 `.json`
- credentials：`~/.local/share/opencode/auth.json`——opencode 内部凭据缓存（`/connect` 交互存的 key，权限 600），**不用它配 apiKey**（见「Provider 与 key 注入」）
- 项目级：仓库根 `opencode.json` / `.opencode/`
- 指令文件：`AGENTS.md`（与其它 agent 共用，`~/.config/opencode/AGENTS.md` 软链到 `~/.agents/AGENTS.md`）
- agents/commands/skills：`.opencode/agent(s)/`、`.opencode/command(s)/`、`.opencode/skill(s)/`

## 配置思路

### Provider 与 key 注入
> **key 绝不写进 opencode.json 明文**。两条注入路径：

- **内置 provider + models.dev 声明的环境变量**：opencode 启动时自动读环境变量（非空则识别为连接）。`opencode auth list` 的 Environment 段列出各 provider 的变量名。
  - OpenCode Go / Zen → `OPENCODE_API_KEY`
- **`provider.{id}.options.apiKey = "{env:VAR}"`**：对未声明环境变量的内置 provider（如 Zhipu），在 opencode.json 显式注入。
  - 例：`zhipuai-coding-plan` 未声明环境变量，用 `options.apiKey = "{env:ZAI_CODING_CN_API_KEY}"`。
- **apiKey 不进 auth.json**：`~/.local/share/opencode/auth.json` 明文、机器耦合、不进版本管理，**不作为凭据配置点**。发现已有条目用 `opencode auth logout <provider-id>` 清除，key 迁到 `secrets.env`。
- config 支持 `{env:VAR}` 和 `{file:path}` 插值（**不是** shell 的 `${VAR}`）。

### MCP
> MCP server 定义集中放 `configs/mcp/`（跨 agent 共享，见 `agents/README.md`），含 opencode 的 `mcp` 字段格式 + server 清单。本机 `opencode.json` 含 `mcp` 字段（运行需要）；key 走 `{env:VAR}`，不写明文。

### 环境变量映射（汇总）
| 用途 | 变量名 | 注入点 |
|------|--------|--------|
| OpenCode Go / Zen provider | `OPENCODE_API_KEY` | opencode 自动读（models.dev 声明） |
| DeepSeek | `DEEPSEEK_API_KEY` | opencode 自动读（models.dev 声明） |
| Xiaomi | `XIAOMI_API_KEY` | opencode 自动读（models.dev 声明） |
| Zhipu (zhipuai-coding-plan) | `ZAI_CODING_CN_API_KEY` | `provider.options.apiKey` |
| MCP（web-search / web-reader / zai-mcp） | `ZAI_CODING_CN_API_KEY` | headers / environment |

> 这些变量放 `~/.config/shell/secrets.env`（见 `tools/shell.md`），由 `.zshrc` 幂等 source。opencode 从终端启动即继承 shell 环境（不像 Zed 的 Dock 启动需 launchctl）。

## 参考
- `configs/opencode/opencode.json`（provider 结构；key 走环境变量）
- `configs/mcp/`（MCP servers 共享参考，opencode + Zed 两种格式）

## 验证
```sh
opencode --version
opencode auth list      # 看 provider 连接状态 + 环境变量识别；env 注入的 provider 不应出现在 Credentials 段
cat ~/.local/share/opencode/auth.json   # 期望 {}（apiKey 不入 auth.json）
opencode models         # 确认可用模型
opencode mcp list       # 确认 MCP server 连接
```
