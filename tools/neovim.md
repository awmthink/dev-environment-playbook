# tool: Neovim

> terminal 编辑器（见 `profile.md`），与 Zed 分工：Zed 做 GUI，Neovim 做终端 / 远程服务器。**定位：基础编辑器**——只保留高亮 / 格式 / 基本操作；**不含 LSP / 代码导航**——深度读代码（跳转 / 引用 / 关系分析）交给 coding agent。

## 为什么用
终端原生、SSH 友好；macOS + Linux 服务器一份配置跨平台一致（纯 nvim 0.11+ 原生、0 插件、无外部依赖）。系统 vim 在新机器（macOS 自带 9.1 +clipboard）尚可，但在 CentOS 8 等老服务器常是 vim 8.0 / `-clipboard`，体验落后——nvim 预编译二进制一条命令装好，`init.lua` 复制即用，是性价比最高的「跨平台统一编辑器」。

> **不做代码导航**：终端里主要是快改配置 / 写 commit message / 扫一眼文件；仔细读代码、分析函数关系等已交给 agent（opencode / pi / codex / zcode / cursor），比手按 `gd`/`gr` 更高效。LSP server 仍会装，但仅供 **Zed** 使用（见 `lsp.md`）。

## 最低版本要求
- **>= 0.11**（当前 0.12.4）。0.11+ 才有原生 LSP / treesitter API。

## 版本与安装策略

**多版本需求：否**——编辑器全局单一版本即可。

**各平台安装**：

| 平台 | 推荐方式 |
|------|----------|
| macOS | `brew install neovim` |
| Linux | 按 glibc 分流：glibc >= 2.32 拉官方预编译二进制 → `~/.local/bin/nvim`；老 glibc（< 2.32，如 CentOS 8 的 2.28）源码编译 → `~/.local/bin/nvim` |

> **为什么 Linux 不走 mise/brew**：官方 neovim 预编译二进制 min glibc 2.32，老 distro（CentOS 8 glibc 2.28）跑不了；brew-on-Linux 在多用户服务器别扭。故按 glibc 分流（新 glibc 拉官方二进制，老 glibc 源码编译）→ `~/.local/bin`。

### Linux 安装（按 glibc 分流）
```sh
NVIM_VER="stable"
GLIBC_VER=$(ldd --version | awk 'NR==1{print $NF}')
glibc_new_enough() {  # 真·版本比较
  awk -v a="$GLIBC_VER" -v b="$1" 'BEGIN{split(a,A,".");split(b,B,".");
    for(i=1;i<=3;i++){x=A[i]+0;y=B[i]+0; if(x>y)exit 0; if(x<y)exit 1}}'
}
if glibc_new_enough 2.32; then
  # glibc >= 2.32：官方预编译二进制
  curl -fL "https://github.com/neovim/neovim/releases/download/$NVIM_VER/nvim-linux-x86_64.tar.gz" \
    | tar -xz -C ~/.local --strip-components=1
else
  # glibc < 2.32（如 CentOS 8）：源码编译（链系统 glibc）。需 cmake（mise 已装）
  TMP=$(mktemp -d)
  git clone --depth=1 --branch "$NVIM_VER" https://github.com/neovim/neovim "$TMP/nvim"
  ( cd "$TMP/nvim" && make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/.local" )
  ( cd "$TMP/nvim/build" && cmake --install . )
  rm -rf "$TMP"
fi
```

## 依赖
- **ripgrep**：`:grep` 全文搜索 → 不进 mise，按平台最 canonical（mac=brew / linux=dnf，见 `platforms/linux.md`）
- **不依赖**：LSP server（导航交 agent）、任何插件管理器 / Mason、tree-sitter CLI

## 配置位置
- **单文件**：`~/.config/nvim/init.lua`（不拆 lua/ 模块，全部在一个文件）

## 配置思路
> 整份见 `configs/nvim/init.lua`。极简、纯原生、0 插件。

- **高亮**：nvim 内置 syntax（默认开启）+ `termguicolors` 真彩色。
- **格式 / 选项**：行号 + 相对行号、缩进（`expandtab` / `tabstop` / `shiftwidth`）、搜索（`smartcase` / `ignorecase`）、分屏方向、`cursorline`、`scrolloff` 等。
- **搜索**：`:grep` 走 ripgrep（`grepprg = rg`），结果进 quickfix，`:copen` 查看。
- **键位**：仅基础——窗口切换（`<C-h/j/k/l>`）、`<esc>` 清高亮、`<leader>q` 全退。**不设**代码导航键位。

## 参考
- `configs/nvim/init.lua`（单文件完整配置）

## 验证
```sh
nvim --version | head -1     # 期望：>= 0.11
# 启动 nvim 打开代码文件：确认语法高亮 / 缩进 / :grep 可用
```
