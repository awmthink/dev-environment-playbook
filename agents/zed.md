# agent: Zed（编辑器 + Agent 平台）

> macOS 日常主力编辑器（见 `profile.md`），同时是 agent 协作平台：内置 Agent 模式 + 远程开发，覆盖「日常主力」与「远程 GPU 服务器」两场景。

## 为什么用
启动快、Rust 原生、GPU 渲染；内置 Agent 模式可挂接多个 coding agent（opencode / claude-acp / cursor-registry）；Remote 开发直连服务器，比 Neovim + tmux 更适合日常（Neovim 仍作纯命令行 fallback）。Cursor 留给大仓库 / 重 agent 场景。

## 版本约束
- 版本：>= 1.0（stable channel；当前实测 **1.14.2**）
- 更新：由 brew cask 统一管理（保持最新 stable）

## 安装

| 平台 | 方式 |
|------|------|
| macOS | `brew install --cask zed` |
| Linux | 官方 tarball / 预览版（按需） |

> macOS 已知坑（与 Ghostty 类似）：cask 只装 `Zed.app`，**不主动把 `zed` CLI 链进 PATH**。需在 Zed 内手动安装 CLI：打开 Zed → `Cmd+Shift+P` → **`zed: install cli`**，它会在 `/usr/local/bin/zed` 建软链指向 `/Applications/Zed.app/Contents/MacOS/cli`。之后 `zed .` / `git core.editor=zed` 才可用。**未装 CLI 时 `which zed` 找不到，不代表 App 没装。**

## 配置位置
- 设置：`~/.config/zed/settings.json`
- keymap：`~/.config/zed/keymap.json`
- 扩展：Zed 内安装；LLM provider 在 `language_models` 声明（结构入模板、key 走环境变量，见下「LLM provider」）
- prompts：`~/.config/zed/prompts/`（自定义 agent prompt）
- AGENTS.md：`~/.config/zed/AGENTS.md` 软链到 `~/.agents/AGENTS.md`（与其它 agent 共享同一份仓库级指令）

## 配置思路
> `configs/zed/settings.json` 固化跨机器通用的**外观 / 布局 / 编辑器偏好 + LLM provider 结构配置**。Agent 模式、agent_servers、ssh_connections 等个人化、流动的配置不进模板，由本机自行维护。

### 外观（对齐 profile）
- `theme = "Aura Dark"`（静态，非 dynamic）：固定 Aura Dark，不走 `{mode, light, dark}` 深浅自动切换——profile 长时间用眼偏好深色，无需浅色 fallback。
- `theme_overrides`：微调 `panel.focused_border` 等（Aura 配色按手感精修，不替换主题）。
- **字号用 Zed 默认**：不显式设 `ui_font_size` / `buffer_font_size`，跟随默认。
- `icon_theme = "Base Charmed Icons"`：与 Aura 配色协调的图标集。
- **buffer font 用 Zed 默认 `.zedMono`**：不设 `buffer_font_family`。Zed 自家代码字体专为代码渲染优化、观感优于手设；代码区字体不与终端强求一致（终端用 Maple Mono NF CN 是为 Nerd Font 图标，编辑器无此需求）。

### LLM provider（key 走环境变量）
> provider 的**结构配置**（api_url / 模型能力 / 上下文窗口）入 `configs/zed/settings.json`；**API key 绝不写进 settings.json**，通过环境变量注入。

- Zed 读 provider 特定的环境变量，**优先级高于系统 keychain**。
- 内置 provider 用固定变量名：`OPENCODE_API_KEY`、`ANTHROPIC_API_KEY`、`OPENAI_API_KEY` 等。
- `openai_compatible` 自定义 provider 的变量名由 provider ID 生成：`UPPER_SNAKE(provider_id) + _API_KEY`。
  - 例：provider ID `zai-coding` → `ZAI_CODING_API_KEY`。
  - provider ID 用**小写连字符**（如 `zai-coding`），变量名才清晰；避免带空格 / 大小写混合的 ID。
- key 放 `~/.config/shell/secrets.env`（见 `tools/shell.md`），由 `.zshrc` 幂等 source。
- **⚠️ 启动方式**：Zed 从「进程环境」读变量——**终端 `zed` 启动**才继承 shell 环境（secrets.env 生效）；从 Dock/Finder 启动不读 `.zshrc`。若需 Dock 启动，用 `launchctl setenv <VAR> <VALUE>`（或 LaunchAgent 持久化）。
- 自定义 headers：`language_models.<provider>.custom_headers` 可附加企业代理 / 观测头（`Authorization` 等 Zed 管理的 header 不可覆盖）。

### Agent 模式（不写入模板，仅记思路）
> 模型 / 后端选择偏个人化、流动，固化价值低；以下供将来固化或新机器恢复时参考。

- `agent.default_profile = "write"`：默认可写权限（信任 agent 落地代码）。
- `agent.default_model`：主力 `opencode` provider 的 `go/deepseek-v4-flash`（thinking on, effort max）——快 + 推理强，日常默认。
- `agent.favorite_models`：收藏备选（含 `glm-5.2` 等），按任务切换。
- `agent.dock = "left"` + `thinking_display = "preview"`：agent 面板常驻左侧，思考过程折叠预览减少干扰。
- `agent.tool_permissions.terminal.default = "allow"`：终端命令默认放行（个人机、信任环境）。
- `agent_servers`：可挂接多个 coding agent 后端（opencode / claude-acp / cursor-registry），按任务选不同 agent，不绑死单一后端。

### 远程开发
- 用 Zed Remote 直连 GPU 服务器（远程训练机），省去 Neovim + tmux 往返。
- **`ssh_connections` 与具体机器 / 账号绑定，不写入 `configs/` 模板**；由各机器本地 `~/.config/zed/settings.json` 自行维护。

### 编辑器行为
- `diff_view_style = "unified"`：unified diff 更紧凑。
- `git.inline_blame.enabled = false`：关掉行内 blame（视觉噪音；需要时走 git_panel）。
- `git_panel.dock = "right"` + `project_panel.dock = "right"`：右侧集中文件 / Git 面板，左侧留给 agent。
- `git_panel.fallback_branch_name = "main"`：对齐 git playbook 的 `init.defaultBranch = main`。
- `collaboration_panel.button = false`：隐藏协作按钮（单人用）。

## 参考
- `configs/zed/settings.json`（外观 / 布局 / 编辑器偏好 + LLM provider 结构配置；key 走环境变量）

## 验证
```sh
zed --version          # 期望：>= 1.0（CLI 已 install cli 才有此命令）
which zed              # 期望：/usr/local/bin/zed
# 启动 Zed：确认 Aura Dark 主题、面板布局生效
```
