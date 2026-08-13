# tool: 字体（Nerd Font）

> 终端 / 编辑器渲染用的编程字体。**桌面端需求**——Linux headless 服务器不装（见 `platforms/linux.md`）。对应 `profile.md`「字体」偏好。

## 为什么用
- **Nerd Font**：在原编程字体基础上补齐图标 / 连字 / Powerline 符号，是 Starship 提示符、zellij 状态栏、编辑器图标正常渲染的前提（见 `tools/shell.md`）。
- 选中英混排优化 + 全图标覆盖的字体，避免终端图标成「豆腐块」、中英等宽对齐错位。

## 字体选择

| 角色 | 字体 | 理由 |
|------|------|------|
| 主力 | **Maple Mono NF CN** | 中英混排对齐好、覆盖图标 / 连字 / CJK |
| 备选 | **JetBrainsMono Nerd Font** | 经典方正、纯 ASCII 区最稳；看腻主力时切换 |

> 不锁定字体版本（tap 随 homebrew 更新）；切换偏好即可，无多版本管理需求。

## 版本与安装策略

**多版本需求：否**——字体全局单一即可，按平台最 canonical 方式装。

| 平台 | 推荐方式 |
|------|----------|
| macOS | `brew tap homebrew/cask-fonts` 后 `brew install --cask <font>`（cask 是字体最省事入口） |
| Linux server | **不装**（headless，字体属桌面端；SSH 终端渲染用本地（macOS）字体） |

### macOS 安装
```sh
brew install --cask font-maple-mono-nf-cn            # 主力
brew install --cask font-jetbrains-mono-nerd-font    # 备选
```

## 配置思路
- 字体选型属偏好（见 `profile.md`），在各 GUI（Ghostty / Zed / iTerm2）设置里指定主力字体即可。
- 图标依赖 Nerd Font——主力 Maple Mono NF CN 已覆盖，无需额外处理。

## 验证
```sh
brew list --cask | grep -E 'maple|jetbrains'   # 期望：列出已装字体 cask
# 在终端 / 编辑器里设为该字体：确认 Starship / 状态栏图标无「豆腐块」
```
