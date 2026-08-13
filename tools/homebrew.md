# tool: Homebrew

> **macOS 包管理器**：cask（GUI app + 字体）+ formula（不需要多版本的 CLI 工具）。runtime / build / LSP 归 mise（见 `tools/mise.md`）。按 core principle（不追求安装方法统一）逐工具评估——brew 收回 macOS 上 canonical 的 CLI formula，mise 只管真正需要多版本 / 锁版本的部分。

## 为什么用
cask 是 macOS 上装 GUI 应用 / 字体最省事的入口；macOS 系统库补位也靠它。CLI 工具按是否需要多版本分两档：**不需要多版本的日用品 CLI**（rg / jq / fzf / fd / starship / zellij）brew formula 最 canonical，安装命令记在各 `tools/*.md`；**需要多版本 / 锁版本的 runtime & build & LSP**（node / python / go / rust / cmake / pyright…）交 mise。brew-on-Linux 受限（bottle 只认标准 prefix `/home/linuxbrew/.linuxbrew`、单用户设计、多用户服务器别扭），故 brew 不上 Linux server。

## 最低版本要求
- 版本：latest（自动更新）

## 前置
- **Xcode Command Line Tools**：macOS 编译 / SDK 的唯一来源（系统头、frameworks 只在 CLT/Xcode 里），brew 与所有原生编译都依赖它。属 macOS 平台级前置，安装 / 验证见 `platforms/macos.md`「开发者基础」。**不可省**——即使编译器用 mise/brew 的 llvm，跑原生代码仍需 CLT 的 SDK。

## 版本与安装策略

**多版本需求：不适用**——brew 是包管理器，本身不做工具版本管理（多版本需求交给 mise / 各语言版本管理器）。

**各平台安装**：

| 平台 | 推荐方式 |
|------|----------|
| macOS | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`（装到 `/opt/homebrew`） |
| Linux | **不用 brew**。runtime/build/LSP 走 mise；CLI 日用品 / 多路复用器走 per-user（官方/GitHub 预编译 → `~/.local/bin`，见 `platforms/linux.md` / `tools/README.md`）；编译器/git/neovim 走 per-user（预编译/源码） |

> macOS 装完脚本会提示把 `eval "$(/opt/homebrew/bin/brew shellenv)"` 加进 `~/.zprofile`（本仓库 `configs/shell/env.sh` 已用 `export PATH="/opt/homebrew/bin:$PATH"` 覆盖）。

## 配置思路
- **不维护中央 Brewfile**——每个工具的 `brew install` / `brew install --cask` 命令记在它自己的 `tools/*.md`（formula：rg/jq/fzf/fd/starship/zellij 等；cask：zed/ghostty/字体）。装机清单 = 各工具卡片的并集，agent 按 platform 读卡片逐个装。
- runtime / build / LSP 不走 brew（归 mise，见 `tools/mise.md`）。
- 镜像（国内加速）：`HOMEBREW_API_DOMAIN` / `HOMEBREW_BOTTLE_DOMAIN` 设中科大 / 清华源（见 `configs/shell/env.sh`）。

## 参考
- 各 `tools/*.md`（brew formula / cask 安装命令的来源）

## 验证
```sh
brew --version
brew doctor     # 无严重 warning
```
