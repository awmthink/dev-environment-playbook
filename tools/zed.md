# tool: Zed（纯 editor）

> macOS 日常主力**编辑器**（见 `profile.md`）。定位为**纯 editor**——只用它的编辑 / 远程开发能力，**不用它的 agent / MCP / LLM provider**。agent 交给 opencode / claude-code / codex / qoder-cli（见各自 `agents/*.md`）。

## 为什么用
启动快、Rust 原生、GPU 渲染；Remote 开发直连 GPU 服务器，比 Neovim + tmux 更适合日常（Neovim 仍作纯命令行 fallback）。Cursor 留给大仓库场景。

> **不用 Zed 的 agent 功能**：内置 Agent 模式、`context_servers`（MCP）、`language_models`（LLM provider）都不配置——这些能力分散到专用 agent 工具，职责清晰、各取所长。Zed 只做编辑器。

## 最低版本要求
- 版本：>= 1.0（stable channel；当前实测 **1.14.2**）
- 更新：cask 为 `auto_updates` flavor——brew 负责首次安装 / `brew upgrade` 不会主动升级它，**Zed 自带更新器**保持最新 stable。仍属 brew 收管（`brew list --cask` 可见、可 `brew uninstall --cask zed` 干净卸载）。

## 版本与安装策略

**多版本需求：否**——编辑器全局单一即可；自带更新器维持最新 stable。

**各平台安装**：

| 平台 | 推荐方式 |
|------|----------|
| macOS | `brew install --cask zed` |

> Linux 定位为 headless 服务器（见 `platforms/linux.md`），**不装 GUI 版 Zed**。远程开发由 macOS 端 Zed 客户端通过 Remote 协议直连 Linux 服务器——远端跑的是 headless server 进程，由 Zed 客户端自动拉起，无需按本节步骤在 Linux 上手动安装。

> **`zed` CLI 链接取决于安装方式**：
> - **brew cask 安装**（本 playbook 推荐路径）：cask 会自动把 `zed` 链到 `/opt/homebrew/bin/zed`（指向 `/Applications/Zed.app/Contents/MacOS/cli`），无需任何手动步骤。
> - **官方下载安装**（拖 App 到 `/Applications`）：App 本身**不会**自动链 CLI——需在 Zed 内 `Cmd+Shift+P → zed: install cli`，建软链到 `/usr/local/bin/zed`。
>
> 链接建好后终端里 `zed .`（在当前目录打开 Zed 项目）即可直接调用；区别只在落点 `/opt/homebrew/bin` 还是 `/usr/local/bin`。若历史上从官方下载迁移到 cask，旧 `/usr/local/bin/zed` 软链可忽略（PATH 上被 `/opt/homebrew/bin/zed` 覆盖）或 `sudo rm` 清理。

## 配置位置
- 设置：`~/.config/zed/settings.json`
- keymap：`~/.config/zed/keymap.json`
- 扩展：Zed 内安装

## 配置思路
> `configs/zed/settings.json` 只固化跨机器通用的**外观 / 布局 / 编辑器行为**。**不配置任何 agent / MCP / LLM 相关项**。

### 外观（对齐 profile）
- `theme = "Aura Dark"`（静态，非 dynamic）：固定 Aura Dark，不走 `{mode, light, dark}` 深浅自动切换——profile 长时间用眼偏好深色，无需浅色 fallback。
- `theme_overrides`：微调 `panel.focused_border` 等（Aura 配色按手感精修，不替换主题）。
- **字号用 Zed 默认**：不显式设 `ui_font_size` / `buffer_font_size`，跟随默认。
- `icon_theme = "Base Charmed Icons"`：与 Aura 配色协调的图标集。
- **buffer font 用 Zed 默认 `.zedMono`**：不设 `buffer_font_family`。Zed 自家代码字体专为代码渲染优化、观感优于手设；代码区字体不与终端强求一致（终端用 Maple Mono NF CN 是为 Nerd Font 图标，编辑器无此需求）。

### 远程开发
- 用 Zed Remote 直连 GPU 服务器（远程训练机），省去 Neovim + tmux 往返。
- **`ssh_connections` 与具体机器 / 账号绑定，不写入 `configs/` 模板**；由各机器本地 `~/.config/zed/settings.json` 自行维护。

### 编辑器行为
- `diff_view_style = "unified"`：unified diff 更紧凑。
- `git.inline_blame.enabled = false`：关掉行内 blame（视觉噪音；需要时走 git_panel）。
- `git_panel.dock = "right"` + `project_panel.dock = "right"`：右侧集中文件 / Git 面板。
- `git_panel.fallback_branch_name = "main"`：对齐 git playbook 的 `init.defaultBranch = main`。
- `collaboration_panel.button = false`：隐藏协作按钮（单人用）。

## 参考
- `configs/zed/settings.json`（只含外观 / 布局 / 编辑器偏好的通用模板）

## 验证
```sh
zed --version          # 期望：>= 1.0
which zed              # 期望：/opt/homebrew/bin/zed（cask 自动链入）
# 启动 Zed：确认 Aura Dark 主题、面板布局生效；Agent 面板不使用
```
