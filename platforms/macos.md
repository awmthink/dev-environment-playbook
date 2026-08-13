# platform: macOS

> 在 macOS 上执行配置时的平台上下文。先读本文件再动 `tools/`。

## 包管理
- 首选 **Homebrew**（`brew install`）。安装方式见 `tools/homebrew.md`（官方一键脚本，具体命令在彼处）。
- 不维护中央 Brewfile——各工具的 `brew install` / `brew install --cask` 命令记在对应 `tools/*.md`，按卡片逐个装（装机清单 = 工具卡片的并集）。
- GUI 应用优先 `brew install --cask`。

## 开发者基础：Xcode Command Line Tools（CLT）
> macOS 上几乎所有开发工具的前置。属**平台级**，是 Homebrew、clang/clangd（见 `tools/c-cpp.md`、`tools/lsp.md`）、系统 git、编译头文件的共同依赖——故在此统一记录，各 `tools/*.md` 只引用、不重复。

- 安装：`xcode-select --install`（弹窗引导；无需装完整 Xcode）。Homebrew 安装脚本也会自动触发。
- 验证：`xcode-select -p` 输出 `/Library/Developer/CommandLineTools`（或 Xcode.app 路径）；`clang --version`、`clangd --version` 有输出。
- 已知坑：**升级 macOS 大版本后 CLT 偶尔失效**（编译报错 / brew 报缺头文件），重装即可：`sudo rm -rf /Library/Developer/CommandLineTools && xcode-select --install`。

## 默认值与已知坑
- 默认 shell 是 zsh；切换默认 shell：`chsh -s <shell>`。
- `defaults write ...` 用于系统 / 应用偏好（记录在 `configs/` 时注明对应 `defaults` 命令）。
- 文件名大小写不敏感 —— clone 仓库时注意。
- Apple Silicon vs Intel：注意架构相关二进制（用 `uname -m` 判断）。

## 常用探测命令
- OS 版本：`sw_vers`
- 架构：`uname -m`
- CLT 是否就绪：`xcode-select -p`
- brew 是否就绪：`which brew`
