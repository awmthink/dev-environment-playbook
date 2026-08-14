# agent: Pi（pi coding agent）

> CLI 类。Pi = Mario Zechner（badlogic）的极简终端 coding agent（pi.dev），TypeScript/Node 实现、MIT 开源。配置根目录 `~/.pi/agent/`，凭据走环境变量。

## 为什么用
- **极简 harness + 深度可定制**：核心只给 `read` / `bash` / `edit` / `write` / `grep` / `find` / `ls` 工具，MCP / 子 agent / plan mode 等一律不内置——按需用 TypeScript 扩展、skills（Agent Skills 标准）、prompt 模板、主题自建或装 pi package（npm/git）。
- **15+ provider 覆盖国内**：DeepSeek / ZAI Coding Plan / Kimi / MiniMax / Xiaomi MiMo / Moonshot 等开箱即用；API key 或订阅 OAuth 两种鉴权。
- **四模式**：交互 TUI 之外还有 print（`pi -p`，脚本友好）、JSON、RPC、SDK——与 opencode 互补：opencode 生态全（MCP 完整）当日常主力，pi 当脚本 / 定制 / CI 场景的轻量 CLI。
- session 树 + 分支（`/tree`）、自动 compaction、`/share` 导出会话。

## 版本约束
- 版本：latest（自带更新器 `pi update --self`，pi 官方更新方式；勿手动 `npm upgrade -g`，那样绕过 pi 的版本 / shrinkwrap 处理）

## 安装

### pi 本体

| 平台 | 推荐方式 |
|------|----------|
| macOS / Linux | 官方脚本 `curl -fsSL https://pi.dev/install.sh \| sh`（自动选 npm prefix；机器无 node 时可交互安装） |

> npm 备选（本仓库 node 由 mise 管，见 `tools/node.md`）：`npm install -g --ignore-scripts @earendil-works/pi-coding-agent`，装进当前 node 前缀、经 mise shim 暴露 `pi`。

> **官方脚本内部即 `npm install -g`**（装到当前 npm prefix = mise node 版本目录），与上方手动 npm 等价、落点相同——与 opencode 不同（opencode 是 Go 独立二进制、真与 node 解耦；pi 是 node 程序，必须依赖 node）。**后果**：mise 升级 node 后 pi 绑在旧版本目录、会从 PATH 消失（node 升级频率低，故不做 postinstall 自动化）；恢复：重跑 install.sh（自动用新 node prefix 重装，`pi update --self` 因此时 pi 不在 PATH 而不可用）。

### MCP 适配器 + server 配置

> pi 无内置 MCP，需要时以扩展补齐（本环境已纳入标配）：

```sh
pi install npm:pi-mcp-adapter   # 装 MCP 适配器扩展，重启 pi 生效
```

> 配置文件：标准 `mcpServers` 格式落 `~/.config/mcp/mcp.json`（用户全局共享、adapter 优先级最高），内容见 `configs/mcp/README.md` 的「pi 格式」段；key 用 `${VAR}` 插值（读 secrets.env 的 `ZAI_CODING_CN_API_KEY`），不写明文。装完在 pi 内 `/mcp` 确认 server 状态（懒加载：首次调用才拉起）。

## 配置位置
- 全局：`~/.pi/agent/`（可用 `PI_CODING_AGENT_DIR` 覆盖）
  - `settings.json`——全局设置（thinking / 主题 / compaction / project trust / telemetry）
  - `AGENTS.md`——全局上下文指令；另外自动加载 cwd 到根目录各级的 `AGENTS.md` / `CLAUDE.md`（目录里存在 `AGENTS.override.md` 时优先）
  - `SYSTEM.md` / `APPEND_SYSTEM.md`——替换 / 追加 system prompt
  - `models.json`——自定义 provider / 模型
  - `auth.json`——凭据（0600；`/login` 交互所存；**解析优先级高于环境变量**）
  - `sessions/`——会话 JSONL（按工作目录组织，树结构支持分支）
  - `prompts/` `skills/` `extensions/` `themes/` `git/` `npm/`——定制资源与 pi packages
