# tool: shell

> zsh 为 macOS 主力，bash 为 Linux 服务器主力。rc 思路在此统一，平台差异交给 agent。

## 为什么用
zsh：macOS 默认、生态成熟、补全强；bash：服务器普遍、脚本兼容性最好。

## 版本约束
- zsh：>= 5.8（macOS 自带 / brew）
- bash：>= 5（Linux 服务器自带）

## 安装

| 平台 | 方式 |
|------|------|
| macOS | 系统自带 zsh；`brew install zsh` 取新版；`chsh -s /bin/zsh` |
| Linux | `apt install zsh` / `dnf install zsh`；`chsh -s /usr/bin/zsh` |

## 配置思路
- **不依赖重框架**（不用 oh-my-zsh），保持启动快、配置可读；手写 `.zshrc`。
- **提示符交给 Starship**（见 `profile.md` 候选），rc 里不写 prompt 主题。
- **本地配置统一放 `~/.config/shell/`**（仓库外、不提交）：`env.sh`（共用环境变量，zsh / bash 都 source）、`proxy.env`（代理，见 `proxy.md`）、`secrets.env`（API key / token，`chmod 600`）。`.zshrc` 幂等 source：`[ -f ~/.config/shell/secrets.env ] && source ~/.config/shell/secrets.env`；脱敏模板见 `configs/shell/secrets.env.example`。
- 历史：`HISTFILE` / `HISTSIZE` / `SAVEHIST`、`setopt SHARE_HISTORY` 共享历史。
- 补全：启用 `compinit`；按需补全脚本放 `~/.config/zsh/completions`。
- 别名：少量高频（`ll`）；不用 git 别名（习惯原生命令），其余交给工具。
- **各语言环境按需 source**：node/python/go/rust 的 PATH 由各自工具(mise/uv/rustup)注入，rc 里只负责调用它们的初始化钩子。
- **user-local bin 进 PATH**：Linux 下优先 `~/.local/bin`（详见 `platforms/linux.md` 的安装目录约定），加上 `~/.cargo/bin`、`~/go/bin` 等；macOS 下 Homebrew 路径由 brew 处理。

服务器端 `.bashrc` 为精简版：基础别名 + 历史 + 共用 env。

## 参考
- `configs/zsh/.zshrc`、`configs/shell/env.sh`（实物）；`configs/bash/.bashrc`（服务器端，待补充）；脱敏模板：`configs/shell/secrets.env.example`、`configs/shell/proxy.env.example`

## 验证
```sh
echo $SHELL       # 期望：.../zsh（macOS）
zsh --version     # 期望：>= 5.8
bash --version    # 期望：>= 5
```
