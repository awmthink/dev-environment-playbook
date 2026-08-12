# tool: tmux

> 终端多路复用：SSH 会话 detach/attach（断线不丢工作）+ 单窗分屏。Linux server 日常必备。

## 为什么用
远程会话持久化（网络波动 / 换机器 attach 回来）、分屏并行；比 screen 现代、比 Zed Remote 更轻、零 GUI 依赖（headless server 友好）。

## 最低版本要求
- **>= 3.4**。CentOS 8 AppStream 自带 **3.1c（2020）偏旧**，是 Linux 上要源码编译的主因。

## 版本与安装策略

**多版本需求：否**——全局单一即可（不需要版本管理器，每平台选最轻方案）。

**各平台安装**：

| 平台 | 推荐方式 |
|------|----------|
| macOS | `brew install tmux`（brew 版本足够新） |
| Linux | 源码编译 → `~/.local/bin`（CentOS 8 的 3.1c 不够，要 ≥3.4）。由 `scripts/bootstrap.sh` 完成。 |

> **Linux 源码编译要点**：构建依赖 `libevent-devel` + `ncurses-devel`（sudo 装一次）；`./configure --prefix=$HOME/.local && make && make install`。缺依赖时 bootstrap 退出并打印 dnf/apt 命令。

## 配置思路
- 配置文件 `~/.config/tmux/tmux.conf`（tmux 3.1+ 默认识别此路径）；待补充（当前用默认）。

## 参考
- `scripts/bootstrap.sh`（tmux 源码编译段，Layer 2 Linux）

## 验证
```sh
tmux -V            # 期望：>= 3.4
which tmux         # linux 期望：~/.local/bin/tmux；mac 期望：brew 路径
tmux new -d -s _selftest && tmux kill-session -t _selftest   # 能创建/销毁会话
```
