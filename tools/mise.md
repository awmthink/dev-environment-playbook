# tool: mise

> 跨平台 dev 工具**版本管理器**：per-tool 安装 + 锁版本（`mise use`），装在 `$HOME`、macOS/Linux 一致。官方预编译二进制优先（不从源码编译 runtime）。

## 为什么用
- **per-tool 锁版本**：`mise use -g <tool>@<ver>` 一步完成「安装 + 设为全局默认」，agent 按各 `tools/*.md` 逐卡执行即可；**项目级** 在项目根放 `mise.toml`（提交进 git 做团队锁版本），进目录自动切。`~/.config/mise/config.toml` 是 mise 在 `use` 时自动维护的状态文件（记录已锁版本），**不手写、不 assemble**。替代 `.tool-versions` / nvm / pyenv。
- **per-user**：装在 `~/.local/share/mise`，免 sudo、进 `$HOME`、随用户备份迁移；多用户服务器各管各的，无共享 prefix 竞争。
- **跨平台**：同一份 config macOS/Linux 都生效，背后拉各平台官方预编译。

## 最低版本要求
- mise 本体：latest（单二进制，`mise up -i mise` 自更新）。

## 版本与安装策略

**多版本需求：是**——mise 本身就是多版本管理工具：**全局默认**写 `~/.config/mise/config.toml`，**项目级 override** 在项目根放 `mise.toml`（提交进项目 git 锁版本）；同一工具的不同版本进不同目录自动切换（PATH 注入、无 shim 开销），按需 lazy 下载。

**各平台安装**：

| 平台 | 推荐方式 |
|------|----------|
| macOS | `brew install mise` |
| Linux | `curl -LsSf https://mise.run \| sh`（装到 `~/.local/bin/mise`） |

激活（shell rc 末尾，幂等）：
```sh
eval "$(mise activate zsh)"   # bash 换 bash
```

## 配置思路
- **工作模式：agent 逐卡片安装，不 assemble manifest**——本仓库不存中央 mise 配置。agent 按推荐顺序（见 `tools/README.md`）读每个 `tools/*.md`，先**检测**（`mise current <tool>` / `mise ls`），缺或版本不符就**装**：每个 mise 工具一条 `mise use -g <tool>@<ver>`。`~/.config/mise/config.toml` 由 mise 在 `use` 时自动累加，是结果状态、不是输入。
  - 进 mise 的工具与对应卡片：`node`（`tools/node.md`）· `python` + `uv`（`tools/python.md`）· `go`（`tools/go.md`）· `rust`（`tools/rust.md`）· `cmake` + `ninja`（`tools/c-cpp.md`）· `npm:pyright` + `npm:@vtsls/language-server`（`tools/lsp.md`）。
- **项目级**：项目根 `mise.toml` override 全局（如某项目要 node 22）；提交进项目 git 做团队锁版本。
- **backend 选择**：runtime 走 `core:`（node/go/python/rust）；CLI 走 `aqua:` / `ubi:`；LSP 等走 `npm:` / `cargo:`（如 `mise use -g npm:pyright@latest`）。
- **装前必跑** `mise ls-remote <tool>` 确认可用性，不靠印象。

## 实操备注：mise 擅长 / 不擅长

mise 管 **需要多版本 / 锁版本的工具**——runtime（node/python/go/rust）+ build（cmake/ninja）+ LSP（pyright/vtsls）——很顺。以下几类**不进 mise**：

- **单文件 leaf CLI / 多路复用器**（**rg / jq / fzf / starship / zellij**）：官方/GitHub 预编译二进制最 canonical、最透明 → 直接装到 `~/.local/bin`（linux）/ brew（mac），无需版本管理层。
- **编译器（llvm）**：mise 走源码编译，慢 → 各平台另装（mac=Xcode CLT，linux=per-user 预编译 llvm，见 `tools/c-cpp.md`）。
- **git**：上游只发源码 → Linux 源码编译进 `~/.local`（见 `tools/git.md`）。
- **neovim**：官方预编译二进制 min glibc 2.32，老 distro 跑不了 → Linux 按 glibc 分流（见 `tools/neovim.md`）。

> 这是**实操取舍**，不是铁律——哪天上游有了好二进制，进 mise 也合理。

### 委托模式（mise 锁版本，专用工具当引擎）
- **rust**：mise 的 rust backend 底层就是 rustup（`mise use -g rust@1.97` 即用 rustup 装该 toolchain），`rustup component add rust-analyzer` 照旧。
- **uv**：mise 管 uv 二进制版本（`mise use -g uv@latest`）；但 uv 是独立工具，有自己的 `uv python` 能力，与 mise 装的解释器互不耦合（见 `tools/python.md`）。

## 参考
- 各 `tools/*.md` 的「版本与安装策略」（每卡片的 `mise use` 命令）
- `tools/README.md`（推荐安装顺序）

## 验证
```sh
mise --version
mise ls               # 已装工具及版本
mise current          # 当前目录生效的版本
mise ls-remote <tool> # 装前验证某工具可用性
```
