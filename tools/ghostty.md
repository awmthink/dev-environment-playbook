# tool: Ghostty

> macOS 主力终端（GPU / Metal 渲染），从 iTerm2 切换而来。

## 为什么用
GPU(Metal) 渲染流畅、原生 macOS 体验、单文件 `key = value` 配置简洁可读；**内置 Aura 主题**直接命中 profile 的 Aura Dark 偏好（无需自定义主题文件）；shell 集成开箱即用；启动快。iTerm2 成熟稳定，作为备选保留。

## 最低版本要求
- 版本：>= 1.3（stable channel；当前 1.3.1）

## 版本与安装策略

**多版本需求：否**——终端应用全局单一即可。

**各平台安装**：

| 平台 | 推荐方式 |
|------|----------|
| macOS | `brew install --cask ghostty` |

> Linux 定位为 headless 服务器（见 `platforms/linux.md`），**不装 GUI 终端**。Linux 只作为 Ghostty 的 **SSH 远程登录目标机**——仅需处理 `xterm-ghostty` terminfo（见下方「远程登录（SSH）」），无需安装 Ghostty 本体。

> macOS 已知：该 cask **只装 `Ghostty.app`，不往全局 PATH 链 `ghostty` CLI**（只链了 manpage / shell completion）。但 **Ghostty 启动的 shell 会自动把 `/Applications/Ghostty.app/Contents/MacOS` 注入 PATH**（即 `TERM_PROGRAM=ghostty` 时）——所以在 Ghostty 窗口内裸 `ghostty` 直接可用；只有从 iTerm / Terminal.app 等**别的终端**调用时才需要完整路径。无需为此建软链。

## 配置思路
配置文件：`~/.config/ghostty/config`（`key = value`，单文件）。整份参考见 `configs/ghostty/config`，关键项与理由：

- `theme = Aura`：内置主题，命中 profile 的 Aura Dark 偏好，无需自定义主题文件。
- `font-family = "Maple Mono NF CN"`：profile 主力字体（中英混排对齐、覆盖图标 / CJK）；备选 JetBrainsMono Nerd Font。
  - 字体安装：`brew install --cask font-maple-mono-nf-cn`。
- `macos-titlebar-style = transparent` + `background-opacity = 0.96`：沉浸感 + 长时用眼柔和。
- `cursor-style = block` + `cursor-style-blink = false`：减少视觉干扰。
- `scrollback-limit = 100000`：足够回溯。
- `shell-integration = detect` + `cursor,sudo,title,ssh-env`：自动 zsh 集成，无需手动改 rc。
  - `ssh-env`（必选，治本）：SSH 时自动把 `TERM` 从 `xterm-ghostty` 转成 `xterm-256color`（所有服务器都有），并传播 `COLORTERM`/`TERM_PROGRAM`/`TERM_PROGRAM_VERSION`。**已知坑：不加它，ssh 到没有 `xterm-ghostty` terminfo 的 Linux 服务器时，远端 bash 的 readline / clear / less / vim 全坏**（方向键乱码、退格失效等）。
  - `sudo`：包装 sudo 以保留 terminfo（避免 sudo 后环境里的终端能力丢失）。
  - **不用 `ssh-terminfo`**：它会往远端写 terminfo（副作用），不符合「零副作用」偏好；`ssh-env` 的 TERM 转换已能覆盖所有服务器。
- `copy-on-select = clipboard`：选中即复制（保留 iTerm2 习惯）。
- `mouse-hide-while-typing = true`。
- 视觉增强（与半透背景配合）：`background-blur = true`（macOS 原生毛玻璃）、`window-colorspace = display-p3`（Apple Silicon 宽色域，Aura 更饱满）、`window-padding-balance = true`（内容居中）、`adjust-cell-height = 2`（略增行高，长时间用眼更舒服）。
- 字体特性：`font-feature = calt`（启用 Maple Mono 连字）。
- 窗口管理：`window-save-state = always`（重启恢复窗口）、`resize-overlay = never`（拖窗口不弹尺寸浮层）；`unfocused-split-opacity` 保持默认 0.7。
- 更新策略：`auto-update = off`（由 brew cask 统一管理，关掉自带更新避免冲突）。
- **不改键位**：继承 profile「保持系统默认」原则，Ghostty 默认快捷键即用。

