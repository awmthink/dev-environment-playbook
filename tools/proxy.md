# tool: 网络代理（proxy）

> 跨工具的代理配置（shell / git / pnpm / docker / brew / curl 等）。**代理地址绝不进仓库**，只记思路。

## 为什么用
国内网络下，部分包源 / 模型 API / 文档需要代理；但地址随网络 / 机器变化，还可能含凭据，不能固化。

## 最低版本要求
- 不适用（配置类）

## 版本与安装策略

**多版本需求：不适用**（配置类）。代理客户端统一用 mihomo（见 `mihomo.md`），`proxy_on` 的后端就是它的本地入口 `127.0.0.1:7890`。

## 配置思路
**地址放本地**：`~/.config/shell/proxy.env`（仓库外、不入版本管理），shell 启动时 `source`——但**只定义变量与开关函数，不导出**（代理默认关闭，避免无谓流量/泄漏），需要时 `proxy_on`。

**两级出口**（客户端与分流规则见 `mihomo.md`）：
- 默认：`proxy_on` → 本地 mihomo（国内/内网直连，境外走订阅节点，节点全挂自动回落自定义节点）
- 应急：`MIHOMO_NODE_URL`（自定义节点）可直接 `curl -x "$MIHOMO_NODE_URL"` 手动使用

需要统一处理的环境变量：
- `HTTP_PROXY` / `HTTPS_PROXY` / `ALL_PROXY` / `NO_PROXY`（小写同名也设一份，部分工具只认小写）

各工具的代理要点：
- **git**：`git config --global http.proxy / https.proxy` 或走环境变量
- **pnpm / npm**：`.npmrc` 的 `proxy` / `https-proxy`
- **docker**：`~/.docker/config.json` 或 systemd drop-in（Linux）
- **brew**：走环境变量
- **curl**：环境变量或 `.curlrc`

提供**开 / 关代理脚本**（`proxy_on` / `proxy_off`），只改当前 shell 环境变量，幂等。

## 参考
- `mihomo.md`（代理客户端本体：安装、分流规则、出口组）
- `configs/shell/proxy.env.example`（脱敏模板，可提交）
- `~/.config/shell/proxy.env`（真实地址，**本地、不提交**）

## 验证
```sh
source ~/.config/shell/proxy.env && proxy_on
curl -sI --max-time 15 https://www.google.com | head -1   # 期望：HTTP/2 200（经 mihomo 节点/兜底）
curl -s -o /dev/null -w '%{http_code}\n' https://www.baidu.com   # 期望：200（规则直连）
echo "$HTTP_PROXY"               # 期望：http://127.0.0.1:7890
```
