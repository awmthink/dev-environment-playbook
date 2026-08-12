# tool: git

> 所有项目的版本控制基础，跨语言统一。

## 为什么用
事实标准；命令行 + 图形工具(lazygit / IDE)生态最全。

## 最低版本要求
- **>= 2.30**（较新即可）。CentOS 8 自带的 2.27 偏旧，且不认 `http_proxy` 环境变量（需 `git -c http.proxy=...`），是 Linux 上要装新版的主要动机。

## 版本与安装策略

**多版本需求：否**——各项目不要求特定 git 版本，全局单一即可（故不需要版本管理器，每平台选最轻方案）。

**各平台安装**：

| 平台 | 推荐方式 |
|------|----------|
| macOS | `brew install git`（单用户，brew 版本足够新） |
| Linux | 源码编译 → `~/.local/bin/git`（发行版偏旧，上游无预编译二进制）。由 `scripts/bootstrap.sh` 完成。 |

> **Linux 源码编译要点**：`make configure && ./configure --prefix=$HOME/.local CC=clang && make NO_ICONV=YesPlease all && make install`。
> - `NO_ICONV=YesPlease` 规避部分 distro 的 iconv 链接问题（仅禁字符集转换，**不影响 `text`/`eol` 行尾规范化**）。
> - 依赖（make / autoconf / zlib-devel / libcurl-devel）不全时脚本退出并打印 dnf/apt 命令；缺依赖期间可用**系统 git 兜底**。

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
