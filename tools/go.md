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
- `GOROOT` / `GOPATH` 用默认即可（**不 export**；现代 Go 默认 `~/go`、`~/go/bin`）；把 `~/go/bin` 加进 PATH（见 `configs/shell/env.sh`）。
- **`GOBIN` 必须保持未设置**：mise 激活 go 时会注入 `GOBIN=<mise go 安装目录>`，导致 `go install` 的工具（gopls/dlv…）绑死 go 版本、mise 升级 go 时丢失。故 rc 里 `mise activate` 之后要 `unset GOBIN`，让工具落 `~/go/bin`、跨版本持久（见 `configs/bash/.bashrc` / `configs/zsh/.zshrc`）。
- 国内加速：`go env -w GOPROXY=https://goproxy.cn,direct`（与代理二选一）。
- `GO111MODULE=on`（现代默认）。

## 参考
- `configs/shell/env.sh`（`~/go/bin` 进 PATH）
- `configs/bash/.bashrc` / `configs/zsh/.zshrc`（`unset GOBIN`）

## 验证
```sh
mise current go
go version
go env GOPATH GOPROXY
echo "GOBIN=[${GOBIN:-<unset>}]"   # 期望空（mise 注入的已被 rc 里 unset 掉）
command -v gopls                    # 期望：~/go/bin/gopls（非 mise 安装目录）
```
