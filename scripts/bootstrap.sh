#!/usr/bin/env bash
# scripts/bootstrap.sh — 新机器一键建环境（编排多层声明）
#
# 架构（见 tools/mise.md / platforms/linux.md）：
#   mise   (peer, 跨平台): runtime + build + LSP            ← Layer 1
#   brew   (peer, macOS):   GUI app + 字体 + CLI formula    ← Layer 2 (mac only)
#   per-user ~/.local:      linux llvm 预编译 + git 源码 + rg/jq/starship 预编译 ← Layer 2 (linux only)
#   外部:                   CUDA/TensorRT（见 tools/cuda.md，本脚本不管）
#
# 幂等：重复跑不出错。破坏性操作前会打印并不自动继续。
set -euo pipefail

say(){ printf '\n\033[1;36m▸ %s\033[0m\n' "$*"; }
PLATFORM="$(uname -s)"   # Darwin / Linux
ARCH="$(uname -m)"       # x86_64 / aarch64 (Linux); arm64 (mac)
HERE="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$HERE/.." && pwd)"

# mise / per-user 工具装到 ~/.local/bin；确保本脚本进程内能解析到
export PATH="$HOME/.local/bin:$PATH"

# ---------- Layer 0: 前置 ----------
say "Layer 0 — 前置检查（平台=$PLATFORM 架构=$ARCH）"
command -v curl >/dev/null || { echo "需要 curl"; exit 1; }

# ---------- Layer 1: mise ----------
say "Layer 1 — mise（runtime + build + LSP）"
if ! command -v mise >/dev/null; then
  curl -LsSf https://mise.run | sh
fi
# 落地全局 config（cp -n：已存在则不覆盖，避免抹掉用户改动）
mkdir -p ~/.config/mise
if [ -f ~/.config/mise/config.toml ]; then
  echo "  → ~/.config/mise/config.toml 已存在，跳过（要更新删掉它再跑）"
else
  cp "$REPO_ROOT/configs/mise/config.toml" ~/.config/mise/config.toml
fi
echo "  → 编辑 ~/.config/mise/config.toml 后跑：mise install"
echo "  → 激活（shell rc）：eval \"\$(mise activate bash)\""
mise install
mise ls

# ---------- Layer 2: brew (macOS only) ----------
if [ "$PLATFORM" = Darwin ]; then
  say "Layer 2 (macOS) — Xcode CLT + brew cask/字体"
  if ! xcode-select -p >/dev/null 2>&1; then
    echo "  ⚠ 未检测到 Xcode CLT（macOS 编译/SDK 必需）。请先跑：xcode-select --install"
    echo "    装完 CLT 再重跑本脚本。"
    exit 1
  fi
  command -v brew >/dev/null || /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew bundle install --file "$REPO_ROOT/configs/homebrew/Brewfile"
fi

