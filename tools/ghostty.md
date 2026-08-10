# tool: Ghostty

> macOS 主力终端（GPU / Metal 渲染），从 iTerm2 切换而来。

## 为什么用
GPU(Metal) 渲染流畅、原生 macOS 体验、单文件 `key = value` 配置简洁可读；**内置 Aura 主题**直接命中 profile 的 Aura Dark 偏好（无需自定义主题文件）；shell 集成开箱即用；启动快。iTerm2 成熟稳定，作为备选保留。

## 版本约束
- 版本：>= 1.3（stable channel；当前 1.3.1）

## 安装

| 平台 | 方式 |
|------|------|
| macOS | `brew install --cask ghostty` |
| Linux | 官方 AppImage / 源码构建（较新，按需） |

## 配置思路
配置文件：`~/.config/ghostty/config`（`key = value`，单文件）。整份参考见 `configs/ghostty/config`，关键项与理由：

- `theme = Aura`：内置主题，命中 profile 的 Aura Dark 偏好，无需自定义主题文件。
- `font-family = "Maple Mono NF CN"`：profile 主力字体（中英混排对齐、覆盖图标 / CJK）；备选 JetBrainsMono Nerd Font。
  - 字体安装：`brew install --cask font-maple-mono-nf-cn`。
- `macos-titlebar-style = transparent` + `background-opacity = 0.96`：沉浸感 + 长时用眼柔和。
- `cursor-style = block` + `cursor-style-blink = false`：减少视觉干扰。
- `scrollback-limit = 100000`：足够回溯。
- `shell-integration = detect` + `cursor,sudo,title`：自动 zsh 集成，无需手动改 rc。
- `copy-on-select = clipboard`：选中即复制（保留 iTerm2 习惯）。
- `mouse-hide-while-typing = true`。
- 视觉增强（与半透背景配合）：`background-blur = true`（macOS 原生毛玻璃）、`window-colorspace = display-p3`（Apple Silicon 宽色域，Aura 更饱满）、`window-padding-balance = true`（内容居中）、`adjust-cell-height = 2`（略增行高，长时间用眼更舒服）。
- 字体特性：`font-feature = calt`（启用 Maple Mono 连字）。
- 窗口管理：`window-save-state = always`（重启恢复窗口）、`resize-overlay = never`（拖窗口不弹尺寸浮层）；`unfocused-split-opacity` 保持默认 0.7。
- 更新策略：`auto-update = off`（由 brew cask 统一管理，关掉自带更新避免冲突）。
- **不改键位**：继承 profile「保持系统默认」原则，Ghostty 默认快捷键即用。

## 参考
- `configs/ghostty/config`（只读实物；本机落地在 `~/.config/ghostty/config`）

## 验证
```sh
ghostty --version                       # 期望：>= 1.3（stable）
ghostty +list-themes | grep -i aura     # 期望：列出 Aura
# 打开新 Ghostty 窗口：确认字体为 Maple Mono NF CN、配色为 Aura Dark
```
