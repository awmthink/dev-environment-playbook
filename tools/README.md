# tools/ — 工具 playbook

每个开发工具一篇 `.md`，记录「我要什么 + 为什么 + 版本 + 验证」。新增工具时复制 `_template.md`。

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
