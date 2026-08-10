# platform: macOS

> 在 macOS 上执行配置时的平台上下文。先读本文件再动 `tools/`。

## 包管理
- 首选 **Homebrew**（`brew install`）。安装命令：见官网一键脚本。
- Brewfile 来源：`configs/`（如有）。可用 `brew bundle` 批量安装。
- GUI 应用优先 `brew install --cask`。

## 默认值与已知坑
- 默认 shell 是 zsh；切换默认 shell：`chsh -s <shell>`。
- `defaults write ...` 用于系统 / 应用偏好（记录在 `configs/` 时注明对应 `defaults` 命令）。
- 文件名大小写不敏感 —— clone 仓库时注意。
- Apple Silicon vs Intel：注意架构相关二进制（用 `uname -m` 判断）。

## 常用探测命令
- OS 版本：`sw_vers`
- 架构：`uname -m`
- brew 是否就绪：`which brew`
