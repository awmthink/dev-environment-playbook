# tool: Zellij

> 终端多路复用器（**替代 tmux**）：SSH 会话 detach/attach（断线不丢工作）+ 单窗分屏。Linux server 与 macOS 日常必备。

## 为什么用
远程会话持久化（网络波动 / 换机器 attach 回来）、分屏并行。相比 tmux：
- **开箱即用、零记忆**：状态栏实时显示当前 mode 与快捷键，不用背 prefix 组合键。
- **Rust 实现**，单静态二进制、跨平台、启动快。
- 内置 floating panes、layouts、tab、会话管理（server 化），默认体验远超裸 tmux。
- 配置 KDL，可读性好；`zellij setup --dump-config` 生成全量模板。

> 取代 tmux（已弃用）。profile.md「候选待试」里的 Zellij 已转正。

## 最低版本要求
- **>= 0.40**（floating panes / layouts 稳定；当前 0.44.3）。

## 版本与安装策略

**多版本需求：否**——全局单一即可（不需要版本管理器，每平台选官方最 canonical 方式）。

**各平台安装**（官方推荐方式）：

| 平台 | 推荐方式 |
|------|----------|
| macOS | `brew install zellij`（zellij 官方推荐的 macOS 装法） |
| Linux | GitHub release 预编译静态二进制（musl，跨 glibc）→ `~/.local/bin` |

> zellij 官方发 musl 静态预编译（`zellij-*-unknown-linux-musl.tar.gz`），单文件、零依赖、老 distro（CentOS 8 glibc 2.28）直接能跑——故 Linux 走 GitHub 二进制，不进 mise、不需源码编译。

### Linux 安装（GitHub 预编译）
```sh
ZELLIJ_VER=0.44.3
TMP=$(mktemp -d)
curl -fL "https://github.com/zellij-org/zellij/releases/download/v$ZELLIJ_VER/zellij-x86_64-unknown-linux-musl.tar.gz" -o "$TMP/z.tar.gz"
tar -xzf "$TMP/z.tar.gz" -C "$TMP"
install -m 0755 "$TMP/zellij" ~/.local/bin/zellij
rm -rf "$TMP"
```

## 配置思路
> 整份见 `configs/zellij/config.kdl`。只写「与默认不同」的偏好，其余用内置默认。

- 配置文件 `~/.config/zellij/config.kdl`（可选；不创建则用内置默认，已足够起步）。
- 起步：`zellij setup --dump-config` 看全量可配置项；按需取几行进自己的 config。
- **主题**：自定义 Aura Dark 主题（色板取自 aura-theme 官方），对齐 profile.md 偏好——见参考配置的 `[themes]` 块 + `theme "aura"`。
- 默认快捷键无需配置——状态栏自显示；`Ctrl-g` 锁定/解锁、`Ctrl-p` pane、`Ctrl-t` tab、`Ctrl-s` scroll。
- 会话持久化：zellij 自带 server 化会话，`zellij attach <name>` / `zellij ls`。

## 参考
- `configs/zellij/config.kdl`（参考实物：compact 布局 + mouse + Aura 主题）

## 验证
```sh
zellij --version          # 期望：>= 0.40
which zellij              # linux 期望：~/.local/bin/zellij；mac 期望：brew 路径
zellij ls                 # 列出会话（无会话时输出空）
# 开新终端跑 `zellij`：确认状态栏 / 分屏 / tab 可用
```
