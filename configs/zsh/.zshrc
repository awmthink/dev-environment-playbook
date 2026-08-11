# configs/zsh/.zshrc — 参考实物（只读）
# 真实文件：~/.zshrc（不软链；agent 按本文件思路生成）
# 本模板只含跨机器通用的结构；机器特定的 PATH 注入（如 opencode）由本机自行维护。
# 约定见 tools/shell.md；本地配置（env/proxy/secrets）在 ~/.config/shell/

# ===== 本地配置（幂等 source）=====
[ -f ~/.config/shell/env.sh ]      && source ~/.config/shell/env.sh
[ -f ~/.config/shell/proxy.env ]   && source ~/.config/shell/proxy.env
[ -f ~/.config/shell/secrets.env ] && source ~/.config/shell/secrets.env

# ===== 历史 =====
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY HIST_IGNORE_DUPS HIST_REDUCE_BLANKS HIST_VERIFY

# ===== 补全 =====
autoload -Uz compinit && compinit

# ===== 别名 =====
alias ll='ls -lah'

# ===== 工具钩子 =====
# mise（多语言版本管理：node 等）
eval "$(mise activate zsh)"

# ===== 提示符：Starship =====
eval "$(starship init zsh)"
