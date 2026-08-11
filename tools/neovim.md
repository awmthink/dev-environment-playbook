# tool: Neovim

> terminal 编辑器主力（见 `profile.md`），与 Zed 分工：Zed 做 GUI 主力，Neovim 做终端 / 远程服务器场景。**定位：读代码 + LSP**；**故意不装补全**——写代码交给 coding agent（opencode / claude-code / codex / qoder-cli）。

## 为什么用
终端原生、远程服务器（SSH）友好；LSP 生态成熟，读代码（定义跳转 / 引用 / 悬浮文档 / 诊断）体验完整；启动快、SSH 下零额外开销。补全 / 写代码交给专用 agent，Neovim 专注「看」。

## 版本约束
- 版本：>= 0.11（内置 `vim.treesitter` 高亮 / 缩进）；当前 **0.12.4**
- 安装：`brew install neovim`

## 依赖
- **ripgrep**：telescope 的 live_grep 必需 → `brew install ripgrep`
- **tree-sitter CLI**：nvim-treesitter 编译 parser 必需 → `npm install -g tree-sitter-cli`（或 `cargo install tree-sitter-cli`）
- **语言运行时**（LSP server 安装依赖）：node / python / go / cargo——已由 mise / brew 覆盖

## 安装

| 平台 | 方式 |
|------|------|
| macOS | `brew install neovim ripgrep` + `npm install -g tree-sitter-cli` |
| Linux | Linuxbrew 同上；或发行版源（版本可能旧，不推荐） |

> 首次启动自动 bootstrap lazy.nvim 并装插件；LSP servers 通过 `:MasonInstall` 装（首次打开对应语言文件后）。

## 配置位置
- 入口：`~/.config/nvim/init.lua`
- 选项 / 键位：`~/.config/nvim/lua/options.lua`、`keymaps.lua`
- 插件：`~/.config/nvim/lua/plugins/init.lua`（lazy.nvim bootstrap + 所有 spec）

## 配置思路
> 整份配置见 `configs/nvim/`（可复刻）。核心理念：**读代码 + LSP，不补全**。

### 插件（lazy.nvim）
| 插件 | 作用 |
|------|------|
| nvim-lspconfig + mason.nvim + mason-lspconfig | LSP 配置 + 自动装 server |
| telescope.nvim | fuzzy finder（文件 / grep / 符号 / 引用 / 诊断） |
| nvim-treesitter | parser 安装管理（高亮靠 nvim 0.11+ 内置 `vim.treesitter`） |

> **不装**：nvim-cmp / coq / 任何补全引擎、snippet 引擎。写代码用 coding agent。

### LSP servers（Mason 装，覆盖 profile 技术栈）
pyright（Python）· clangd（C/C++）· vtsls（TypeScript/Vue）· gopls（Go）· rust_analyzer（Rust）

### 读代码键位（LSP attach 后 buffer-local）
| 键 | 动作 |
|----|------|
| `gd` | goto definition |
| `gr` | references |
| `gD` | goto declaration |
| `gi` | goto implementation |
| `gy` | goto type definition |
| `K` | hover doc |
| `<leader>rn` | rename |
| `<leader>ca` | code action |
| `[d` / `]d` | 上 / 下一个诊断 |
| `<leader>e` | 行诊断浮窗 |
| `gq` | 诊断列表（location list） |

### Telescope
`<leader>ff` 文件 · `<leader>fg` live grep · `<leader>fb` buffer · `<leader>fs` 文档符号 · `<leader>fS` 工作区符号 · `<leader>fd` 诊断

### 诊断样式
virtual_text（行尾 `●`）+ signs（sign 列）+ underline；severity_sort；浮窗带 border + source。

## 参考
- `configs/nvim/`（init.lua + lua/ 完整配置实物）

## 验证
```sh
nvim --version | head -1     # 期望：>= 0.11
# 启动 nvim 打开代码文件：
#   :LspInfo       确认 LSP server attached
#   :checkhealth   确认无严重错误
#   gd / gr / K    确认读代码键位工作
```