## 参考
- `configs/ghostty/config`（只读实物；本机落地在 `~/.config/ghostty/config`）
- `configs/ghostty/terminfo/xterm-ghostty`（terminfo 源文件，见下方「远程登录」）

## 远程登录（SSH）
Ghostty 会把 `TERM=xterm-ghostty` 传给 SSH 目标机。ncurses **6.5-20241228 起**才内置该条目，旧发行版（如 CentOS 8 的 ncurses 6.1）的 terminfo 库里没有，于是 `clear` 等报 `terminals database is inaccessible` / `unknown terminal type`。

- **首选（零副作用、自动）**：本机已启用 `ssh-env`（见上方 shell 集成）。SSH 时自动把 `TERM` 从 `xterm-ghostty` 转成 `xterm-256color`（所有服务器都有），并传播 `COLORTERM`/`TERM_PROGRAM`/`TERM_PROGRAM_VERSION`。不改远端任何文件、零安装。**依赖 shell 集成包裹 `ssh` 命令**：需在 Ghostty 窗口内、zsh 集成已加载时直接敲 `ssh`；从脚本或其它终端发起的 ssh 不生效。
- **可选（保留完整能力）**：想保留 `xterm-ghostty` 全部能力（彩色下划线、真彩检测等）时，把条目装到目标机用户目录（免 sudo、符合平台 user-local 约定），一劳永逸：
  ```sh
  tic -x configs/ghostty/terminfo/xterm-ghostty
  ```
  `tic` 默认写系统库、无权限时落到 `~/.terminfo`；如需强制 user-local 可设 `TERMINFO=~/.terminfo`。源文件由官方 `src/terminfo/ghostty.zig` 生成并入库，新机器不必再从网络拉取。
- **坑：conda 环境的 ncurses 只认 hex 目录布局**。conda-forge ncurses ≥6.5 构建查找 terminfo 时只按首字符的十六进制目录（如 `x` → `~/.terminfo/78/`、`g` → `~/.terminfo/67/`），不读 `tic` 默认写入的字母目录（`x/`、`g/`）。在激活了 conda 环境的机器上（PATH 里 `clear`/`tput` 解析到 `$CONDA_PREFIX/bin`），会再次报 `terminals database is inaccessible`。补一份硬链接即可（幂等）：
  ```sh
  mkdir -p ~/.terminfo/78 ~/.terminfo/67
  ln -f ~/.terminfo/x/xterm-ghostty ~/.terminfo/78/xterm-ghostty
  ln -f ~/.terminfo/g/ghostty       ~/.terminfo/67/ghostty
  ```
  硬链接让字母 / hex 两种布局共享同一份数据，系统 ncurses（字母布局）不受影响。
- **兜底**：SSH 配置 `SetEnv TERM=xterm-256color`（OpenSSH 8.7+）。不依赖 shell 集成，适合脚本或非 Ghostty 终端发起 ssh 的场景；但会丢失 Ghostty 增强能力。

## 验证
> 在 **Ghostty 窗口内**运行（Ghostty 会把自身注入 PATH，裸 `ghostty` 可用）；从其它终端（iTerm 等）跑需换成完整路径 `/Applications/Ghostty.app/Contents/MacOS/ghostty`。

```sh
ghostty --version                       # 期望：>= 1.3（stable）
ghostty +list-themes | grep -i aura     # 期望：列出 Aura
# 打开新 Ghostty 窗口：确认字体为 Maple Mono NF CN、配色为 Aura Dark
```

远程登录后的验证（走 `ssh-env`，默认）：

```sh
ssh <host> 'echo $TERM'    # 期望：xterm-256color
ssh <host> 'tput colors'   # 期望：256
```

走 terminfo 安装路线的，改为验证：

```sh
infocmp -x xterm-ghostty >/dev/null && echo OK   # 期望：OK
```
