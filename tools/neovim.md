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
- **剪切板**：按平台分流，**不检测 SSH/DISPLAY**——macOS 用自带的 `pbcopy`/`pbpaste`（nvim 自动检测 provider）；**Linux 用 OSC52**（yank 时把内容写到控制终端，经 ssh/终端透传到**本地**系统剪切板），**不依赖 xclip/wl-copy**（那俩在 SSH 无 DISPLAY 场景下根本连不上 X/Wayland，是 SSH 友好定位下的死路）。详见配置思路「剪切板」。
- **不依赖**：LSP server（导航交 agent）、任何插件管理器 / Mason、tree-sitter CLI

## 配置位置
- **单文件**：`~/.config/nvim/init.lua`（不拆 lua/ 模块，全部在一个文件）

## 配置思路
> 整份见 `configs/nvim/init.lua`。极简、纯原生、0 插件。

- **高亮**：nvim 内置 syntax（默认开启）+ `termguicolors` 真彩色。
- **SSH 启动警告（`NVIM_NOTTYFAST`）**：nvim 启动早期发 OSC 11 查终端背景色自动判断 dark/light；SSH 高延迟下来不及响应，每次启动报警告且变慢（neovim #38699/#38648）。解法：shell 环境 `export NVIM_NOTTYFAST=1`（见 `configs/shell/env.sh` Linux 块）跳过该检测，并在 init.lua 显式 `o.background = "dark"` 兜底。检测发生在 user config 之前，故必须用环境变量——init.lua 里设 background 拦不住这个警告。
- **格式 / 选项**：行号 + 相对行号、缩进（`expandtab` / `tabstop` / `shiftwidth`）、搜索（`smartcase` / `ignorecase`）、分屏方向、`cursorline`、`scrolloff` 等。
- **搜索**：`:grep` 走 ripgrep（`grepprg = rg`），结果进 quickfix，`:copen` 查看。
- **剪切板（按平台分流）**：macOS → `o.clipboard = "unnamedplus,unnamed"`（pbcopy provider 自动生效）；Linux → `TextYankPost` autocmd 里用 OSC52 把 yank 写 `/dev/tty`（纯 lua + 系统 `base64`，0 插件/0 外部脚本）。**Linux 不设 `clipboard=unnamedplus`**：SSH 下没有可用 paste provider，设了反而让 `p` 失灵；故只同步 yank 方向，粘贴进 nvim 走 `Cmd+V` 终端层 bracketed paste。这是为「SSH 友好」定位补的洞——xclip/wl-copy 方案在 SSH 远程（无 DISPLAY）完全失效，只有 OSC52 能跨 ssh 到本地剪切板（前提：本地终端支持 OSC52，如 Ghostty/iTerm2；macOS 自带 Terminal.app 不支持）。
- **键位**：仅基础——窗口切换（`<C-h/j/k/l>`）、`<esc>` 清高亮、`<leader>q` 全退。**不设**代码导航键位。

## 参考
- `configs/nvim/init.lua`（单文件完整配置）

## 验证
```sh
nvim --version | head -1     # 期望：>= 0.11
# 剪切板联动：
#   macOS：nvim 内 yy 一行 → 终端外 `pbpaste` 应输出该行（pbcopy provider 自动生效）
#   Linux：headless 无法验证 OSC52（需真实交互终端渲染），改手动——
#          nvim 内 yy 一行 → 切到本地终端 Cmd+V，应粘出该行（OSC52 经 ssh 透传）
# 启动 nvim 打开代码文件：确认语法高亮 / 缩进 / :grep 可用
```
