# tool: mise

> 跨平台 dev 工具的**声明式版本管理器**，与 brew **平级**。管 runtime + CLI + build 工具，per-user、装在 `$HOME`、macOS/Linux 同一份配置。

## 为什么用
- **声明式**：一份 `mise.toml` 描述所有工具版本，提交进 git → 团队/新机器版本一致（跨语言的 `.tool-versions` 替代品）。
- **per-user**：装在 `~/.local/share/mise`，免 sudo、进 `$HOME`、进备份；多用户服务器上各管各的，无共享 prefix 竞争（brew-on-Linux 的痛点）。
- **跨平台一致**：同一份 config 在 macOS/Linux 都生效，背后下载各平台官方二进制。
- **官方二进制优先**：runtime/CLI 走上游预编译，不从源码编译（快）；版本切换靠 PATH，零 shim 开销。
- 替代 nvm + pyenv + gvm + .nvmrc + .python-version 这一堆，一个工具一套机制。

## 版本约束
- 版本：latest（单二进制，自更新 `mise up -i mise` 或重装）

## 职责边界（很重要）

mise 是**平级管理器之一**，不是万能入口。明确分工：

| 归 mise 管 | 不归 mise（平级/外层） |
|------------|----------------------|
| **runtime**：node / go / python / rust | **编译器**：mac=Xcode CLT(apple clang)，linux=`~/.local` 预编译 llvm（源码编译太慢，见下） |
| **CLI**：rg / jq / starship / fzf / tmux | **git**：两端**源码编译**进 `~/.local`（上游无预编译，但 ~1min，统一版本） |
| | **neovim**：官方二进制 min glibc 2.32，老 distro 跑不了 → bootstrap.sh 按 glibc 分流（源码/二进制） |
| **build**：cmake / ninja | **CUDA / TensorRT**：外部（集群/NVIDIA，见 `tools/cuda.md`） |
| | **GUI app / 字体**：brew cask（macOS-only，见 `tools/homebrew.md`） |

> **为什么编译器/git/neovim 不进 mise**：mise 的弱项是编译器——llvm 走源码编译（慢）、无可用 gcc 插件；git 上游无预编译二进制；neovim 官方二进制对 glibc 要求高（见各 `tools/*.md`）。这几类归 `bootstrap.sh` 平台适配。**写 config 前逐个 `mise ls-remote <tool>` 验证可用性**，不靠印象。

### 委托模式（mise 当"声明层"，专用工具当"引擎"）
- **uv**：mise 管 uv 二进制版本（`uv = "latest"`，aqua backend 拉预编译）。uv 是 python 的**项目 venv/依赖引擎**——但注意：mise 装的 `python`（默认 backend）与 `uv` 是**两个独立的 mise 工具**，uv 不是 mise 装 python 的 backend（那是 uv 自己的 `uv python` 能力，互不耦合）。
- **rust**：mise 的 rust backend **底层就是 rustup**（`rust = "1.97"` 走 rustup），`rustup component add rust-analyzer` 等照旧。
- node / go：mise 直接管（这俩它最擅长）。

## 安装

| 平台 | 方式 |
|------|------|
| macOS / Linux | `curl -LsSf https://mise.run \| sh`（装到 `~/.local/bin/mise`），或从 github.com/jdx/mise releases 拉二进制 |

激活（shell rc 末尾，幂等）：
```sh
eval "$(mise activate bash)"   # bash；zsh 换 zsh
```

## 配置思路
- **全局默认**：`~/.config/mise/config.toml`（仓库实物 `configs/mise/config.toml` 落地）——跨机器核心工具集 + 版本。
- **项目级**：项目根 `mise.toml`——override 全局（如某项目要 node 22、某项目要特定 CLI 版本）；提交进项目 git 做团队锁版本。
- **backend 选择**：runtime 走 `core:`（node/go/python/rust）；CLI 走 `aqua:` / `ubi:`（registry 自动选，或显式 `"ubi:owner/repo"`）；LSP 等走 `npm:` / `cargo:`。
- **postinstall**：如 node 装完启用 corepack → `node = { version = "24", postinstall = "corepack enable" }`。
- **跨平台**：`os = ["linux","macos"]` 限制平台；同一 config 两端通用。
- **版本策略**：全局默认选"应用广泛、不追新"的稳定版；项目按需 override 更新版。

## 参考
- `configs/mise/config.toml`（全局默认实物）
- `scripts/bootstrap.sh`（编排：mise install + brew bundle[mac] + linux per-user llvm/git）

## 验证
```sh
mise --version
mise ls               # 已装工具及版本
mise current          # 当前目录生效的版本
# 验证某工具能否进 mise（写进 config 前必跑）：
mise ls-remote <tool>
```