- 项目级：`.pi/settings.json` + `.pi/{prompts,skills,extensions,themes}/`（需 project trust，首次启动交互确认，决策存 `trust.json`）
- skills 另读 `~/.agents/skills/` 与各级 `.agents/skills/`（Agent Skills 标准，与 opencode 可共享目录）

## 配置思路

### Provider 与 key 注入
> **key 走环境变量（secrets.env），API key 不进 auth.json**——pi 的解析顺序是 `--api-key` > `auth.json` > 环境变量，`/login` 存 key 会遮蔽 env、造成双处凭据。`/login` 只用于订阅 OAuth（ChatGPT Plus / Claude Pro / GitHub Copilot）。

| Provider | 环境变量 | 备注 |
|----------|----------|------|
| DeepSeek | `DEEPSEEK_API_KEY` | 与 opencode 同变量，secrets.env 已有 |
| Z.AI Coding CN | `ZAI_CODING_CN_API_KEY` | provider id `zai-coding-cn`（baseUrl open.bigmodel.cn），与 opencode 同变量直接复用 |
| OpenCode Go / Zen | `OPENCODE_API_KEY` | 与 opencode 同变量 |
| Xiaomi MiMo | `XIAOMI_API_KEY` | 与 opencode 同变量 |

> 完整映射参考 pi 仓库 `packages/ai/src/env-api-keys.ts`。变量放 `~/.config/shell/secrets.env`（见 `tools/shell.md`），pi 从终端启动即继承。

### 上下文与 skills 复用
- 仓库内 `AGENTS.md` 自动被 pi 读取（与其它 agent 共用同一份）。
- 全局 `~/.pi/agent/AGENTS.md` 软链 `~/.agents/AGENTS.md`（跨 agent 唯一实体，见 `agents/README.md`），与 opencode / codex 共用一份全局指令。
- skills 目录（`~/.agents/skills/`）与 opencode 共享：写一份、两边用。

### MCP：pi-mcp-adapter + 标准 mcp.json
- pi 官方哲学不内置 MCP（缺什么用扩展补）；本环境用第三方适配器 `pi-mcp-adapter` 补齐（安装与配置见上文「安装」）。
- 配置读**标准 MCP 配置文件**（`mcpServers` 格式，与主流 host 通用），优先级：`~/.config/mcp/mcp.json` > `~/.agents/mcp.json` > `~/.agents/mcp/mcp.json` > `~/.pi/agent/mcp.json` > `.mcp.json` > `.pi/mcp.json`；本环境 server 清单落 `~/.config/mcp/mcp.json`。
- 交互：pi 内 `/mcp` 管理面板（enable / disable / 状态）、`/mcp setup` 可导入其它 host 的既有 MCP 配置；终端等价命令 `pi-mcp-adapter init`。
- 特性：server 懒加载 + 单代理工具（`mcp({ search })` / `mcp({ tool, args })`），工具定义不进 context，省 token。
- **插值语法差异**：opencode 用 `{env:VAR}`，pi-mcp-adapter 用 `${VAR}`——同一批 server 在 `configs/mcp/README.md` 里按两种格式各存一份。

### 启动网络行为（可选）
- 启动时更新检查 + 安装遥测会访问 pi.dev；代理网络下可设 `PI_SKIP_VERSION_CHECK=1`、`PI_TELEMETRY=0` 关闭。

## 参考
- `configs/agents/AGENTS.md`（跨 agent 全局指令的参考实物）
- `configs/shell/secrets.env.example`（`ZAI_CODING_CN_API_KEY` 条目，pi 与 opencode 共用）
- 官方文档：https://pi.dev/docs/latest（settings / providers / skills）

## 验证
```sh
pi --version                       # 期望：latest（pi update --self 更新）
pi list                            # 期望：pi-mcp-adapter 已安装
pi --list-models | head -n 20      # 模型目录正常加载
pi -p "hi"                         # print 模式一镜到底（验证 provider + key 生效）
cat ~/.pi/agent/auth.json          # 期望：{} 或仅订阅 OAuth 条目（API key 走 env）
# pi 内 /mcp → 确认 web-search-prime / web-reader / zai-mcp-server 状态
```
