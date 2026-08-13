# tool: Go

> 后端 / CLI 工具语言之一。**版本由 mise 锁**（`mise use -g go@1.26`）。

## 为什么用
编译型、并发模型好、CLI 生态强；适合写工具与服务。mise 统一声明版本（跨平台一致）。

## 最低版本要求
- Go：latest stable（mise 管）

## 版本与安装策略

**多版本需求：基本不需要手动管**——Go 1.21+ 的 `toolchain` 机制按 `go.mod` 的 `go` / `toolchain` 行自动下载匹配版本（`GOTOOLCHAIN=auto`，默认开）。mise 只管全局默认；项目需要别的版本靠 `go.mod` 驱动，不用切 mise。极端情况才在项目 `mise.toml` 写 `go = "1.25"`。

**各平台安装**：

| 平台 | 推荐方式 |
|------|----------|
| macOS / Linux | 都走 **mise**：`mise use -g go@1.26`（装 + 锁全局默认） |

## 配置思路
- `GOROOT` / `GOPATH` 用默认即可；`$(go env GOPATH)/bin` 加入 PATH（见 `configs/shell/env.sh`）。
- 国内加速：`go env -w GOPROXY=https://goproxy.cn,direct`（与代理二选一）。
- `GO111MODULE=on`（现代默认）。

## 参考
- `configs/shell/env.sh`（`GOPATH/bin` PATH）

## 验证
```sh
mise current go
go version
go env GOPATH GOPROXY
```
