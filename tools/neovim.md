# tool: Neovim

> terminal 编辑器主力（见 `profile.md`），与 Zed 分工：Zed 做 GUI，Neovim 做终端 / 远程服务器。**定位：读代码 + LSP，0 插件**（纯 nvim 0.11+ 原生）；**故意不装补全**——写代码交给 coding agent。

## 为什么用
终端原生、SSH 友好；LSP 生态成熟。**0 插件**：用 nvim 0.11+ 原生 `vim.lsp` / `vim.diagnostic`，避免插件管理器 / Mason 等黑盒层，配置可移植、跨平台一致（Linux 无 tree-sitter CLI 的 glibc 等坑）。

## 版本约束
- 版本：>= 0.11（`vim.lsp.config` / `vim.lsp.enable` / `vim.diagnostic.jump`）；当前 **0.12.4**
- 安装：`brew install neovim`

## 依赖
- **ripgrep**：`:grep` 全文搜索 → `brew install ripgrep`
- **LSP server**：见下表，按用到的语言装
- **不依赖**：tree-sitter CLI、任何 nvim 插件管理器 / Mason

## LSP server（系统级安装，进 PATH）
> 不用 Mason——server 装到系统（brew / npm），全局可用、版本统一、可复现、跨工具共享。

| 语言 | server | 安装 |
|------|--------|------|
| Python | pyright | `brew install pyright` |
| C/C++ | clangd | 系统自带（`/usr/bin/clangd`，Xcode CLT）；Linux 用 `brew install llvm` 或发行版包 |
| Go | gopls | `brew install gopls` |
| Rust | rust-analyzer | `brew install rust-analyzer` |
| TypeScript/Vue | vtsls | `npm install -g @vtsls/language-server` |

## 配置位置
- **单文件**：`~/.config/nvim/init.lua`（不拆 lua/ 模块，全部在一个文件）

## 配置思路
> 整份见 `configs/nvim/init.lua`。0 插件、纯原生。

### LSP
- `vim.lsp.config(name, {cmd, filetypes, root_markers})` 手写各 server 配置（不依赖 lspconfig 插件，避开其 deprecated 的 `require('lspconfig').setup`）
- `vim.lsp.enable({servers})` 启用
- 键位在 `LspAttach` autocmd 里按 buffer 设

### 高亮
- 用 nvim 内置 **syntax（regex）**（默认开启）
- **不用 treesitter**：避免 nvim-treesitter 插件 + tree-sitter CLI 编译 parser（Linux 下 glibc 兼容坑）。regex 高亮读代码够用。

### fuzzy / 搜索
- 不用 telescope，用 `:grep`（`grepprg = rg`）+ quickfix
- `<leader>fg` 输入 pattern → 结果进 quickfix → `<leader>co`（`:copen`）查看
- `:find {path}` 文件名补全（wildmenu）

### 读代码键位（LSP attach 后 buffer-local）
| 键 | 动作 |
|----|------|
| `gd` / `gD` / `gi` / `gy` | 定义 / 声明 / 实现 / 类型定义 |
| `gr` | references |
| `K` | hover doc |
| `<leader>rn` / `<leader>ca` | rename / code action |
| `[d` / `]d` | 上 / 下一个诊断（`vim.diagnostic.jump`） |
| `<leader>e` / `gq` | 行诊断浮窗 / 诊断列表 |

### 搜索键位
`<leader>fg` grep（→ quickfix）· `<leader>co` 打开 quickfix

## 参考
- `configs/nvim/init.lua`（单文件完整配置）

## 验证
```sh
nvim --version | head -1     # 期望：>= 0.11
which pyright-langserver gopls rust-analyzer vtsls clangd   # LSP server 在 PATH
# 启动 nvim 打开代码文件：
#   :LspInfo       确认 server attached
#   gd / gr / K    读代码键位
#   :grep foo<cr> | :copen   全文搜索
```
