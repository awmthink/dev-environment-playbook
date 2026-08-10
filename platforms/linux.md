# platform: Linux

> 在 Linux 上执行配置时的平台上下文。先读本文件再动 `tools/`。

## 发行版（按实际情况补充）

<!-- 列出你常用的发行版，以及各自包管理器 -->

| 发行版 | 包管理器 | 备注 |
|--------|----------|------|
| Ubuntu / Debian | apt | |
| Arch | pacman / yay | |
| Fedora | dnf | |

## 通用约定
- 优先发行版自带包管理器；版本过旧时再用官方安装器 / 版本管理器（见各 `tools/*.md`）。
- 默认 shell 多为 bash；切换：`chsh -s <shell>`。

## 安装目录约定（user-local，优先）
- **优先装到用户目录、不用 sudo**，避免污染 / 管系统、方便随用户迁移。
- **通用 user-local bin：`~/.local/bin`**——各类安装脚本、`pip --user`、`uv`、`cargo install` 之外的小工具都放这里。
- 常见用户级 bin 目录（都需加入 PATH，见 `tools/shell.md`）：
  - `~/.local/bin`（通用首选）
  - `~/.cargo/bin`（Rust / rustup）
  - `~/go/bin`（`go install` 产物）
  - `~/.local/share/mise/shims`（若用 mise）
- 安装脚本默认目标为 `/usr/local/bin` 时，能加 `--prefix` / `-b` 等参数就改到 `~/.local`。
- `~/.local/bin` 要在 PATH **靠前**，避免被系统旧版本覆盖；`.profile` 默认会自动加，确认即可。

## 常用探测命令
- 发行版：`cat /etc/os-release`
- 包管理器：`which apt dnf pacman 2>/dev/null`
- 架构：`uname -m`
