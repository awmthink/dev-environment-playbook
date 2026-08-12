# tool: Homebrew

> macOS 的事实包管理器，是大多数工具的安装入口。

## 为什么用
统一装机、版本可控、`Brewfile` 可复现、cask 管 GUI 应用。

## 版本约束
- 版本：latest（自动更新）

## 前置
- **Xcode Command Line Tools**：brew 依赖它。属 macOS 平台级前置，安装 / 验证 / 已知坑统一见 `platforms/macos.md`「开发者基础」。

## 安装

| 平台 | 方式 |
|------|------|
| macOS | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`（官方一键脚本，装到 `/opt/homebrew`，自动入 PATH） |
| Linux | 同一脚本：`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`（Linuxbrew，无 sudo，装用户目录）；开发工具首选，见下 |

> **安装校验**：脚本跑完后 `which brew` 应有输出；macOS 装到 `/opt/homebrew/bin/brew`，Apple Silicon 上脚本会提示把 `eval "$(/opt/homebrew/bin/brew shellenv)"` 加进 `~/.zprofile`（本仓库的 `configs/shell/env.sh` 已用 `export PATH="/opt/homebrew/bin:$PATH"` 覆盖，无需再写）。
>
> **Linux 策略**：发行版 apt/dnf/yum 的工具版本普遍偏旧，**开发工具优先用 Linuxbrew 装到用户目录自管**（无 sudo）。默认装到 `/home/linuxbrew/.linuxbrew`（多用户共享）或 `~/.homebrew`（纯用户隔离），shell rc 加 `eval "$(<brew-prefix>/bin/brew shellenv)"`。与 macOS 同一份 Brewfile 复现。

## 配置思路
- 用 **Brewfile** 维护装机清单（CLI + cask），放 `configs/homebrew/Brewfile`。
- 在新机器用 `brew bundle install --file configs/homebrew/Brewfile` 一键复现。
- 定期 `brew bundle check --file configs/homebrew/Brewfile` 对账（哪些没装 / 哪些多余）。
- GUI 应用优先 `cask`；开发库优先 `brew install`。
- **Brewfile 只收「跨机器核心」**：只列 `tools/` / `agents/` 明确声明、每台机器都要的工具（附注释指 playbook）。机器/工作/个人特定的工具（ffmpeg、gh、tmux、cursor、工作 npm 包等）不入此清单，各机自装——`brew bundle check` 只校验「清单内是否都装了」，不会因额外安装而报错；`brew bundle cleanup --force` 才会动未列项（慎用）。keg-only formula（`node@24`、`rustup`）用 `link: true` 表达 force-link。装完仍需跑各 playbook 的额外步骤（corepack / rustup default / 字体等）。

## 参考
- `configs/homebrew/Brewfile`（实物）

## 验证
```sh
brew --version
brew doctor     # 无严重 warning
```
