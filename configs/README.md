# configs/ — 参考配置实物

存放**只读参考**的配置文件原件（dotfile / JSON / toml 等）。

## 规则
- 这里是「文档 / 参考」，**不是**被软链接到 `$HOME` 的目标。实际落地由 agent 按 `tools/` 与 `agents/` 的思路生成。
- 命名建议按工具分子目录：`configs/zed/settings.json`、`configs/opencode.json`。
- 含密钥的文件**不要**放进来；用占位符脱敏。
