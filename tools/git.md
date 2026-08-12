# tool: git

> 所有项目的版本控制基础，跨语言统一。

## 为什么用
事实标准；命令行 + 图形工具(lazygit / IDE)生态最全。

## 版本约束
- 版本：latest（各平台包管理器自带即可）

## 安装

> git **不进 mise**（上游只发源码、无预编译二进制）。**两端都源码编译进 `~/.local`**，由 `scripts/bootstrap.sh` 完成（含依赖检测：make / autoconf / zlib-devel / libcurl-devel 等）。
>
> 构建：`make configure && ./configure --prefix=... CC=clang && make NO_ICONV=YesPlease all && make install`。`NO_ICONV=YesPlease` 规避某些 distro 的 iconv 链接问题（仅禁用字符集转换，**不影响 `text`/`eol` 行尾规范化**）。依赖不全时脚本退出并打印 dnf/apt 命令；缺依赖期间可用**系统 git 兜底**。

| 平台 | 方式 |
|------|------|
| macOS / Linux | `scripts/bootstrap.sh`（源码编译 → `~/.local/bin/git`，版本两端一致） |

> 为什么不用 distro/brew：发行版版本偏旧（如 CentOS 8 的 2.27）；brew-on-Linux 有多用户问题。源码编译统一两端版本，成本仅 ~1 分钟。

## 配置思路
<!-- 个人身份信息是机器/账号相关，不要写死进仓库；agent 同步时从本地或向我询问 -->

- `user.name` / `user.email`：身份，待填（绝不进仓库）
- `init.defaultBranch = main`：新仓库默认分支
- `pull.rebase`：默认 false（merge）；若偏好线性历史可设 true（待定）
- `core.editor`：指向当前主力编辑器（见 `profile.md`）
- `credential.helper`：macOS 用 `osxkeychain`；Linux 用 `cache` 或 libsecret
- **不设别名**：习惯原生命令（与 `shell.md` 「不用 git 别名」一致）

## 参考
- `configs/git/.gitconfig`（实物，待补充）

## 验证
```sh
git --version      # 期望：较新稳定版
git config --list  # 确认身份与上述设置已生效
```
