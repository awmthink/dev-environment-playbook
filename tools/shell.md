# tool: shell

> macOS zsh / Linux server bash 双 shell；substance 共享于 `configs/shell/env.sh`，两端 rc 仅薄壳。

## 为什么用
登录 shell 属平台基础设施层，按平台选默认更稳，不强求统一：
- **macOS → zsh**：交互强（`compinit` 补全、`SHARE_HISTORY`、globbing qualifier），系统自带。
- **Linux server → bash**：零依赖、所有发行版一致；救援 / single-user / root 只有 bash（甚至 sh），zsh 装在 `/usr/bin`、`/usr` 没挂上就 login 不进来。server 登录场景窄（SSH 跑命令 / 给 agent 当启动环境），zsh 的交互优势用不上。
- **substance 抽到 `env.sh`**（PATH / 编辑器 / 别名 / 平台分支，POSIX 兼容，两端都 source）；`.zshrc` / `.bashrc` 仅剩薄壳（history 选项、`compinit`、工具钩子）。「维护两份 rc」实际只是维护两份 ~15 行、几乎不变的壳。
- **脚本走 `#!/usr/bin/env bash` shebang**，与登录 shell 解耦——不存在「必须 zsh」的脚本场景。

## 最低版本要求
- zsh（macOS）：>= 5.5（系统自带或 `brew install zsh`）
- bash（Linux server）：主流发行版默认即满足（CentOS 8 的 4.x 也够用，server 场景窄）

## 版本与安装策略

**多版本需求：否**——登录 shell 全局单一版本。各语言运行时的多版本由 mise 管，shell 本身不参与。

**各平台登录 shell**：

| 平台 | 登录 shell | 备注 |
|------|-----------|------|
| macOS | zsh | 系统自带；`brew install zsh` 取新版；`chsh -s /bin/zsh` |
| Linux server | bash（默认，**不切 zsh**） | 系统自带、零安装；server 救援 / single-user 需要 bash |

> 不在 Linux 上装 / 切 zsh：登录 shell 属基础设施层，server 上 bash 已够用且救援可用。若个别 server 确需 zsh（如临时交互），须装系统级（`/usr/bin/zsh` 进 `/etc/shells`）才能 `chsh`——用户级路径做 login shell 不可靠（依赖挂载）。但这不是本 playbook 的默认路径。

## 配置思路
- **不依赖重框架**（不用 oh-my-zsh），保持启动快、配置可读；手写 `.zshrc`。
- **提示符交给 Starship**（见 `profile.md` 候选），rc 里不写 prompt 主题。
- **本地配置统一放 `~/.config/shell/`**（仓库外、不提交）：`env.sh`（共用环境变量，zsh / bash 都 source）、`proxy.env`（代理，见 `proxy.md`）、`secrets.env`（API key / token，`chmod 600`）。`.zshrc` 幂等 source：`[ -f ~/.config/shell/secrets.env ] && source ~/.config/shell/secrets.env`；脱敏模板见 `configs/shell/secrets.env.example`。
- 历史：`HISTFILE` / `HISTSIZE` / `SAVEHIST`、`setopt SHARE_HISTORY` 共享历史。
- 补全：启用 `compinit`；按需补全脚本放 `~/.config/zsh/completions`。
- 别名：少量高频（`ll`、`vim=nvim`），放 `env.sh` 两端共用（POSIX 语法，zsh/bash 一致）；不用 git 别名（习惯原生命令），其余交给工具。
- **语言运行时统一归 mise**：node/python/go/rust 的版本与 PATH 由 mise 管，rc 里只加**一个** init 钩子（幂等）：
  - `.zshrc`：`eval "$(mise activate zsh)"`
  - `.bashrc`：`eval "$(mise activate bash)"`
  不再为各语言单独写 init（nvm/conda-init/rustup init 都不再需要）；uv/rustup 作 mise 的 engine 透明运行。
- **user-local bin 进 PATH**：`~/.local/bin`（per-user llvm 预编译/git/tmux 等装这里，Linux 编译器 `~/.local/llvm-18.1.8/bin` 也前置）、`~/.cargo/bin`、`~/go/bin`；macOS 下 Homebrew 路径由 brew 处理。详见 `configs/shell/env.sh`。

Linux server `.bashrc` 为薄壳：source env.sh + 历史 + 工具钩子（与 `.zshrc` 同结构，仅 shell 语法差异）。

## 参考
- `configs/zsh/.zshrc`、`configs/bash/.bashrc`（两端薄壳）、`configs/shell/env.sh`（共享 substance）；脱敏模板：`configs/shell/secrets.env.example`、`configs/shell/proxy.env.example`

## 验证
```sh
echo $SHELL        # macOS 期望：/bin/zsh 或 /opt/homebrew/bin/zsh；Linux server 期望：/bin/bash
# macOS：
zsh --version      # 期望：>= 5.5
# Linux server：
bash --version     # 期望：>= 4（主流默认 5.x）
```
