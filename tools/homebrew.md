# tool: Homebrew

> **macOS peer 管理器**（与 mise 平级）：只管 GUI app（cask）+ 字体。**开发工具（runtime/CLI/build）已全部移交 mise**（见 `tools/mise.md`），brew 不再跨平台当统一入口。

## 为什么用
cask 是 macOS 上装 GUI 应用 / 字体最省事的入口；macOS 系统库补位也靠它。但 CLI 开发工具它不再是主力——mise 在跨平台一致性、per-user、声明式上更合适，且 brew-on-Linux 受限（bottle 只认标准 prefix `/home/linuxbrew/.linuxbrew`、单用户设计、多用户服务器别扭）。故 **brew 退守 macOS 不可替代的部分**。

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
| Linux | **不用 brew**。dev 工具走 mise；编译器/git 走 per-user（见 `tools/mise.md` / `scripts/bootstrap.sh`） |

> macOS 装完脚本会提示把 `eval "$(/opt/homebrew/bin/brew shellenv)"` 加进 `~/.zprofile`（本仓库 `configs/shell/env.sh` 已用 `export PATH="/opt/homebrew/bin:$PATH"` 覆盖）。

## 配置思路
- 用 **Brewfile** 维护装机清单，**只列 cask（GUI app）+ 字体**——CLI formula 不再入此清单（已归 mise）。
- 在新 macOS 用 `brew bundle install --file configs/homebrew/Brewfile` 一键复现。
- 定期 `brew bundle check --file configs/homebrew/Brewfile` 对账。
- 镜像（国内加速）：`HOMEBREW_API_DOMAIN` / `HOMEBREW_BOTTLE_DOMAIN` 设中科大 / 清华源（见 `configs/shell/env.sh`）。

## 参考
- `configs/homebrew/Brewfile`（只剩 cask + 字体）

## 验证
```sh
brew --version
brew doctor     # 无严重 warning
brew bundle check --file configs/homebrew/Brewfile
```
