# tool: LSP servers（跨编辑器共享）

> 语言服务器，为编辑器（Neovim / Zed）提供代码导航 / 悬浮文档 / 诊断 / 重构能力。**系统级安装**（brew/npm），进 PATH，多编辑器共享——不依赖 Mason 等工具内装。

## 为什么用
读代码核心：定义跳转、引用查找、hover 文档、诊断。装在系统 PATH，Neovim 和 Zed 都能直接用（Zed 自动检测 PATH 的 server；Neovim 在 `init.lua` 的 `vim.lsp.config` 引用）。统一一份 server，避免 Mason 黑盒层、版本统一、跨工具复用。

## servers 清单（覆盖 profile 技术栈）

| 语言 | server | 安装 | 备注 |
|------|--------|------|------|
| Python | pyright | `brew install pyright` | 类型 / 定义 / 引用 |
| C/C++ | clangd | macOS 自带（Xcode CLT，`/usr/bin/clangd`）；Linux `brew install llvm` | |
| Go | gopls | `brew install gopls` | |
| Rust | rust-analyzer | `brew install rust-analyzer` | |
| TypeScript/Vue | vtsls | `npm install -g @vtsls/language-server` | TS/JS/Vue |

## 配置思路
- **系统级安装**（brew/npm），进 PATH——不依赖 Mason（避免黑盒、版本统一、跨工具共享）。
- **Neovim**：`init.lua` 里 `vim.lsp.config(name, {cmd, filetypes, root_markers})` 手写 + `vim.lsp.enable({servers})`（见 `tools/neovim.md`）。
- **Zed**：自动检测 PATH 的 server 读代码（纯 editor 定位，无需配置；见 `tools/zed.md`）。
- 版本：跟随 brew/npm 最新（不 pin）。

## 参考
- Neovim 的 LSP 键位 / 诊断样式：`configs/nvim/init.lua`、`tools/neovim.md`

## 验证
```sh
which pyright-langserver clangd gopls rust-analyzer vtsls   # 期望：全在 PATH
```
