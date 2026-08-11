# tools/ — 工具 playbook

每个开发工具一篇 `.md`，记录「我要什么 + 为什么 + 版本 + 验证」。新增工具时复制 `_template.md`。

## 索引

<!-- 在这里维护工具清单，方便 agent 和你快速定位 -->

| 工具 | 文件 | 状态 |
|------|------|------|
| Homebrew | `homebrew.md` | 已写 |
| Git | `git.md` | 已写 |
| Shell (zsh/bash) | `shell.md` | 已写 |
| Starship | `starship.md` | 已写（提示符） |
| 网络代理 | `proxy.md` | 已写 |
| Node.js + pnpm | `node.md` | 已写（mise + corepack） |
| Python + uv | `python.md` | 已写 |
| Go | `go.md` | 已写 |
| Rust | `rust.md` | 已写 |
| C/C++ + CUDA | `c-cpp.md` | 已写 |
| Ghostty | `ghostty.md` | 已写（macOS 主力终端） |
| iTerm2 | — | 备选 / 待写 |
| 编辑器 (Zed/Cursor/Neovim/VSCode) | — | 待写（部分与 `agents/` 交叉） |
| Docker | — | 待写 |
| lazygit / Zellij | — | 待评估（见 `profile.md`） |

## 写作要点（给人和 agent）
- 写**意图与理由**，不是只贴 dotfile。
- **验证**步骤必须是可直接执行的命令。
- 版本约束明确：`>=x` / `pin x.y.z` / `latest`。
- 平台差异尽量交给 agent，除非有必须记录的坑（那就写进 `platforms/`）。
