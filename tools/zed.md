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
| Linux | 官方 tarball / 预览版（按需） |

> macOS cask 现已**自动把 `zed` CLI 链到 `/opt/homebrew/bin/zed`**（指向 `/Applications/Zed.app/Contents/MacOS/cli`），无需再手动 `zed: install cli`。早期版本（旧 cask）曾只装 App 不链 CLI，需在 Zed 内 `Cmd+Shift+P → zed: install cli` 建软链到 `/usr/local/bin/zed`——该手动软链现已冗余（PATH 上被 `/opt/homebrew/bin/zed` 覆盖），若历史遗留存在可忽略或 `sudo rm` 清理。`zed .` / `git core.editor=zed` 直接可用。

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
