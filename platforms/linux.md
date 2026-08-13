# platform: Linux

> 在 Linux 上执行配置时的平台上下文。先读本文件再动 `tools/`。

## 适用范围（重要）

本文件所指 **Linux = 无桌面 headless 服务器**（GPU 训练机 / 远程开发目标机等），**不含桌面环境、不含任何 GUI 需求**。因此：

- **GUI-only 工具在 Linux 平台一律不安装 / 不配置**——Zed、Ghostty 等 GUI 应用只考虑 macOS；它们的 `tools/*.md` 不再给出 Linux 安装路径。
- Linux 上只关心这些工具的 **CLI / 服务端 / headless 部分**（如 Zed Remote 的远端 server 进程、Ghostty 的 `xterm-ghostty` terminfo 条目、Neovim 终端版）。
- **字体（Nerd Font 等）属桌面端需求**，不在 Linux 考虑范围。

## 发行版（按实际情况补充）

<!-- 列出你常用的发行版，以及各自包管理器 -->

| 发行版 | 包管理器 | 备注 |
|--------|----------|------|
| Ubuntu / Debian | apt | |
| Arch | pacman / yay | |
| Fedora | dnf | |
| CentOS / RHEL 8+ | dnf（EOL 后需切 vault 源） | GPU 服务器常见；老版 gcc/llvm/cmake 偏旧 → 走 mise + per-user llvm（见下） |

## 通用约定
- **开发工具优先 user-local 自管**：发行版 apt/dnf/yum 版本普遍偏旧，开发工具（git/node/go/rust/uv 等）不依赖系统源，装到用户目录自行管理版本（见下方「user-local 包管理」与各 `tools/*.md`）。
- 发行版包管理器仅用于：系统基础库、服务、无法 user-local 的底层依赖。
- 默认 shell 多为 bash；切换：`chsh -s <shell>`。

## 安装目录约定（user-local，优先）
- **优先装到用户目录、不用 sudo**，避免污染 / 管系统、方便随用户迁移。
- **通用 user-local bin：`~/.local/bin`**——各类安装脚本、`pip --user`、`uv`、`cargo install` 之外的小工具都放这里。
- 常见用户级 bin 目录（都需加入 PATH，见 `tools/shell.md`）：
  - `~/.local/bin`（通用首选）
  - `~/.cargo/bin`（Rust / rustup）
  - `~/go/bin`（`go install` 产物）
- 安装脚本默认目标为 `/usr/local/bin` 时，能加 `--prefix` / `-b` 等参数就改到 `~/.local`。
- `~/.local/bin` 要在 PATH **靠前**，避免被系统旧版本覆盖；`.profile` 默认会自动加，确认即可。

## user-local 包管理（开发工具）
> Linux 发行版源版本偏旧，开发工具按「是否需要多版本」分流，装到用户目录自管。agent 逐卡片检测+安装（顺序见 `tools/README.md`）；per-tool 版本/命令都在卡片里，本表只给「哪类走哪条路」。

| 类别 | 工具 | 走哪条路 | 卡片 |
|------|------|---------|------|
| 需多版本/锁版本 | node/python/go/rust · cmake/ninja · pyright/vtsls | **mise**（per-user `~/.local/share/mise`） | `tools/mise.md` + 各 runtime 卡片 |
| 编译器 | llvm（clang/clangd） | per-user 预编译 tarball → `~/.local/llvm-*` | `tools/c-cpp.md` |
| 编辑器 | neovim | glibc 分流（源码 / 官方二进制）→ `~/.local/bin` | `tools/neovim.md` |
| 版本控制 | git | 源码编译 → `~/.local/bin` | `tools/git.md` |
| leaf CLI | rg / jq / fzf | 官方/GitHub 预编译 → `~/.local/bin` | `tools/cli-utils.md` |
| 多路复用 / 提示符 | zellij / starship | 官方/GitHub 预编译 → `~/.local/bin` | `tools/zellij.md` / `tools/shell.md` |

- **不在 Linux 用 brew**：brew-on-Linux 受限（bottle 只认标准 prefix `/home/linuxbrew/.linuxbrew`、单用户设计、多用户共享服务器别扭），dev 工具改由 mise + per-user 接管。brew 退回 macOS 专属。
- **单文件 CLI**：`cargo install` / `go install` / `uv tool install`，产物进对应 bin 目录。
- **判定原则**：leaf 单文件 CLI / 多路复用器优先官方/GitHub 预编译（最 canonical、最透明，musl 静态版跨 glibc）；发行版 dnf 源偏旧/不可靠，不依赖。

## 常用探测命令
- 发行版：`cat /etc/os-release`
- 包管理器：`which apt dnf pacman 2>/dev/null`
- 架构：`uname -m`
