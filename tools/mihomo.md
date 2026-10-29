# tool: mihomo（Clash Meta）

> 本地分流代理客户端：国内/内网直连、境外走订阅节点。是 `proxy.md` 中 `proxy_on` 的后端。

## 为什么用

- 环境变量全量走单一上游代理是「一刀切」：无法按目标分流，NO_PROXY 只能手工维护；mihomo 规则引擎**逐连接**判定（GEOSITE/GEOIP 数据库），「国内直连、境外代理」零维护
- 出口两类：订阅连接（自动更新）+ 自定义扩展节点（手动追加）；多节点自动测速（url-test）+ 故障转移（fallback）
- 原版 Clash 已删库（2023），mihomo 是社区维护的 Clash Meta 后继，clash 配置格式兼容

## 最低版本要求

- >= v1.19（v1.19.33 实测）

## 版本与安装策略

**多版本需求：否**（单一常驻客户端，无多版本场景）。

**各平台安装**（推荐方案，不是铁律——达到上方最低版本即可）：

| 平台 | 推荐方式 |
|------|----------|
| macOS | `brew install mihomo`（homebrew-core formula；`brew services start mihomo` 常驻） |
| Linux | GitHub Releases 预编译二进制 → `~/.local/bin`（RHEL 系无系统包） |

首次配置还需下载三样到配置目录（`~/.config/mihomo/`），境外源不畅时先临时 `curl -x` 任一可用上游代理获取：
- geodata：`geoip.metadb` + `geosite.dat`（MetaCubeX/meta-rules-dat，`releases/latest`）
- 面板：metacubexd（`codeload.github.com/MetaCubeX/metacubexd/zip/refs/heads/gh-pages` 解压为 `ui/`）

Linux 下用 systemd 用户服务常驻（无 sudo 依赖）+ `loginctl enable-linger`（退出登录不中断），见 `configs/mihomo/mihomo.service`。

## 配置思路

（模板：`configs/mihomo/config.example.yaml`，脱敏占位符）

- **只监听 127.0.0.1**（mixed-port 7890、external-controller 9090）：远程机器访问面板走 SSH 隧道（`ssh -L 9090:127.0.0.1:9090`），不暴露局域网
- **出口只有两类，声明集中在 `proxy.env` 两个变量**：① `MIHOMO_SUB_URL` 订阅连接（`proxy-providers`，每日自动更新）② `MIHOMO_NODE_URL` 自定义扩展节点（http/socks5 代理 URL 形式）。落地时用 `configs/mihomo/render.py` 渲染出 `config.yaml`（幂等，复用已有 secret）；ss/vmess 等复杂节点类型直接改 `config.yaml`
- **订阅经 `proxy-providers` 引入，只取 `proxies` 段**：订阅自带的 rules/groups/dns 全部丢弃——分流规则以自己的 config 为准，不受订阅方模板绑架
- **规则四条**：内网直连（`GEOIP,private,DIRECT,no-resolve`）→ `GEOSITE,cn` 直连 → `GEOIP,CN` 直连 → `MATCH` 走出口组
- **组结构**：`PROXY`(select) 聚合 [ `自动选择`(url-test，仅订阅节点)、`故障转移`(fallback → 自定义节点)、全部出口 ]；**自定义节点不进自动测速组**——出口需手动管控的场景（如内网代理），不该被测速自动选中
- `store-selected: true`：记住面板手动选择，重启不丢
- **订阅 URL / 节点凭据绝不进仓库**；真实 config.yaml 权限 600

### 已知坑（工具自身）

- 机场订阅多为灰产，节点常共用单台入口机（所有区域域名解析同一 IP）——入口一挂全部节点同时失效，**fallback 兜底是必需品**，不是可选项
- REST API 对中文节点名的 `/proxies/{name}/delay` 路由会 404；批量测速用 `/group/{name}/delay`
- HTTP 代理型自定义节点通常仅放行标准端口的 CONNECT → 不能作为链式上游去连订阅节点（节点只能直连）

## 参考

- `configs/mihomo/config.example.yaml`（脱敏配置模板，render.py 的输入）
- `configs/mihomo/render.py`（从 proxy.env 的 `MIHOMO_SUB_URL` / `MIHOMO_NODE_URL` 渲染 config.yaml）
- `configs/mihomo/mihomo.service`（systemd 用户服务单元）
- `~/.config/mihomo/`（真实配置，**本地、不提交**）

## 验证

```sh
mihomo -v                            # 期望：>= v1.19
systemctl --user is-active mihomo    # 期望：active
curl -sx http://127.0.0.1:7890 -o /dev/null -w '%{http_code}\n' https://www.baidu.com     # 期望：200（规则直连）
curl -sx http://127.0.0.1:7890 -o /dev/null -w '%{http_code}\n' --max-time 15 \
     https://www.google.com/generate_204   # 期望：204（走订阅节点；节点全挂时经 fallback 走自定义节点）
```
