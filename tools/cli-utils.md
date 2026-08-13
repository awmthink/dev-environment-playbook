# tool: CLI 增强工具（rg / jq / fzf / fd）

> shell 下的高频增强工具：全文搜索（rg）、JSON 处理（jq）、模糊查找（fzf）、文件查找（fd）。leaf 单文件、无需多版本、几乎零配置，按 core principle 各平台选最 canonical 的官方来源。

## 为什么用
四者都是 shell 日常不可缺的「粘合」工具，替代系统老古董（grep/awk 手搓 JSON 等）：
- **ripgrep (rg)**：比 grep 快一个量级，默认递归 + 忽略 `.gitignore`；也是 nvim `:grep` 的后端（见 `tools/neovim.md`）。
- **jq**：命令行 JSON 查询/变换的事实标准，pipe 友好。
- **fzf**：通用模糊查找器，接管道 / 文件 / git 分支 / 历史命令，提供交互式筛选。
- **fd**：find 的现代替代（Rust 实现），语法友好、默认尊重 `.gitignore`；coding agent（pi 等）的 find 工具以 fd 为后端，缺了会报 `fd not found`。

## 最低版本要求
- rg：latest（GitHub release）
- jq：>= 1.7（新 filter / 性能；1.6 也能用，但 release 取最新即可）
- fzf：latest（GitHub release）
- fd：latest（GitHub release）

## 版本与安装策略

**多版本需求：否**——四个都是全局单一二进制，不参与版本管理。各平台用最 canonical 的官方来源（mac=brew；linux=官方/GitHub 预编译 → `~/.local/bin`），不进 mise（见 `tools/mise.md` 实操备注）。

**各平台安装**：

| 工具 | macOS | Linux |
|------|-------|-------|
| rg | `brew install ripgrep` | GitHub musl 静态 → `~/.local/bin` |
| jq | **先查系统自带**：macOS 26+ 自带 `/usr/bin/jq`（`jq-1.7.x-apple`），满足 >=1.7 则无需装；否则 `brew install jq` | GitHub 静态单文件 → `~/.local/bin` |
| fzf | `brew install fzf` | GitHub 单文件 → `~/.local/bin` |
| fd | `brew install fd` | GitHub musl 静态 → `~/.local/bin` |

> **为什么 Linux 不用 dnf**：发行版源偏旧/不可靠（CentOS 8 的 rg 在 EPEL、fzf 不可靠）；官方/GitHub 预编译最 canonical、最透明。rg / fd 用 **musl 静态版**跨 glibc，老 distro（CentOS 8 glibc 2.28）直接能跑。详见 `platforms/linux.md`。

### Linux 安装命令
```sh
# ripgrep（musl 静态，跨 glibc）
RG_VER=15.2.0
curl -fL "https://github.com/BurntSushi/ripgrep/releases/download/$RG_VER/ripgrep-$RG_VER-x86_64-unknown-linux-musl.tar.gz" | tar -xz -C /tmp
install -m 0755 "/tmp/ripgrep-$RG_VER-x86_64-unknown-linux-musl/rg" ~/.local/bin/rg

# jq（静态单文件）
curl -fL "https://github.com/jqlang/jq/releases/download/jq-1.8.2/jq-linux-amd64" -o ~/.local/bin/jq
chmod 0755 ~/.local/bin/jq

# fzf（单文件）
FZF_VER=0.74.2
curl -fL "https://github.com/junegunn/fzf/releases/download/v$FZF_VER/fzf-$FZF_VER-linux_amd64.tar.gz" | tar -xz -C /tmp
install -m 0755 /tmp/fzf ~/.local/bin/fzf

# fd（musl 静态，跨 glibc）
FD_VER=10.4.2
curl -fL "https://github.com/sharkdp/fd/releases/download/v$FD_VER/fd-v$FD_VER-x86_64-unknown-linux-musl.tar.gz" | tar -xz -C /tmp
install -m 0755 "/tmp/fd-v$FD_VER-x86_64-unknown-linux-musl/fd" ~/.local/bin/fd
```

> GitHub release 下载慢/失败时先确认代理（见 `tools/proxy.md`：交互 shell 直接 `proxy_on`；非登录场景先 `source ~/.config/shell/proxy.env`）。

## 配置思路
- **rg / jq / fd**：零配置，开箱即用；行为通过命令行参数控制。
- **fzf keybinds**：brew 版装后跑 `$(brew --prefix)/opt/fzf/install` 启用 `Ctrl-T`/`Ctrl-R`/`Alt-C`；Linux 版若要 keybinds，clone 仓库后 `~/.fzf/install`，或仅当命令行 filter 用（不强求）。
- rg / fd 的默认忽略 `.gitignore` 行为通常正是想要的；需搜隐藏/被忽略文件时 rg 加 `-uu`、fd 加 `-u`（= `--no-ignore --hidden`）。

## 参考
- `tools/README.md`（工具索引）

## 验证
```sh
rg --version | head -1     # 期望：ripgrep 15.x
jq --version               # 期望：>=1.7（macOS 26+ 系统自带 jq-1.7.x-apple 即满足，无需 brew）
fzf --version              # 期望：0.7x
fd --version               # 期望：fd 10.x
echo '{"a":1}' | jq .a     # 期望：1（jq pipe 可用）
fd -t f . ~/.local/bin     # 期望：列出 ~/.local/bin 下的文件
```
