# tool: Starship

> 跨 shell 的提示符（prompt）工具，zsh / bash 统一。对应 `profile.md` 全局偏好的「提示符」维度。

## 为什么用
- 一次配置，zsh（macOS）和 bash（Linux 服务器）通用——命中 profile 双 shell 场景，rc 里只加 init 钩子、提示符逻辑不分叉。
- 开箱显示 git 分支 / 状态、当前目录的语言版本（Python/Node/Rust/Go…）、上一条命令耗时；对多语言栈（算法 + 全栈）自动识别当前项目语言，省去手写 prompt 逻辑。
- 替代 oh-my-zsh 主题与手写 PROMPT——配合 `shell.md`「不用重框架」原则，提示符单独交给 Starship，rc 保持干净。
- Rust 实现，启动开销小。

## 版本约束
- 版本：latest（brew / 官方脚本）

## 安装

| 平台 | 方式 |
|------|------|
| macOS / Linux | 都走 **mise**：`starship = "latest"` 在 `configs/mise/config.toml` |

## 配置思路
- **钩子**：shell rc 末尾 `eval "$(starship init <shell>)"`（zsh 加到 `.zshrc`，bash 加到 `.bashrc`；见 `shell.md`）。幂等，无副作用。
- **配置文件**：`~/.config/starship.toml`（可选；不创建则用内置默认，已足够起步）。TOML，每个 `[module]` 控制一个模块（目录 / git / 语言版本 / 时长…）。
- **字体**：图标依赖 Nerd Font——profile 主力 Maple Mono NF CN 已覆盖，无需额外装字体。
- **起步预设**：`starship preset nerd-font-symbols -o ~/.config/starship.toml` 生成含 NF 图标的基础配置，再按需微调。
- **跨机器**：`starship.toml` 纯偏好、不含密钥，可纳入 `configs/` 提交，多机复用。
- **排查**：`starship timings` 看各模块耗时（提示符变慢时定位）；`starship explain` 解释当前显示了哪些模块。

## 参考配置
- `configs/starship.toml`（实物，待补充；当前用默认 / 预设）

## 验证
```sh
starship --version      # 期望：有版本输出
which starship          # 期望：在 PATH
starship explain        # 期望：列出当前提示符各模块及原因
# 开新终端：确认显示目录 / git 分支 / 语言版本
```
