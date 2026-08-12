# platform: Linux

> 在 Linux 上执行配置时的平台上下文。先读本文件再动 `tools/`。

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

- **mise（主力）**：runtime（node/python/go/rust）+ CLI（rg/jq/starship/fzf/tmux/neovim）+ build（cmake/ninja）全部声明在 `configs/mise/config.toml`，per-user 装在 `~/.local/share/mise`。跨平台与 macOS 一致（见 `tools/mise.md`）。
- **不在 Linux 用 brew**：brew-on-Linux 受限（bottle 只认标准 prefix `/home/linuxbrew/.linuxbrew`、单用户设计、多用户共享服务器别扭），dev 工具改由 mise 接管。brew 退回 macOS 专属（cask + 字体）。
- **per-user `~/.local`（mise 之外）**：
  - **编译器**：预编译 llvm 18.1.8（`~/.local/llvm-18.1.8`，CUDA 12.8 要 clang<20）——LLVM 不发 macOS 预编译、且 mise-llvm 走源码编译太慢，故 Linux 走 per-user 预编译（见 `tools/c-cpp.md`）。
  - **git**：源码编译（~1min，两端统一版本；上游无预编译，不进 mise）。
  - 见 `scripts/bootstrap.sh` 自动安装。
- **单文件 CLI**：`cargo install` / `go install` / `uv tool install`，产物进对应 bin 目录。

## 常用探测命令
- 发行版：`cat /etc/os-release`
- 包管理器：`which apt dnf pacman 2>/dev/null`
- 架构：`uname -m`