# ---------- Layer 2: per-user llvm + git (Linux only) ----------
if [ "$PLATFORM" = Linux ]; then
  say "Layer 2 (Linux) — per-user llvm 预编译 + git 源码 + rg/jq/starship 预编译（进 ~/.local）"
  mkdir -p ~/.local

  # llvm 18.1.8（CUDA 12.8 要 clang<20；选老 glibc 构建以兼容更广的发行版，含 CentOS 8）
  LLVM_VER=18.1.8
  case "$ARCH" in
    x86_64)  TARBALL="clang+llvm-$LLVM_VER-x86_64-linux-gnu-ubuntu-18.04.tar.xz" ;;
    aarch64) TARBALL="clang+llvm-$LLVM_VER-aarch64-linux-gnu.tar.xz" ;;
    *) echo "  ⚠ 不支持的架构：$ARCH"; exit 1 ;;
  esac
  if [ ! -x ~/.local/llvm-$LLVM_VER/bin/clang ]; then
    TMP=$(mktemp -d)
    curl -fL "https://github.com/llvm/llvm-project/releases/download/llvmorg-$LLVM_VER/$TARBALL" -o "$TMP/llvm.tar.xz"
    tar -xf "$TMP/llvm.tar.xz" -C "$TMP"
    mv "$TMP"/clang+llvm-* ~/.local/llvm-$LLVM_VER
    rm -rf "$TMP"
  fi
  # 让本脚本后续步骤（git 编译）用到这个 clang
  export PATH="$HOME/.local/llvm-$LLVM_VER/bin:$PATH"
  echo "  → llvm 装好：~/.local/llvm-$LLVM_VER/bin/clang"

  # git（源码编译，版本两端统一）。构建依赖（sudo 装一次）：make + autoconf + zlib/libcurl/expat/openssl -devel。
  # 必须 `make configure && ./configure`，否则默认错认 GNU libiconv 导致链接失败；`NO_ICONV` 见下。
  GIT_VER=2.55.0
  if ! ~/.local/bin/git --version 2>/dev/null | grep -q "$GIT_VER"; then
    missing=""
    for c in make autoconf; do command -v "$c" >/dev/null || missing="$missing $c"; done
    for h in zlib.h curl/curl.h expat.h openssl/ssl.h; do
      echo "#include <$h>" | ${CC:-cc} -E - >/dev/null 2>&1 || missing="$missing $(basename $(dirname $h))-devel"
    done
    if [ -n "$missing" ]; then
      echo "  ⚠ git 源码编译缺少构建依赖：$missing"
      echo "    CentOS/RHEL: sudo dnf install make autoconf zlib-devel libcurl-devel expat-devel openssl-devel gettext perl"
      echo "    Ubuntu/Debian: sudo apt install make autoconf zlib1g-dev libcurl4-openssl-dev libexpat1-dev libssl-dev gettext perl"
      echo "    装好依赖后重跑本脚本（缺依赖时可用系统 git 兜底）。"
      exit 1
    fi
    TMP=$(mktemp -d)
    curl -fL "https://mirrors.edge.kernel.org/pub/software/scm/git/git-$GIT_VER.tar.xz" -o "$TMP/git.tar.xz"
    tar -xf "$TMP/git.tar.xz" -C "$TMP"
    # 用刚装的 clang 编译 git（不依赖系统 gcc）
    ( cd "$TMP/git-$GIT_VER" \
        && make CC=clang configure \
        && ./configure --prefix="$HOME/.local" CC=clang \
        && make -j"$(nproc)" NO_ICONV=YesPlease all \
        && make NO_ICONV=YesPlease install )
    rm -rf "$TMP"
  fi
  echo "  → git 装好：~/.local/bin/git $GIT_VER"

  # rg（GitHub 预编译 musl 静态，跨 glibc；见 platforms/linux.md）
  if [ ! -x ~/.local/bin/rg ]; then
    RG_VER=15.2.0
    TMP=$(mktemp -d)
    curl -fL "https://github.com/BurntSushi/ripgrep/releases/download/$RG_VER/ripgrep-$RG_VER-x86_64-unknown-linux-musl.tar.gz" -o "$TMP/rg.tgz"
    tar -xzf "$TMP/rg.tgz" -C "$TMP"
    install -m 0755 "$TMP/ripgrep-$RG_VER-x86_64-unknown-linux-musl/rg" ~/.local/bin/rg
    rm -rf "$TMP"
  fi
  echo "  → rg 装好：$(~/.local/bin/rg --version 2>/dev/null | head -1 || echo '?')"

  # jq（GitHub 预编译，静态单文件二进制）
  if [ ! -x ~/.local/bin/jq ]; then
    JQ_VER=1.8.2
    curl -fL "https://github.com/jqlang/jq/releases/download/jq-$JQ_VER/jq-linux-amd64" -o ~/.local/bin/jq
    chmod 0755 ~/.local/bin/jq
  fi
  echo "  → jq 装好：$(~/.local/bin/jq --version 2>/dev/null || echo '?')"

  # starship（官方 installer → ~/.local/bin；见 tools/starship.md）
  if [ ! -x ~/.local/bin/starship ]; then
    curl -sSf https://starship.rs/install.sh | sh -s -- -b ~/.local/bin -y
  fi
  echo "  → starship 装好：$(~/.local/bin/starship --version 2>/dev/null | head -1 || echo '?')"

  # fzf（GitHub 预编译单文件二进制）
  if [ ! -x ~/.local/bin/fzf ]; then
    FZF_VER=0.74.2
    TMP=$(mktemp -d)
    curl -fL "https://github.com/junegunn/fzf/releases/download/v$FZF_VER/fzf-$FZF_VER-linux_amd64.tar.gz" -o "$TMP/fzf.tgz"
    tar -xzf "$TMP/fzf.tgz" -C "$TMP"
    install -m 0755 "$TMP/fzf" ~/.local/bin/fzf
    rm -rf "$TMP"
  fi
  echo "  → fzf 装好：$(~/.local/bin/fzf --version 2>/dev/null || echo '?')"

  # zellij（GitHub 预编译 musl 静态，替代 tmux；见 tools/zellij.md）
  if [ ! -x ~/.local/bin/zellij ]; then
    ZELLIJ_VER=0.44.3
    TMP=$(mktemp -d)
    curl -fL "https://github.com/zellij-org/zellij/releases/download/v$ZELLIJ_VER/zellij-x86_64-unknown-linux-musl.tar.gz" -o "$TMP/z.tar.gz"
    tar -xzf "$TMP/z.tar.gz" -C "$TMP"
    install -m 0755 "$TMP/zellij" ~/.local/bin/zellij
    rm -rf "$TMP"
  fi
  echo "  → zellij 装好：$(~/.local/bin/zellij --version 2>/dev/null || echo '?')"
