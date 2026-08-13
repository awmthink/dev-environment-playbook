# tool: 网络代理（proxy）

> 跨工具的代理配置（shell / git / pnpm / docker / brew / curl 等）。**代理地址绝不进仓库**，只记思路。

## 为什么用
国内网络下，部分包源 / 模型 API / 文档需要代理；但地址随网络 / 机器变化，还可能含凭据，不能固化。

## 最低版本要求
- 不适用（配置类）

## 版本与安装策略

**多版本需求：不适用**（配置类）。代理客户端本身（如 clash / mihomo / surge）若需要，可单独建 `tools/<client>.md`。

## 配置思路
**地址放本地**：`~/.config/shell/proxy.env`（仓库外、不入版本管理），shell 启动时 `source`——但**只定义变量与开关函数，不导出**（代理默认关闭，避免无谓流量/泄漏），需要时 `proxy_on`。

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
- `configs/shell/proxy.env.example`（脱敏模板，可提交）
- `~/.config/shell/proxy.env`（真实地址，**本地、不提交**）

## 验证
```sh
source ~/.config/shell/proxy.env && proxy_on
curl -I https://www.google.com   # 期望：能连通
echo "$HTTP_PROXY"               # 期望：非空
```
