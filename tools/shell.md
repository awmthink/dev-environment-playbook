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
- **共用环境变量**抽到一个文件（如 `~/.config/shell/env.sh`），zsh / bash 都 source，避免重复。
- 历史：`HISTFILE` / `HISTSIZE` / `SAVEHIST`、`setopt SHARE_HISTORY` 共享历史。
- 补全：启用 `compinit`；按需补全脚本放 `~/.config/zsh/completions`。
- 别名：少量高频（`ll/gst/gd`），其余交给工具。
- **各语言环境按需 source**：node/python/go/rust 的 PATH 由各自工具(mise/uv/rustup)注入，rc 里只负责调用它们的初始化钩子。

服务器端 `.bashrc` 为精简版：基础别名 + 历史 + 共用 env。

## 参考
- `configs/zsh/.zshrc`、`configs/shell/env.sh`、`configs/bash/.bashrc`（实物，待补充）

## 验证
```sh
echo $SHELL       # 期望：.../zsh（macOS）
zsh --version     # 期望：>= 5.8
bash --version    # 期望：>= 5
```
