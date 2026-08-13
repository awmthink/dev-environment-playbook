# configs/mcp/ — MCP servers

> MCP server 配置集中于此。当前 agent 主力是 **opencode**（见 `profile.md`），MCP 配在 opencode 的 `mcp` 字段。Zed 定位为纯 editor，不配 MCP。

## MCP servers 清单

| Server | 类型 | 用途 | Key 来源 |
|--------|------|------|----------|
| web-search-prime | remote | 联网搜索（bigmodel） | `ZAI_CODING_CN_API_KEY` |
| web-reader | remote | 网页阅读（bigmodel） | `ZAI_CODING_CN_API_KEY` |
| zai-mcp-server | local（npx） | Z.AI MCP 工具集 | `ZAI_CODING_CN_API_KEY` |

> 所有 server 的 key 统一走 `ZAI_CODING_CN_API_KEY`（放 `~/.config/shell/secrets.env`，见 `tools/shell.md`）。config 里用 `{env:ZAI_CODING_CN_API_KEY}` 插值，**绝不写明文**。

## opencode 格式（`mcp` 字段，放 `~/.config/opencode/opencode.json`）

```json
{
  "mcp": {
    "web-search-prime": {
      "type": "remote",
      "url": "https://open.bigmodel.cn/api/mcp/web_search_prime/mcp",
      "headers": { "Authorization": "Bearer {env:ZAI_CODING_CN_API_KEY}" }
    },
    "web-reader": {
      "type": "remote",
      "url": "https://open.bigmodel.cn/api/mcp/web_reader/mcp",
      "headers": { "Authorization": "Bearer {env:ZAI_CODING_CN_API_KEY}" }
    },
    "zai-mcp-server": {
      "type": "local",
      "command": ["npx", "-y", "@z_ai/mcp-server"],
      "environment": {
        "Z_AI_API_KEY": "{env:ZAI_CODING_CN_API_KEY}",
        "Z_AI_MODE": "ZHIPU"
      }
    }
  }
}
```

> 其它 agent（claude-code / codex / qoder-cli）若需同样的 MCP，参考各自 MCP 配置格式，key 同样走 `{env:ZAI_CODING_CN_API_KEY}`。
