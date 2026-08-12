# tool: shell

> zsh 全平台统一（macOS + Linux），rc 思路一致。

## 为什么用
zsh：补全强、生态成熟、跨平台一份 rc；bash 兼容性不再构成约束（脚本走自身 shebang，与登录 shell 解耦）。

## 最低版本要求
- zsh：>= 5.5（macOS 自带 / brew / Linux `dnf install zsh`；CentOS 8 dnf 版 5.5.1 够用）

## 版本与安装策略

**多版本需求：否**——登录 shell 全局单一版本。各语言运行时的多版本由 mise 管，shell 本身不参与。

**各平台安装**：

| 平台 | 推荐方式 |
|------|----------|
| macOS | 系统自带 zsh；`brew install zsh` 取新版；`chsh -s /bin/zsh` |
| Linux | `dnf install zsh`（系统级，进 `/usr/bin/zsh` + `/etc/shells`，可 chsh）；`chsh -s /usr/bin/zsh` |

> Linux 上 zsh 必须是系统级（`/usr/bin/zsh`，在 `/etc/shells`）才能 `chsh`。用户级路径（如 `~/.local/bin/zsh`）做 login shell 不可靠（依赖挂载）。

## 配置思路
- **不依赖重框架**（不用 oh-my-zsh），保持启动快、配置可读；手写 `.zshrc`。
- **提示符交给 Starship**（见 `profile.md` 候选），rc 里不写 prompt 主题。
- **本地配置统一放 `~/.config/shell/`**（仓库外、不提交）：`env.sh`（共用环境变量，zsh / bash 都 source）、`proxy.env`（代理，见 `proxy.md`）、`secrets.env`（API key / token，`chmod 600`）。`.zshrc` 幂等 source：`[ -f ~/.config/shell/secrets.env ] && source ~/.config/shell/secrets.env`；脱敏模板见 `configs/shell/secrets.env.example`。
- 历史：`HISTFILE` / `HISTSIZE` / `SAVEHIST`、`setopt SHARE_HISTORY` 共享历史。
- 补全：启用 `compinit`；按需补全脚本放 `~/.config/zsh/completions`。
- 别名：少量高频（`ll`、`vim=nvim`）；不用 git 别名（习惯原生命令），其余交给工具。
- **语言运行时统一归 mise**：node/python/go/rust 的版本与 PATH 由 mise 管，rc 里只加**一个** init 钩子（幂等）：
  - `.zshrc`：`eval "$(mise activate zsh)"`
  - `.bashrc`：`eval "$(mise activate bash)"`
  不再为各语言单独写 init（nvm/conda-init/rustup init 都不再需要）；uv/rustup 作 mise 的 engine 透明运行。
- **user-local bin 进 PATH**：`~/.local/bin`（per-user llvm 预编译/git/tmux 等装这里，Linux 编译器 `~/.local/llvm-18.1.8/bin` 也前置）、`~/.cargo/bin`、`~/go/bin`；macOS 下 Homebrew 路径由 brew 处理。详见 `configs/shell/env.sh`。

服务器端 `.bashrc` 为精简版：基础别名 + 历史 + 共用 env。

## 参考
- `configs/zsh/.zshrc`、`configs/shell/env.sh`（实物）；`configs/bash/.bashrc`（服务器端，待补充）；脱敏模板：`configs/shell/secrets.env.example`、`configs/shell/proxy.env.example`

## 验证
```sh
echo $SHELL       # 期望：.../zsh（macOS）
zsh --version     # 期望：>= 5.8
bash --version    # 期望：>= 5
```
