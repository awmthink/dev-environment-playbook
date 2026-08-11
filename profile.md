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
| 提示符 | Starship | 跨 shell（zsh/bash）统一、自动显示 git/语言版本上下文；替代手写 prompt 与 oh-my-zsh 主题 |
| 编辑器 | Zed（GUI 主力）· Neovim（terminal 主力） | Zed 不带 agent、只做编辑；Neovim 用于终端 / 远程服务器场景 |
| Coding agent | opencode · claude-code · codex · qoder-cli | agent 与 editor 职责分离——编辑用 Zed，agent 用专用工具（终端 / CLI） |
| 终端 | Ghostty（macOS 主力）· iTerm2（备选） | Ghostty：GPU(Metal) 渲染流畅、原生 macOS、配置简洁、内置 Aura 主题；iTerm2：成熟稳定作备选 |
| Node 包管理 | pnpm（via corepack） | 快、省磁盘、严格；通过 node 自带 corepack 安装，不单独 brew install |
| Python 包管理 | uv | 极快，统一 toolchain |
| 系统包管理 | macOS: Homebrew；Linux: 开发工具优先 user-local（Linuxbrew + mise/uv/rustup），发行版源仅作系统基础 | Linux 发行版版本偏旧，开发工具自行管理版本更可控 |
| 主题 | Aura Dark | 长时间用眼偏好；指定 Aura Dark 配色 |
| 字体 | 主力 **Maple Mono NF CN**；备选 **JetBrainsMono Nerd Font**（看腻时切换） | 主力：中英混排对齐、覆盖图标 / 连字 / CJK；备选：经典方正、纯 ASCII 区最稳 |
| 键位 | 不改键位，保持系统默认 | 跨机器无需额外配置 |

## 探索中 / 待评估

> 这些是「正在尝试或候选」的工具，状态偏流动，配置上先轻量化、易回退；不替换主力。

- 探索中：Nushell（shell，担心太新 / 生态不匹配）
- 候选待试：Zellij（多路复用，GPU 服务器长会话）

## 工作流约定

- 借助 coding agent 推进项目；重复性的环境配置 / 同步也交给 agent（见 `README.md` 两类场景）。
- 语言版本管理：**node → brew（单 LTS，不切版本）**、**python → uv**；go / rust 暂用 brew / rustup 直装（go 多版本走原生 `GOTOOLCHAIN`）。不混用多个管理器。
- <!-- 待补充：项目目录约定（如 ~/Workspace）、git 提交信息风格等 -->
