# tool: git

> 所有项目的版本控制基础，跨语言统一。

## 为什么用
事实标准；命令行 + 图形工具(lazygit / IDE)生态最全。

## 版本约束
- 版本：latest（各平台包管理器自带即可）

## 安装

| 平台 | 方式 |
|------|------|
| macOS | `brew install git`（系统自带版可能偏旧，用 brew 覆盖） |
| Linux | `apt install git` / `dnf install git` |

## 配置思路
<!-- 个人身份信息是机器/账号相关，不要写死进仓库；agent 同步时从本地或向我询问 -->

- `user.name` / `user.email`：身份，待填（绝不进仓库）
- `init.defaultBranch = main`：新仓库默认分支
- `pull.rebase`：默认 false（merge）；若偏好线性历史可设 true（待定）
- `core.editor`：指向当前主力编辑器（见 `profile.md`）
- `credential.helper`：macOS 用 `osxkeychain`；Linux 用 `cache` 或 libsecret
- 常用别名：`co/br/ci/st/lg`（`lg` = 带图的历史）

## 参考
- `configs/git/.gitconfig`（实物，待补充）

## 验证
```sh
git --version      # 期望：较新稳定版
git config --list  # 确认身份与上述设置已生效
```
