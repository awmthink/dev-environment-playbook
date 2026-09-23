# dev-environment-playbook

一个 **agent-readable playbook**：把开发环境写成「意图 + 理由 + 版本 + 验证」，由 coding agent 在任意平台读取并落地，而不再依赖脆弱的跨平台 dotfiles 同步。

## 默认前提

你已经在某台机器上 `clone` 了本仓库，并用某个 coding agent（opencode / pi / codex / zcode 等）在本目录打开了会话。agent 会先读 `AGENTS.md`（流程 + 安全规则），然后按你的指令工作。**你不直接改文件，而是下指令 + review agent 的产出。**

## 两类核心场景（都通过 agent 驱动）

### 场景 1：完善本项目（补充工具 / 平台偏好 / agent 配置）

把本项目当作「单一事实源」持续维护，维护动作本身也交给 agent：

**新增一个工具**
```
帮我新增 tools/git.md：按 profile.md 的偏好记录「为什么用 / 版本约束 /
各平台安装方式 / 配置思路 / 验证命令」，示例配置放进 configs/，
并在 tools/README.md 索引登记一行。改完给我看 diff。
```

**补充平台偏好 / 坑**
```
在 platforms/linux.md 补充 Arch 的包管理器偏好与已知坑。
```
（某工具在特定平台的差异，则让 agent 写进对应 `tools/<tool>.md` 的「安装」表。）

**完善 agent 配置**
```
在 agents/ 登记新 agent（CLI / App 分类 + 验证方式；CLI 类再补配置思路）。
```

> `AGENTS.md` 里的「写作约定」规定了这些文档的统一格式，agent 会自动遵循。

### 场景 2：检查 / 更新 / 清理当前开发环境

这是本项目的核心用途。在本机的 agent 会话里下指令：

**检查差异**（只读，最安全，建议先跑）
```
对比当前环境与 tools/ 和 agents/（CLI 类）的声明，列出：缺哪些工具、版本不符的、配置缺失的。
先只报告，不要改动任何东西。
```

**同步 / 更新**
```
按 tools/ 和 agents/（CLI 类：opencode、pi）配置我的 shell、git 和 opencode。
遇到既有配置先 diff 给我确认。
```

**清理**
```
列出当前环境中不在 tools/ 声明里、且我大概率不再需要的东西，
给出清理建议，等我确认后再删。
```

无论哪个动作，agent 都会按 `AGENTS.md` 的流程（识别平台 → 读意图 → 检查现状 → 计划确认 → 执行 → 验证）与安全规则（幂等、不覆盖既有配置、改动前备份、不碰密钥）执行。

## 仓库结构（速查）

| 路径 | 作用 |
|------|------|
| `AGENTS.md` | agent 的操作手册（流程 + 安全规则） |
| `profile.md` | 我是谁、工作流、全局偏好 |
| `platforms/` | macOS / Linux 的平台上下文与坑 |
| `tools/` | 每个开发工具一篇 playbook（含 `_template.md`） |
| `agents/` | coding agent 自身的配置 playbook |
| `configs/` | 参考配置实物（只读，非软链目标） |

## 目标平台 / 覆盖的 agent

- 平台：macOS（Homebrew）、Linux（见 `platforms/linux.md`）
- Agent：opencode · pi（CLI）· codex · zcode（App，见 `agents/`）

## 为什么不是 dotfiles 仓库？

传统 dotfiles 仓库（chezmoi / yadm / stow）想做「跨平台同步」，但平台差异让 sync 很脆弱。本项目换思路：**只记录意图，把落地交给当前平台的 agent**；并且把 agent 本身也当成需要管理的开发工具。
