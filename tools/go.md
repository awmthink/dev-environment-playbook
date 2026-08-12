# tool: Go

> 后端 / CLI 工具语言之一。**版本由 mise 声明**（`go = "1.26"`）。

## 为什么用
编译型、并发模型好、CLI 生态强；适合写工具与服务。mise 统一声明版本（跨平台一致）。

## 版本约束
- Go：latest stable（mise 管；多版本走 mise 项目级 override）

## 安装

| 平台 | 方式 |
|------|------|
| macOS / Linux | 都走 **mise**：`go = "1.26"` 在 `configs/mise/config.toml` |

## 配置思路
- `GOROOT` / `GOPATH` 用默认即可；`$(go env GOPATH)/bin` 加入 PATH（见 `configs/shell/env.sh`）。
- 国内加速：`go env -w GOPROXY=https://goproxy.cn,direct`（与代理二选一）。
- `GO111MODULE=on`（现代默认）。
- 多版本：项目 `mise.toml` 里 `go = "1.25"` override 全局。

## 参考
- `configs/mise/config.toml`（go 声明）
- `configs/shell/env.sh`（`GOPATH/bin` PATH）

## 验证
```sh
mise current go
go version
go env GOPATH GOPROXY
```
