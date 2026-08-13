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
| Linux | 源码编译 → `~/.local/bin/git`（发行版偏旧，上游无预编译二进制）。安装命令见下。 |

> **Linux 源码编译要点**：`make configure && ./configure --prefix=$HOME/.local CC=clang && make all && make install`。
> - **必须在剥离 conda 的 PATH 下编译**：conda 在 PATH 时，configure 会捡到 conda 的 `curl-config`，把 `-I <conda>/include` 带进编译 → conda 的 GNU libiconv `iconv.h`（`#define iconv_open libiconv_open`）遮蔽 glibc 头 → 链接报 `undefined reference to libiconv_open`。同时 curl/openssl 也会被链到 conda 版本，git 与 conda 耦合。
> - 缺依赖期间可用**系统 git 兜底**。

### Linux 安装（源码编译，链 per-user clang）
```sh
# 构建依赖（一次性，需 sudo）：
#   CentOS/RHEL: sudo dnf install make autoconf zlib-devel libcurl-devel expat-devel openssl-devel gettext perl
#   Ubuntu/Debian: sudo apt install make autoconf zlib1g-dev libcurl4-openssl-dev libexpat1-dev libssl-dev gettext perl
# 干净 PATH：剥掉 conda，避免 conda 的 curl-config / GNU libiconv 头泄漏（见上方要点）
CLEAN_PATH=$(echo "$PATH" | tr ':' '\n' | rg -v 'miniconda|conda' | paste -sd:)
GIT_VER=2.55.0
TMP=$(mktemp -d)
curl -fL "https://mirrors.edge.kernel.org/pub/software/scm/git/git-$GIT_VER.tar.xz" -o "$TMP/git.tar.xz"
tar -xf "$TMP/git.tar.xz" -C "$TMP"
( cd "$TMP/git-$GIT_VER" \
    && PATH="$CLEAN_PATH" make CC=clang configure \
    && PATH="$CLEAN_PATH" ./configure --prefix="$HOME/.local" CC=clang \
    && PATH="$CLEAN_PATH" make -j"$(nproc)" CC=clang all \
    && PATH="$CLEAN_PATH" make CC=clang install )
rm -rf "$TMP"
```

## 配置思路
<!-- 个人身份信息是机器/账号相关，不要写死进仓库；agent 同步时从本地或向我询问 -->

- `user.name` / `user.email`：身份，待填（绝不进仓库）
- `init.defaultBranch = main`：新仓库默认分支
- `pull.rebase`：默认 false（merge）；若偏好线性历史可设 true（待定）
- `core.editor`：默认继承 `$EDITOR=nvim`（见 `tools/shell.md` / `configs/shell/env.sh`），无需单独设置。用 nvim 而非 Zed——commit message / rebase 这类编辑场景常在终端 / SSH 下发生，Zed 是 GUI-only、SSH 不可用。
- `credential.helper`：macOS 用 `osxkeychain`；Linux 用 `cache` 或 libsecret
- **不设别名**：习惯原生命令（与 `shell.md` 「不用 git 别名」一致）

## 参考
- `configs/git/.gitconfig`（实物，待补充）

## 验证
```sh
git --version      # 期望：较新稳定版
git config --list  # 确认身份与上述设置已生效
# iconv 已启用（非 NO_ICONV）：GBK 提交信息能正确转码显示
tmp=$(mktemp -d) && cd "$tmp" && git init -q && git config user.email t@t && git config user.name t \
  && printf '中文' | iconv -t GBK > m && git -c i18n.commitEncoding=GBK commit --allow-empty -q -F m \
  && git log -1 --pretty=%s   # 期望输出：中文（GBK → UTF-8 转码成功）
cd - && rm -rf "$tmp"
```
