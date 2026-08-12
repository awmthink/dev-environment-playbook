# configs/bash/.bashrc — 参考实物（只读）
# 真实文件：~/.bashrc（不软链；agent 按本文件思路生成）
# Linux server 登录 shell（见 platforms/linux.md）；与 .zshrc 共享 env.sh，仅薄壳。
# 约定见 tools/shell.md；本地配置（env/proxy/secrets）在 ~/.config/shell/
# 别名已抽到 configs/shell/env.sh（POSIX，与 .zshrc 共用），本文件只留 shell 专属项。

# ===== 本地配置（幂等 source）=====
[ -f ~/.config/shell/env.sh ]      && source ~/.config/shell/env.sh
[ -f ~/.config/shell/proxy.env ]   && source ~/.config/shell/proxy.env
[ -f ~/.config/shell/secrets.env ] && source ~/.config/shell/secrets.env

# ===== 历史 =====
HISTFILE=~/.bash_history
HISTSIZE=10000
HISTFILESIZE=10000
shopt -s histappend                # 追加而非覆盖（近似 zsh INC_APPEND_HISTORY）
HISTCONTROL=ignoreboth:erasedups   # 忽略重复 + 空格前导
# 多会话近实时共享（近似 zsh SHARE_HISTORY）：每条命令后追加并拉取新条目
PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"

# ===== 工具钩子 =====
# mise（runtime + build + LSP；见 tools/mise.md）
eval "$(mise activate bash)"
# ===== 提示符：Starship =====
eval "$(starship init bash)"
