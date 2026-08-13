# configs/mcp/ — MCP servers

> MCP server 配置集中于此。**opencode** 用 `mcp` 字段格式（见 `profile.md`）；**pi**（装 pi-mcp-adapter 后）用标准 `mcpServers` 格式。Zed 定位为纯 editor，不配 MCP。

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

> 其它 agent（codex / zcode / cursor）是 GUI App，MCP 在 App 内配置，本仓库不覆盖（见 `agents/README.md`）。

## pi 格式（pi-mcp-adapter，标准 `mcpServers`，放 `~/.config/mcp/mcp.json`）

> pi 无内置 MCP，先装适配器 `pi install npm:pi-mcp-adapter`（见 `agents/pi.md`），再读标准 MCP 配置文件。adapter 按字段推断传输（`url` = StreamableHTTP / `command`+`args` = stdio，**无 `type` 字段**）；插值用 `${VAR}`（不是 opencode 的 `{env:VAR}`）：

```json
{
  "mcpServers": {
    "web-search-prime": {
      "url": "https://open.bigmodel.cn/api/mcp/web_search_prime/mcp",
      "headers": { "Authorization": "Bearer ${ZAI_CODING_CN_API_KEY}" }
    },
    "web-reader": {
      "url": "https://open.bigmodel.cn/api/mcp/web_reader/mcp",
      "headers": { "Authorization": "Bearer ${ZAI_CODING_CN_API_KEY}" }
    },
    "zai-mcp-server": {
      "command": "npx",
      "args": ["-y", "@z_ai/mcp-server"],
      "env": {
        "Z_AI_API_KEY": "${ZAI_CODING_CN_API_KEY}",
        "Z_AI_MODE": "ZHIPU"
      }
    }
  }
}
```
