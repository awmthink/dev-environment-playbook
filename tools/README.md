# tools/ — 工具 playbook

每个开发工具一篇 `.md`，记录「我要什么 + 为什么 + 版本 + 验证」。新增工具时复制 `_template.md`。

## agent 工作模式：逐卡片「检测 → 安装」

> **不 assemble 中央 manifest**。agent 按下面的**推荐顺序**逐个读卡片，每张卡片独立完成「检测现状 → 缺/旧则装 → 验证」。mise 的 `~/.config/mise/config.toml` 与 brew 状态由工具在 `use` / `install` 时自行维护，agent 不手写。

### 推荐安装顺序（按依赖分层）
1. **shell 基座**：`shell.md`（rc / env.sh / PATH / starship 钩子）——一切的前置
2. **版本管理器**：`mise.md`——runtime/build/LSP 都依赖它
3. **runtime**（mise）：`node.md` → `python.md`(含 uv) → `go.md` → `rust.md`
4. **build**（mise）：`c-cpp.md` 的 cmake/ninja
5. **LSP**（依赖各 runtime）：`lsp.md`（pyright/vtsls 随 node；rust-analyzer 随 rust；gopls 随 go）
6. **CLI 增强与多路复用**：`cli-utils.md`(rg/jq/fzf) · `zellij.md`
7. **编译器 / git / 编辑器**（per-user 预编译或源码）：`c-cpp.md`(llvm) · `git.md` · `neovim.md`
8. **GPU（仅 GPU 机）**：`cuda.md`（最后，依赖 llvm/CUDA 兼容区间）
9. **macOS 桌面补充**（仅 mac）：`zed.md` · `ghostty.md` · `fonts.md`
10. **网络**：`proxy.md`（按需）

> 顺序非强制——仅是「依赖在前、叶子在后」的默认走法；agent 按用户请求的「配置 X」跳到对应卡片即可，缺依赖时回上层补。

## 索引

<!-- 在这里维护工具清单，方便 agent 和你快速定位 -->

| 工具 | 文件 | 状态 |
|------|------|------|
| **mise** | `mise.md` | 已写（版本管理器：runtime + build + LSP，跨平台 per-user） |
| Homebrew | `homebrew.md` | 已写（**macOS 包管理器**：cask（GUI + 字体）+ CLI formula） |
| Git | `git.md` | 已写（源码编译进 ~/.local，两端统一） |
| Zellij | `zellij.md` | 已写（多路复用，**替代 tmux**；linux=GitHub 二进制 / mac=brew） |
| Shell (zsh/bash + Starship) | `shell.md` | 已写（登录 shell + 提示符；starship 合入此卡片） |
| CLI 增强工具 (rg/jq/fzf) | `cli-utils.md` | 已写（shell 增强工具：搜索 / JSON / 模糊查找） |
| 网络代理 | `proxy.md` | 已写 |
| Node.js + pnpm | `node.md` | 已写（mise 管 node；pnpm via corepack） |
| Python + uv | `python.md` | 已写（mise 管 python；uv 作项目引擎） |
| Go | `go.md` | 已写（mise 管） |
| Rust | `rust.md` | 已写（mise 管，rustup engine） |
| C/C++ | `c-cpp.md` | 已写（编译器平台原生：mac=CLT / linux=per-user llvm；cmake/ninja 走 mise） |
| CUDA / TensorRT | `cuda.md` | 已写（外部 toolchain） |
| Ghostty | `ghostty.md` | 已写（macOS 主力终端） |
| iTerm2 | — | 备选 / 待写 |
| Zed（GUI 主力） | `zed.md` | 已写 |
| 字体（Nerd Font） | `fonts.md` | 已写（macOS cask；主力 Maple Mono NF CN / 备选 JetBrainsMono） |
| Neovim（terminal 主力） | `neovim.md` | 已写 |
| LSP servers（跨编辑器） | `lsp.md` | 已写（pyright/vtsls 走 mise；clangd 走平台 llvm） |
| Docker | — | 待写 |
| lazygit | — | 待评估（见 `profile.md`） |

## 基础 CLI 工具

> leaf 单文件、无需多版本、按 core principle 各平台选最 canonical 方式（mac=brew formula；linux=官方/GitHub 预编译 → `~/.local/bin`，见 `platforms/linux.md`）。

| 工具 | 归属 | 说明 |
|------|------|------|
| ripgrep / jq / fzf | `tools/cli-utils.md` | shell 增强工具（搜索 / JSON / 模糊查找），独立卡片 |
| starship / Zellij | `tools/shell.md` / `tools/zellij.md` | starship 合入 shell 卡片 |
| cmake / ninja | `tools/c-cpp.md` | 构建（走 mise） |
| gh | — | 待定（GitHub CLI，见 `profile.md` 候选） |


## 写作要点（给人和 agent）
- 写**意图与理由**，不是只贴 dotfile。
- **验证**步骤必须是可直接执行的命令。
- 最低版本明确：`>=x` / `pin x.y.z` / `latest`。
- 每篇必含「**版本与安装策略**」一节——把「多版本需求」与「各平台安装」**合并写**：多版本需求决定安装方式（需要多版本→版本管理器 mise/rustup/uv；不需要→每平台选最轻方案），需求与装法因果连贯，不拆两节。
- 「各平台安装」是**推荐方案，不是铁律**：macOS 优先 brew，Linux 按工具权衡（系统包 / mise / build-from-source→`~/.local`）。
- 平台差异尽量交给 agent，除非有必须记录的坑（那就写进 `platforms/`）。
