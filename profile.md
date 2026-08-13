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
| Shell | macOS zsh · Linux server bash | 登录 shell 属平台基础设施层：server bash 零依赖、救援 / single-user 可用；macOS zsh 取补全 / 历史。substance（PATH / 编辑器 / 别名）共享于 `configs/shell/env.sh`，两端 rc 仅薄壳；脚本走 shebang 与登录 shell 解耦 |
| 提示符 | Starship | 跨 shell（zsh/bash）统一、自动显示 git/语言版本上下文；替代手写 prompt 与 oh-my-zsh 主题 |
| 编辑器 | Zed（GUI 主力）· Neovim（terminal 主力） | Zed 不带 agent、只做编辑；Neovim 用于终端 / 远程服务器场景 |
| Coding agent | CLI：opencode · pi；App：codex · zcode · cursor | CLI 管终端 / 远程服务器场景，App 管 GUI 集成场景（GUI 内配置，playbook 只登记不管理）；编辑仍由 Zed（纯 editor）负责，职责分离 |
| 终端 | Ghostty（macOS 主力）· iTerm2（备选） | Ghostty：GPU(Metal) 渲染流畅、原生 macOS、配置简洁、内置 Aura 主题；iTerm2：成熟稳定作备选 |
| Node 包管理 | pnpm（via corepack） | 快、省磁盘、严格；通过 node 自带 corepack 安装，不单独 brew install |
| Python 包管理 | uv | 极快，统一 toolchain |
| 系统包管理 | **mise**（跨平台 peer：runtime + build + LSP，需多版本/锁版本的工具）+ **brew**（macOS peer：GUI app + 字体 + 不需多版本的 CLI formula）；CLI 日用品按 core principle 逐平台评估（mac=brew / linux=官方/GitHub 预编译 → `~/.local/bin`）；编译器平台原生（mac=Xcode CLT，linux=per-user llvm 预编译）；系统基础库走发行版 dnf/apt（写在消费它的工具卡片里）；CUDA/TensorRT 走外部 | mise per-user、mac/linux 一份配置；brew 管 macOS cask + 字体 + 日用品 CLI formula；编译器因 mise 走源码编译太慢/无插件而留平台原生 |
| 主题 | Aura Dark | 长时间用眼偏好；指定 Aura Dark 配色 |
| 字体 | 主力 **Maple Mono NF CN**；备选 **JetBrainsMono Nerd Font**（看腻时切换） | 主力：中英混排对齐、覆盖图标 / 连字 / CJK；备选：经典方正、纯 ASCII 区最稳 |
| 键位 | 不改键位，保持系统默认 | 跨机器无需额外配置 |

## 探索中 / 待评估

> 这些是「正在尝试或候选」的工具，状态偏流动，配置上先轻量化、易回退；不替换主力。

- 探索中：Nushell（shell，担心太新 / 生态不匹配）

## 工作流约定

- 借助 coding agent 推进项目；重复性的环境配置 / 同步也交给 agent（见 `README.md` 两类场景）。
- 语言版本管理：**统一归 mise**（node/python/go/rust 各自在 `tools/*.md` 给出 `mise use -g` 命令，agent 逐卡片检测+安装；config.toml 由 mise 自动维护、不手写；python 的 venv/依赖用 **uv** 作 engine、rust 用 **rustup** 作 engine，mise 只锁版本）。不再用 brew/nvm 管运行时；编译器（clang）+ git 不进 mise（见各 `tools/*.md`）。
- <!-- 待补充：项目目录约定（如 ~/Workspace）、git 提交信息风格等 -->