fi

# ---------- neovim（不进 mise：官方二进制 min glibc 2.32，老 distro 要源码编译）----------
say "neovim（平台分流）"
NVIM_VER="stable"
if [ "$PLATFORM" = Darwin ]; then
  # macOS：官方预编译（darwin arm64/x86_64）
  if ! command -v nvim >/dev/null || ! nvim --version | head -1 | grep -q 'NVIM'; then
    case "$ARCH" in
      arm64)  asset="nvim-macos-arm64.tar.gz" ;;
      x86_64) asset="nvim-macos-x86_64.tar.gz" ;;
    esac
    TMP=$(mktemp -d)
    curl -fL "https://github.com/neovim/neovim/releases/download/$NVIM_VER/$asset" -o "$TMP/n.tar.gz"
    tar -xzf "$TMP/n.tar.gz" -C "$TMP"
    mkdir -p ~/.local/bin ~/.local/share
    cp -r "$TMP"/nvim-macos/* ~/.local/ 2>/dev/null || ln -sf "$TMP"/nvim-macos/bin/nvim ~/.local/bin/nvim
    rm -rf "$TMP"
  fi
else
  # Linux：glibc >= 2.32 用官方二进制；否则源码编译
  GLIBC_VER=$(ldd --version 2>/dev/null | awk 'NR==1{print $NF}')
  glibc_new_enough() {  # 真·版本比较
    awk -v a="$GLIBC_VER" -v b="$1" 'BEGIN{split(a,A,".");split(b,B,".");
      for(i=1;i<=3;i++){x=A[i]+0;y=B[i]+0; if(x>y)exit 0; if(x<y)exit 1}}'
  }
  if glibc_new_enough 2.32; then
    if ! command -v nvim >/dev/null; then
      curl -fL "https://github.com/neovim/neovim/releases/download/$NVIM_VER/nvim-linux-x86_64.tar.gz" \
        | tar -xz -C ~/.local --strip-components=1
    fi
  else
    echo "  → glibc $GLIBC_VER < 2.32，源码编译 neovim（链系统 glibc）"
    if ! command -v nvim >/dev/null; then
      command -v cmake >/dev/null || { echo "  ⚠ neovim 源码编译需要 cmake（mise 应已装）"; exit 1; }
      TMP=$(mktemp -d)
      git clone --depth=1 --branch stable https://github.com/neovim/neovim "$TMP/nvim"
      ( cd "$TMP/nvim" && make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/.local" )
      ( cd "$TMP/nvim/build" && cmake --install . )
      rm -rf "$TMP"
    fi
  fi
fi
echo "  → nvim: $(~/.local/bin/nvim --version 2>/dev/null | head -1 || echo '检查安装')"

# ---------- 验证 ----------
say "验证"
mise current
if [ "$PLATFORM" = Linux ]; then
  ~/.local/llvm-18.1.8/bin/clang --version | head -1
  ~/.local/bin/git --version
  ~/.local/bin/rg --version | head -1
  ~/.local/bin/jq --version
  ~/.local/bin/fzf --version
  ~/.local/bin/starship --version | head -1
  command -v zellij >/dev/null && zellij --version    # 多路复用（替代 tmux）
else
  clang --version | head -1          # mac: Xcode CLT 的 apple clang
  command -v git && git --version
fi
[ -x /usr/local/cuda/bin/nvcc ] && /usr/local/cuda/bin/nvcc --version | tail -2 || echo "(CUDA 见 tools/cuda.md，另行配置)"

say "完成。shell rc（PATH + mise activate）见 tools/shell.md / configs/shell/env.sh"
