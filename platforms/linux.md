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
> Linux 发行版源版本偏旧，开发工具用以下方式装到用户目录、自行管理版本。

- **mise（主力）**：**需要多版本 / 锁版本的工具**——runtime（node/python/go/rust）+ build（cmake/ninja）+ LSP（pyright/vtsls），各 `tools/*.md` 给出 `mise use -g` 命令，agent 逐卡片检测+安装（config.toml 由 mise 自动维护、不 assemble），per-user 装在 `~/.local/share/mise`（见 `tools/mise.md`）。CLI 日用品 / 编译器 / git / neovim 不进 mise（见下）。
- **不在 Linux 用 brew**：brew-on-Linux 受限（bottle 只认标准 prefix `/home/linuxbrew/.linuxbrew`、单用户设计、多用户共享服务器别扭），dev 工具改由 mise + per-user 接管。brew 退回 macOS 专属（cask + 字体 + CLI formula）。
- **per-user `~/.local`（mise 之外）**：
  - **编译器**：预编译 llvm 18.1.8（`~/.local/llvm-18.1.8`，CUDA 12.8 要 clang<20）——LLVM 不发 macOS 预编译、且 mise-llvm 走源码编译太慢，故 Linux 走 per-user 预编译（见 `tools/c-cpp.md`）。
  - **git**：源码编译（~1min，两端统一版本；上游无预编译，不进 mise）。
  - **rg / jq / fzf / starship / zellij**：官方/GitHub 预编译单文件二进制 → `~/.local/bin`（starship 官方 installer；rg/jq/fzf/zellij 取 GitHub release，rg/zellij 用 musl 静态版跨 glibc）。具体命令见 `tools/cli-utils.md`（rg/jq/fzf）、`tools/shell.md`（starship）、`tools/zellij.md`（zellij）。
- **单文件 CLI**：`cargo install` / `go install` / `uv tool install`，产物进对应 bin 目录。

## CLI 日用品（CentOS 8，按 core principle 逐工具评估）
> 不需要多版本、不进跨平台 mise config；按「最 canonical 来源」决定 dnf / 官方预编译 / mise。

| 工具 | CentOS 8 系统版 | 判定 | 安装 |
|------|----------------|------|------|
| jq | AppStream 1.6 | 官方预编译最 canonical（静态单文件） | GitHub release `jq-linux-amd64` → `~/.local/bin` |
| ripgrep (rg) | EPEL（偏旧） | 官方预编译最 canonical（musl 静态） | GitHub release `ripgrep-*-x86_64-unknown-linux-musl.tar.gz` → `~/.local/bin` |
| zellij | 无 | 官方预编译最 canonical（musl 静态） | GitHub release `zellij-x86_64-unknown-linux-musl.tar.gz` → `~/.local/bin`（替代 tmux，见 `tools/zellij.md`） |
| fzf | EPEL 不可靠 | GitHub 预编译最 canonical（单文件） | GitHub release `fzf-*-linux_amd64.tar.gz` → `~/.local/bin`（shell keybinds 另配） |
| starship | 无 dnf 包 | 官方 installer 最 canonical | `curl -sS https://starship.rs/install.sh \| sh -s -- -b ~/.local/bin` |

> **判定原则**：leaf 单文件 CLI / 多路复用器优先官方/GitHub 预编译二进制（最 canonical、最透明）→ `~/.local/bin`。不再依赖系统 dnf 版本（发行版源偏旧/不可靠）。安装命令：rg/jq/fzf 见 `tools/cli-utils.md`；starship 见 `tools/shell.md`；zellij/llvm/git/nvim 见各自 `tools/*.md`。

## 常用探测命令
- 发行版：`cat /etc/os-release`
- 包管理器：`which apt dnf pacman 2>/dev/null`
- 架构：`uname -m`
