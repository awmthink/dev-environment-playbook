# configs/zsh/.zshrc — 参考实物（只读）
# 真实文件：~/.zshrc（不软链；agent 按本文件思路生成）
# 本模板只含跨机器通用的结构；机器特定的 PATH 注入（如 opencode）由本机自行维护。
# 约定见 tools/shell.md；本地配置（env/proxy/secrets）在 ~/.config/shell/
# 别名已抽到 configs/shell/env.sh（POSIX，与 .bashrc 共用），本文件只留 shell 专属项。

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

# ===== 工具钩子 =====
# mise（runtime + build + LSP；macOS 与 Linux 共享，见 tools/mise.md）
eval "$(mise activate zsh)"
unset GOBIN   # 覆盖 mise 为 go 注入的 GOBIN（=mise go 安装目录），让 go install 落 ~/go/bin、跨 go 版本持久（见 tools/go.md）
# ===== 提示符：Starship =====
eval "$(starship init zsh)"
