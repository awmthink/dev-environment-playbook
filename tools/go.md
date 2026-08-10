# tool: Go

> 后端 / CLI 工具语言之一。

## 为什么用
编译型、并发模型好、CLI 生态强；适合写工具与服务。

## 版本约束
- Go：latest stable（按需通过版本管理器锁版本）

## 安装

| 平台 | 方式 |
|------|------|
| macOS | `brew install go`；或 `mise install go@latest` |
| Linux | `apt install golang`（可能偏旧）/ `mise install go@latest`（推荐） |

## 配置思路
- `GOROOT` / `GOPATH` 用默认即可；`$(go env GOPATH)/bin` 加入 PATH。
- 国内加速：`go env -w GOPROXY=https://goproxy.cn,direct`（与代理二选一）。
- `GO111MODULE=on`（现代默认）。

## 参考
- `configs/go/env`（`go env -w` 写入，待补充）

## 验证
```sh
go version
go env GOPATH GOPROXY
```
