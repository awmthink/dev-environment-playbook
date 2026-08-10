# profile.md — 关于我与我的工作流

> 这是给 agent 的全局上下文。配置任何工具前，先了解下面这些偏好，它们会影响几乎所有决策。

## 关于我

- 角色：AI 算法工程师（10+ 年经验），借助 coding agent 基本全栈，几乎什么项目都能做
- 主要技术栈：Python · C/C++（含 CUDA）· TypeScript + Vue + CSS · Go · Rust
- 工作内容：算法 + 工程兼顾；前端、后端、系统、性能优化都会涉及

## 全局偏好

<!-- 这些是「跨工具生效」的偏好，每个 tools/*.md 默认继承 -->

| 维度 | 偏好 | 理由 |
|------|------|------|
| Shell | zsh（macOS 主力）/ bash（Linux 服务器） | macOS 默认、生态成熟；服务器照旧 bash 兼容 |
| 编辑器 | Zed · Cursor · Neovim · VS Code（按场景切换） | 建议分工：Zed 日常主力、Cursor 大仓库 / 重 agent、Neovim 远程服务器、VS Code 仅需扩展时 fallback |
| 终端 | iTerm2（macOS） | 功能成熟稳定、生态匹配好 |
| Node 包管理 | pnpm | 快、省磁盘、严格 |
| Python 包管理 | uv | 极快，统一 toolchain |
| 系统包管理 | macOS: Homebrew；Linux: 发行版自带（apt/dnf/…） | 各平台原生方案优先 |
| 主题 | Aura Dark | 长时间用眼偏好；指定 Aura Dark 配色 |
| 字体 | 主力 **Maple Mono NF CN**；备选 **JetBrainsMono Nerd Font**（看腻时切换） | 主力：中英混排对齐、覆盖图标 / 连字 / CJK；备选：经典方正、纯 ASCII 区最稳 |
| 键位 | 不改键位，保持系统默认 | 跨机器无需额外配置 |

## 探索中 / 待评估

> 这些是「正在尝试或候选」的工具，状态偏流动，配置上先轻量化、易回退；不替换主力。

- 探索中：Nushell（shell，担心太新 / 生态不匹配）、Ghostty（terminal，同上）
- 候选待试：Starship（提示符，跨 shell 显示多语言版本上下文）、Zellij（多路复用，GPU 服务器长会话）

## 工作流约定

- 借助 coding agent 推进项目；重复性的环境配置 / 同步也交给 agent（见 `README.md` 两类场景）。
- <!-- 待补充：项目目录约定（如 ~/Workspace）、git 提交信息风格、语言版本管理器（pyenv/nvm/rustup/…）等 -->
