# ~/.config/shell/env.sh — 共享环境变量（zsh / bash 都 source）
# 约定：只放「非密、shell 无关、POSIX 兼容」的 export。
# 密钥 → secrets.env；代理 → proxy.env。见 tools/shell.md。

# ===== 语言 / 区域 =====
export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

# ===== 编辑器 / 分页器 =====
export EDITOR=vim
export VISUAL="$EDITOR"
export PAGER=less
export LESS=-RiF   # -R 颜色 / -i 搜索忽略大小写 / -F 一屏即退

# ===== 颜色 =====
export CLICOLOR=1

# ===== 通用 PATH（跨平台） =====
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/go/bin:$HOME/.cargo/bin:/usr/local/bin:$PATH"

# ===== 平台专属：macOS / Homebrew =====
if [ "$(uname)" = Darwin ]; then
  export PATH="/opt/homebrew/bin:$PATH"
  # brew llvm（keg-only）前置 PATH：让 clang/clangd/clang-format/clang-tidy 用 brew 版（见 tools/c-cpp.md「LLVM 语言工具」）
  export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
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
