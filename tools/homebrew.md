# tool: Homebrew

> macOS 的事实包管理器，是大多数工具的安装入口。

## 为什么用
统一装机、版本可控、`Brewfile` 可复现、cask 管 GUI 应用。

## 版本约束
- 版本：latest（自动更新）

## 安装

| 平台 | 方式 |
|------|------|
| macOS | 官方一键脚本（见 brew.sh） |
| Linux | Linuxbrew（无 sudo，装用户目录）；开发工具首选，见下 |

> **Linux 策略**：发行版 apt/dnf/yum 的工具版本普遍偏旧，**开发工具优先用 Linuxbrew 装到用户目录自管**（无 sudo）。装到 `/home/linuxbrew/.linuxbrew`（多用户共享）或 `~/.homebrew`（纯用户隔离），shell rc 加 `eval "$(<brew-prefix>/bin/brew shellenv)"`。与 macOS 同一份 Brewfile 复现。

## 配置思路
- 用 **Brewfile** 维护装机清单（CLI + cask），放 `configs/Brewfile`。
- 在新机器用 `brew bundle install --file configs/Brewfile` 一键复现。
- 定期 `brew bundle check` 对账（哪些没装 / 哪些多余）。
- GUI 应用优先 `cask`；开发库优先 `brew install`。

## 参考
- `configs/Brewfile`（实物，待补充）

## 验证
```sh
brew --version
brew doctor     # 无严重 warning
```
