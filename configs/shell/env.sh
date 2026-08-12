# ~/.config/shell/env.sh — 共享环境变量（zsh / bash 都 source）
# 约定：只放「非密、shell 无关、POSIX 兼容」的 export。
# 密钥 → secrets.env；代理 → proxy.env。见 tools/shell.md。

# ===== 语言 / 区域 =====
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# ===== 编辑器 / 分页器 =====
export EDITOR=nvim
export VISUAL="$EDITOR"
export PAGER=less
export LESS=-RiF   # -R 颜色 / -i 搜索忽略大小写 / -F 一屏即退

# ===== 颜色 =====
export CLICOLOR=1

# ===== 别名（POSIX，zsh / bash 共用；从各 rc 抽出以去重）=====
alias ll='ls -lah'
alias vim='nvim'

# ===== Python / uv =====
# 只用 uv 管理的 python（tools/python.md）：避免项目落到系统/brew python 上，保证解释器跨机器一致
export UV_PYTHON_PREFERENCE=only-managed

# ===== 通用 PATH（跨平台） =====
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/go/bin:$HOME/.cargo/bin:/usr/local/bin:$PATH"

# ===== 平台专属：macOS / Homebrew =====
if [ "$(uname)" = Darwin ]; then
  export PATH="/opt/homebrew/bin:$PATH"
  export HOMEBREW_API_AUTO_UPDATE_SECS=86400
  export HOMEBREW_AUTO_UPDATE_SECS=604800
  # 中科大源（国内加速；按需换清华/官方）
  # brew 4.0+ 默认 API 模式：无需 HOMEBREW_INSTALL_FROM_API、纯 API 模式无 core git tap，
  # 故只留真正生效的三项。BREW_GIT_REMOTE 须与 /opt/homebrew 实际 origin 一致
  # （git -C /opt/homebrew remote set-url origin <同此值>），否则 brew doctor 报 non-standard origin。
  export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
  export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
  export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
fi

# ===== 平台专属：Linux / per-user llvm（CUDA 12.8 兼容的 clang<20）=====
if [ "$(uname)" = Linux ]; then
  # per-user 预编译 llvm（见 scripts/bootstrap.sh / tools/c-cpp.md）：clang/clangd/clang-format/clang-tidy
  [ -x "$HOME/.local/llvm-18.1.8/bin/clang" ] && export PATH="$HOME/.local/llvm-18.1.8/bin:$PATH"
  export CC=clang CXX=clang++
fi

# ===== mise（runtime + build + LSP 的 PATH 与版本切换）=====
# init 钩子放各 shell rc（需指定 shell 类型）：
#   zsh: eval "$(mise activate zsh)"    bash: eval "$(mise activate bash)"
# 这里只确保 mise 二进制可解析（~/.local/bin 已在上面的通用 PATH）

